import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/data/file_picker_service.dart';
import 'package:muzia/features/library/data/file_scanner_service.dart';
import 'package:muzia/features/library/data/music_repository.dart';
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
  Stream<Track> scan(String directoryPath) async* {
    for (final track in tracks) {
      yield track;
    }
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
}
