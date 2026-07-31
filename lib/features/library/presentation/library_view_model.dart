import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:muzia/features/library/data/directory_service.dart';
import 'package:muzia/features/library/data/file_picker_service.dart';
import 'package:muzia/features/library/data/file_scanner_service.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';

enum LibraryStatus { empty, loading, ready, readyWithWarnings, error }

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    FilePickerService? picker,
    FileScannerService? scanner,
    DirectoryService? directoryService,
    MusicRepository? repository,
  }) : _picker = picker ?? NativeFilePickerService(),
       _scanner = scanner ?? LocalFileScannerService(),
       _directoryService = directoryService ?? NativeDirectoryService(),
       _repository = repository ?? InMemoryMusicRepository();

  LibraryViewModel.persistent({
    FilePickerService? picker,
    FileScannerService? scanner,
    DirectoryService? directoryService,
  }) : this(
         picker: picker,
         scanner: scanner,
         directoryService: directoryService,
         repository: LazyPersistentMusicRepository(),
       );

  final FilePickerService _picker;
  final FileScannerService _scanner;
  final DirectoryService _directoryService;
  final MusicRepository _repository;
  LibraryStatus _status = LibraryStatus.empty;
  List<Track> _tracks = const [];
  String? _errorMessage;
  String? _warningMessage;
  bool _initialized = false;

  LibraryStatus get status => _status;
  List<Track> get tracks => List.unmodifiable(_tracks);
  String? get registeredFolder => _repository.registeredFolder;
  String? get errorMessage => _errorMessage;
  String? get warningMessage => _warningMessage;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _status = LibraryStatus.loading;
    _warningMessage = null;
    notifyListeners();
    try {
      await _repository.load();
      _tracks = _repository.tracks;
      _status = _tracks.isEmpty ? LibraryStatus.empty : LibraryStatus.ready;
      notifyListeners();
    } on Object {
      _setError('ライブラリの読み込みに失敗しました。');
    }
  }

  Future<void> chooseAndScanFolder() async {
    final selectedPath = await _picker.pickDirectory();
    if (selectedPath == null) return;
    await registerAndScan(selectedPath);
  }

  Future<void> registerAndScan(String path) async {
    final validationError = await _validateDirectory(path);
    if (validationError != null) {
      _setError(validationError);
      return;
    }
    if (p.equals(path, _repository.registeredFolder ?? '')) {
      _setError('このフォルダはすでに登録されています。');
      return;
    }

    _status = LibraryStatus.loading;
    _errorMessage = null;
    _warningMessage = null;
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
        _setError('音楽ファイルのメタデータを解析できませんでした。');
        return;
      } else if (metadataIssueCount > 0) {
        _status = LibraryStatus.readyWithWarnings;
        _warningMessage = '$metadataIssueCount件の音楽ファイルを解析できませんでした。';
      } else {
        _status = LibraryStatus.ready;
      }
      await _repository.registerFolder(path, tracks);
      notifyListeners();
    } on FolderAccessException {
      _setError('フォルダにアクセスできません。権限を確認してください。');
    } on Object {
      _setError('フォルダのスキャンに失敗しました。');
    }
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
      _warningMessage = null;
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
}
