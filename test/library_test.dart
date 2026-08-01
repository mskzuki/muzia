import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/data/file_picker_service.dart';
import 'package:muzia/features/library/data/file_scanner_service.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/data/security_scoped_bookmark_service.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';

class _FakePicker implements FilePickerService {
  _FakePicker(this.path);
  final String? path;

  @override
  Future<String?> pickDirectory() async => path;
}

class _FakeScanner implements FileScannerService {
  _FakeScanner(this.tracks);
  final List<Track> tracks;

  @override
  Stream<ScanEvent> scan(String directoryPath) async* {
    for (final track in tracks) {
      yield TrackFound(track);
    }
    yield ScanCompleted(
      candidateCount: tracks.length,
      foundCount: tracks.length,
    );
  }
}

void main() {
  test('登録したフォルダをスキャンして楽曲を保存する', () async {
    final directory = await Directory.systemTemp.createTemp(
      'muzia-library-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final track = Track(
      filePath: '${directory.path}/song.mp3',
      fileExtension: '.mp3',
    );
    final repository = InMemoryMusicRepository();
    final viewModel = LibraryViewModel(
      picker: _FakePicker(directory.path),
      scanner: _FakeScanner([track]),
      repository: repository,
    );

    await viewModel.chooseAndScanFolder();

    expect(viewModel.status, LibraryStatus.ready);
    expect(repository.registeredFolder, directory.path);
    expect(viewModel.tracks, [track]);
  });

  test('存在しないパスは登録しない', () async {
    final repository = InMemoryMusicRepository();
    final viewModel = LibraryViewModel(repository: repository);

    await viewModel.registerAndScan('/path/that/does/not/exist');

    expect(viewModel.status, LibraryStatus.error);
    expect(repository.registeredFolder, isNull);
    expect(viewModel.errorMessage, 'フォルダが見つかりません。');
  });

  test('同じフォルダの重複登録を拒否する', () async {
    final directory = await Directory.systemTemp.createTemp(
      'muzia-library-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final repository = InMemoryMusicRepository();
    final viewModel = LibraryViewModel(
      scanner: _FakeScanner(const []),
      repository: repository,
    );

    await viewModel.registerAndScan(directory.path);
    await viewModel.registerAndScan(directory.path);

    expect(viewModel.status, LibraryStatus.error);
    expect(viewModel.errorMessage, 'このフォルダはすでに登録されています。');
  });

  test('解析エラーを空フォルダと区別する', () async {
    final directory = await Directory.systemTemp.createTemp(
      'muzia-library-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final repository = InMemoryMusicRepository();
    final viewModel = LibraryViewModel(
      scanner: _IssueScanner(),
      repository: repository,
    );

    await viewModel.registerAndScan(directory.path);

    expect(viewModel.status, LibraryStatus.error);
    expect(viewModel.errorMessage, '音楽ファイルのメタデータを解析できませんでした。');
  });

  test('一部の解析エラーは楽曲を表示しながら警告する', () async {
    final directory = await Directory.systemTemp.createTemp(
      'muzia-library-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final repository = InMemoryMusicRepository();
    final viewModel = LibraryViewModel(
      scanner: _PartialIssueScanner(),
      repository: repository,
    );

    await viewModel.registerAndScan(directory.path);

    expect(viewModel.status, LibraryStatus.readyWithWarnings);
    expect(viewModel.tracks, hasLength(1));
    expect(viewModel.warningMessage, '1件の音楽ファイルを解析できませんでした。');
  });

  test('フォルダアクセスエラーを分類する', () async {
    final directory = await Directory.systemTemp.createTemp(
      'muzia-library-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final repository = InMemoryMusicRepository();
    final viewModel = LibraryViewModel(
      scanner: _AccessErrorScanner(),
      repository: repository,
    );

    await viewModel.registerAndScan(directory.path);

    expect(viewModel.status, LibraryStatus.error);
    expect(viewModel.errorMessage, 'フォルダにアクセスできません。権限を確認してください。');
  });

  test('スキャン失敗後は楽曲一覧を永続層の内容へ戻す', () async {
    final directory = await Directory.systemTemp.createTemp(
      'muzia-library-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    const savedTrack = Track(filePath: '/tmp/saved.mp3', fileExtension: '.mp3');
    final repository = InMemoryMusicRepository();
    await repository.registerFolder('/tmp/saved', const [savedTrack]);
    final viewModel = LibraryViewModel(
      scanner: _PartialThenFailScanner(),
      repository: repository,
    );
    await viewModel.initialize();

    await viewModel.registerAndScan(directory.path);

    expect(viewModel.status, LibraryStatus.error);
    expect(viewModel.errorMessage, 'フォルダにアクセスできません。権限を確認してください。');
    expect(viewModel.tracks, [savedTrack]);
    expect(repository.registeredFolder, '/tmp/saved');
  });

  test('解析全件失敗でも楽曲一覧を永続層の内容へ戻す', () async {
    final directory = await Directory.systemTemp.createTemp(
      'muzia-library-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    const savedTrack = Track(filePath: '/tmp/saved.mp3', fileExtension: '.mp3');
    final repository = InMemoryMusicRepository();
    await repository.registerFolder('/tmp/saved', const [savedTrack]);
    final viewModel = LibraryViewModel(
      scanner: _IssueScanner(),
      repository: repository,
    );
    await viewModel.initialize();

    await viewModel.registerAndScan(directory.path);

    expect(viewModel.status, LibraryStatus.error);
    expect(viewModel.tracks, [savedTrack]);
  });

  test('フォルダのアクセス権を復元できない場合も楽曲一覧を表示する', () async {
    const track = Track(filePath: '/tmp/song.mp3', fileExtension: '.mp3');
    final repository = _AccessLostRepository();
    await repository.registerFolder('/tmp/music', const [track]);
    final viewModel = LibraryViewModel(repository: repository);

    await viewModel.initialize();

    expect(viewModel.status, LibraryStatus.readyWithWarnings);
    expect(viewModel.tracks, [track]);
    expect(viewModel.warningTitle, 'フォルダにアクセスできません');
    expect(viewModel.warningMessage, 'フォルダの場所が変わった可能性があります。フォルダを登録し直してください。');
  });

  test('ブックマーク作成に失敗してもエラー表示に留める', () async {
    final directory = await Directory.systemTemp.createTemp(
      'muzia-library-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final repository = InMemoryMusicRepository();
    final viewModel = LibraryViewModel(
      picker: _FakePicker(directory.path),
      scanner: _FakeScanner(const []),
      repository: repository,
      bookmarkService: _ThrowingBookmarkService(),
    );

    await viewModel.chooseAndScanFolder();

    expect(viewModel.status, LibraryStatus.error);
    expect(viewModel.errorMessage, 'フォルダを登録できませんでした。');
    expect(repository.registeredFolder, isNull);
  });

  test('フォルダ選択に失敗してもエラー表示に留める', () async {
    final viewModel = LibraryViewModel(
      picker: _ThrowingPicker(),
      repository: InMemoryMusicRepository(),
    );

    await viewModel.chooseAndScanFolder();

    expect(viewModel.status, LibraryStatus.error);
    expect(viewModel.errorMessage, 'フォルダを登録できませんでした。');
  });

  test('保存失敗後の再保存成功で一覧表示可能な状態へ戻る', () async {
    final directory = await Directory.systemTemp.createTemp(
      'muzia-library-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final track = Track(
      filePath: '${directory.path}/song.mp3',
      fileExtension: '.mp3',
    );
    final repository = _FailOnceMetadataRepository();
    await repository.registerFolder(directory.path, [track]);
    final viewModel = LibraryViewModel(repository: repository);
    await viewModel.initialize();

    final values = const MetadataValues(title: '更新後の曲名');
    expect(await viewModel.updateTrackMetadata(track, values), isFalse);
    expect(viewModel.status, LibraryStatus.error);

    expect(await viewModel.updateTrackMetadata(track, values), isTrue);
    expect(viewModel.status, LibraryStatus.ready);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.tracks.single.title, '更新後の曲名');
  });
}

/// 楽曲は読み込めるが、フォルダのアクセス権を復元できなかったリポジトリ。
class _AccessLostRepository extends InMemoryMusicRepository {
  @override
  bool get folderAccessLost => true;
}

class _ThrowingPicker implements FilePickerService {
  @override
  Future<String?> pickDirectory() async => throw StateError('picker failed');
}

class _ThrowingBookmarkService implements SecurityScopedBookmarkService {
  @override
  Future<Uint8List?> createBookmark(String path) async =>
      throw StateError('createBookmark failed');

  @override
  Future<RestoredSecurityScopedBookmark?> restoreBookmark(
    Uint8List bookmark,
  ) async => throw StateError('restoreBookmark failed');
}

class _FailOnceMetadataRepository extends InMemoryMusicRepository {
  var _shouldFail = true;

  @override
  Future<void> updateMetadataMany(
    List<String> filePaths,
    MetadataValues values,
  ) async {
    if (_shouldFail) {
      _shouldFail = false;
      throw StateError('保存失敗');
    }
    await super.updateMetadataMany(filePaths, values);
  }
}

class _IssueScanner implements FileScannerService {
  @override
  Stream<ScanEvent> scan(String directoryPath) async* {
    yield ScanIssueEvent(kind: ScanIssueKind.metadata, filePath: 'broken.mp3');
    yield ScanCompleted(candidateCount: 1, foundCount: 0);
  }
}

class _PartialIssueScanner implements FileScannerService {
  @override
  Stream<ScanEvent> scan(String directoryPath) async* {
    yield const TrackFound(Track(filePath: 'valid.mp3', fileExtension: '.mp3'));
    yield ScanIssueEvent(kind: ScanIssueKind.metadata, filePath: 'broken.mp3');
    yield ScanCompleted(candidateCount: 2, foundCount: 1);
  }
}

/// 途中まで楽曲を返してから失敗するスキャン。
class _PartialThenFailScanner implements FileScannerService {
  @override
  Stream<ScanEvent> scan(String directoryPath) async* {
    yield const TrackFound(
      Track(filePath: '/tmp/partial.mp3', fileExtension: '.mp3'),
    );
    throw FolderAccessException(
      const FileSystemException('permission denied'),
      StackTrace.current,
    );
  }
}

class _AccessErrorScanner implements FileScannerService {
  @override
  Stream<ScanEvent> scan(String directoryPath) async* {
    throw FolderAccessException(
      const FileSystemException('permission denied'),
      StackTrace.current,
    );
  }
}
