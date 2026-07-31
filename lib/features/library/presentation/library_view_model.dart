import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:muzia/features/library/data/file_picker_service.dart';
import 'package:muzia/features/library/data/file_scanner_service.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';

enum LibraryStatus { empty, loading, ready, error }

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    FilePickerService? picker,
    FileScannerService? scanner,
    MusicRepository? repository,
  }) : _picker = picker ?? NativeFilePickerService(),
       _scanner = scanner ?? LocalFileScannerService(),
       _repository = repository ?? InMemoryMusicRepository();

  LibraryViewModel.persistent({
    FilePickerService? picker,
    FileScannerService? scanner,
  }) : this(
         picker: picker,
         scanner: scanner,
         repository: LazyPersistentMusicRepository(),
       );

  final FilePickerService _picker;
  final FileScannerService _scanner;
  final MusicRepository _repository;
  LibraryStatus _status = LibraryStatus.empty;
  List<Track> _tracks = const [];
  String? _errorMessage;
  bool _initialized = false;

  LibraryStatus get status => _status;
  List<Track> get tracks => List.unmodifiable(_tracks);
  String? get registeredFolder => _repository.registeredFolder;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _status = LibraryStatus.loading;
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
    final validationError = _validateDirectory(path);
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
    notifyListeners();
    try {
      final tracks = <Track>[];
      await for (final track in _scanner.scan(path)) {
        tracks.add(track);
        _tracks = List.unmodifiable(tracks);
        notifyListeners();
      }
      await _repository.registerFolder(path, tracks);
      _status = tracks.isEmpty ? LibraryStatus.empty : LibraryStatus.ready;
      notifyListeners();
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
      notifyListeners();
      return true;
    } on Object {
      _setError('楽曲をライブラリから削除できませんでした。');
      return false;
    }
  }

  String? _validateDirectory(String path) {
    final entity = Directory(path);
    if (path.trim().isEmpty || !entity.existsSync()) return 'フォルダが見つかりません。';
    return null;
  }

  void _setError(String message) {
    _status = LibraryStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
