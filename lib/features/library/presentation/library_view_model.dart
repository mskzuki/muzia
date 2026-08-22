import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:muzia/features/library/data/directory_service.dart';
import 'package:muzia/features/library/data/file_picker_service.dart';
import 'package:muzia/features/library/data/file_scanner_service.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/data/security_scoped_bookmark_service.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';

enum LibraryStatus { empty, loading, ready, readyWithWarnings, error }

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    FilePickerService? picker,
    FileScannerService? scanner,
    DirectoryService? directoryService,
    MusicRepository? repository,
    SecurityScopedBookmarkService? bookmarkService,
  }) : _picker = picker ?? NativeFilePickerService(),
       _scanner = scanner ?? LocalFileScannerService(),
       _directoryService = directoryService ?? NativeDirectoryService(),
       _repository = repository ?? InMemoryMusicRepository(),
       _bookmarkService =
           bookmarkService ?? const NoopSecurityScopedBookmarkService();

  LibraryViewModel.persistent({
    FilePickerService? picker,
    FileScannerService? scanner,
    DirectoryService? directoryService,
    SecurityScopedBookmarkService? bookmarkService,
  }) : this(
         picker: picker,
         scanner: scanner,
         directoryService: directoryService,
         repository: LazyPersistentMusicRepository(
           bookmarkService: bookmarkService,
         ),
         bookmarkService:
             bookmarkService ?? NativeSecurityScopedBookmarkService(),
       );

  final FilePickerService _picker;
  final FileScannerService _scanner;
  final DirectoryService _directoryService;
  final MusicRepository _repository;
  final SecurityScopedBookmarkService _bookmarkService;
  LibraryStatus _status = LibraryStatus.empty;
  List<Track> _tracks = const [];
  String? _errorMessage;
  String? _warningTitle;
  String? _warningMessage;
  int _failureRevision = 0;
  bool _initialized = false;

  LibraryStatus get status => _status;
  List<Track> get tracks => List.unmodifiable(_tracks);
  String? get registeredFolder => _repository.registeredFolder;
  String? get errorMessage => _errorMessage;
  String? get warningTitle => _warningTitle;
  String? get warningMessage => _warningMessage;
  int get failureRevision => _failureRevision;

  /// 楽曲一覧を表示できる状態かどうか。`ready` と `readyWithWarnings` は
  /// 警告の有無が違うだけで、一覧の表示可否としては同じ扱いになる。
  bool get canShowTracks =>
      _status == LibraryStatus.ready ||
      _status == LibraryStatus.readyWithWarnings;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _status = LibraryStatus.loading;
    _clearWarning();
    notifyListeners();
    try {
      await _repository.load();
      _tracks = _repository.tracks;
      if (_tracks.isEmpty) {
        _status = LibraryStatus.empty;
      } else if (_repository.folderAccessLost) {
        // 楽曲、メタデータ、削除状態はDBに残っている。フォルダのアクセス権だけを
        // 失った状態なので、一覧は表示したうえで再登録を促す。
        _status = LibraryStatus.readyWithWarnings;
        _setWarning(
          title: 'フォルダにアクセスできません',
          message: 'フォルダの場所が変わった可能性があります。フォルダを登録し直してください。',
        );
      } else {
        _status = LibraryStatus.ready;
      }
      notifyListeners();
    } on Object {
      _setError('ライブラリの読み込みに失敗しました。');
    }
  }

  Future<void> chooseAndScanFolder() async {
    final preserveExistingTracks = canShowTracks;
    final String? selectedPath;
    final Uint8List? bookmark;
    try {
      selectedPath = await _picker.pickDirectory();
      if (selectedPath == null) return;
      bookmark = await _bookmarkService.createBookmark(selectedPath);
    } on Object {
      _reportFailure(
        'フォルダを登録できませんでした。',
        preserveExistingTracks: preserveExistingTracks,
      );
      return;
    }
    await registerAndScan(selectedPath, securityScopedBookmark: bookmark);
  }

  Future<void> registerAndScan(
    String path, {
    Uint8List? securityScopedBookmark,
  }) async {
    final previousStatus = _status;
    final preserveExistingTracks = canShowTracks;
    final validationError = await _validateDirectory(path);
    if (validationError != null) {
      _reportFailure(
        validationError,
        preserveExistingTracks: preserveExistingTracks,
      );
      return;
    }
    if (p.equals(path, _repository.registeredFolder ?? '')) {
      _reportFailure(
        'このフォルダはすでに登録されています。',
        preserveExistingTracks: preserveExistingTracks,
      );
      return;
    }

    _status = LibraryStatus.loading;
    _errorMessage = null;
    _clearWarning();
    notifyListeners();
    try {
      final tracks = <Track>[];
      var candidateCount = 0;
      var metadataIssueCount = 0;
      await for (final event in _scanner.scan(path)) {
        switch (event) {
          case TrackFound(:final track):
            tracks.add(track);
            _tracks = List.unmodifiable(tracks);
            notifyListeners();
          case ScanIssueEvent(kind: ScanIssueKind.metadata):
            metadataIssueCount++;
          case ScanCompleted(candidateCount: final completedCount):
            candidateCount = completedCount;
        }
      }
      if (candidateCount == 0) {
        _status = LibraryStatus.empty;
      } else if (tracks.isEmpty && metadataIssueCount > 0) {
        _restoreTracksFromRepository();
        _reportFailure(
          '音楽ファイルのメタデータを解析できませんでした。',
          preserveExistingTracks: preserveExistingTracks,
          preservedStatus: previousStatus,
        );
        return;
      } else if (metadataIssueCount > 0) {
        _status = LibraryStatus.readyWithWarnings;
        _setWarning(
          title: '一部のファイルを読み込めませんでした',
          message: '$metadataIssueCount件の音楽ファイルを解析できませんでした。',
        );
      } else {
        _status = LibraryStatus.ready;
      }
      await _repository.registerFolder(
        path,
        tracks,
        securityScopedBookmark: securityScopedBookmark,
      );
      notifyListeners();
    } on FolderAccessException {
      _restoreTracksFromRepository();
      _reportFailure(
        'フォルダにアクセスできません。権限を確認してください。',
        preserveExistingTracks: preserveExistingTracks,
        preservedStatus: previousStatus,
      );
    } on Object {
      _restoreTracksFromRepository();
      _reportFailure(
        'フォルダのスキャンに失敗しました。',
        preserveExistingTracks: preserveExistingTracks,
        preservedStatus: previousStatus,
      );
    }
  }

  /// スキャン中は受信した楽曲で `_tracks` を逐次差し替えるため、失敗すると
  /// 中途半端な結果が残る。永続層は登録前の内容のままなので、そちらへ戻す。
  void _restoreTracksFromRepository() {
    _tracks = _repository.tracks;
  }

  Future<bool> removeTracks(List<Track> tracks) async {
    if (tracks.isEmpty) return true;
    try {
      await _repository.markRemovedMany(
        tracks.map((track) => track.filePath).toList(growable: false),
        true,
      );
      _tracks = _repository.tracks;
      _status = _tracks.where((track) => !track.isRemoved).isEmpty
          ? LibraryStatus.empty
          : LibraryStatus.ready;
      _errorMessage = null;
      _clearWarning();
      notifyListeners();
      return true;
    } on Object {
      _setError('楽曲をライブラリから削除できませんでした。');
      return false;
    }
  }

  Future<bool> updateTrackMetadata(Track track, MetadataValues values) async {
    return updateTracksMetadata([track], values);
  }

  Future<bool> updateTracksMetadata(
    List<Track> tracks,
    MetadataValues values,
  ) async {
    if (tracks.isEmpty) return true;
    try {
      await _repository.updateMetadataMany(
        tracks.map((track) => track.filePath).toList(growable: false),
        values,
      );
      _tracks = _repository.tracks;
      _status = _tracks.where((track) => !track.isRemoved).isEmpty
          ? LibraryStatus.empty
          : _warningMessage != null
          ? LibraryStatus.readyWithWarnings
          : LibraryStatus.ready;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on Object {
      _setError('メタデータを保存できませんでした。');
      return false;
    }
  }

  Future<String?> _validateDirectory(String path) async {
    if (path.trim().isEmpty || !await _directoryService.isDirectory(path)) {
      return 'フォルダが見つかりません。';
    }
    return null;
  }

  void _setError(String message) {
    _status = LibraryStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _reportFailure(
    String message, {
    bool preserveExistingTracks = false,
    LibraryStatus? preservedStatus,
  }) {
    if (preserveExistingTracks || canShowTracks) {
      if (preserveExistingTracks && preservedStatus != null) {
        _status = preservedStatus;
      }
      _errorMessage = message;
      _failureRevision++;
      notifyListeners();
      return;
    }
    _setError(message);
  }

  void _setWarning({required String title, required String message}) {
    _warningTitle = title;
    _warningMessage = message;
  }

  void _clearWarning() {
    _warningTitle = null;
    _warningMessage = null;
  }
}
