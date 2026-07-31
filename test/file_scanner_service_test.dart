import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/data/file_scanner_service.dart';
import 'package:muzia/features/library/data/metadata_service.dart';
import 'package:muzia/features/library/domain/track.dart';

class _FakeMetadataService implements MetadataService {
  final paths = <String>[];

  @override
  Future<Track> read(File file) async {
    paths.add(file.path);
    return Track(filePath: file.path, fileExtension: '.mp3');
  }
}

void main() {
  test('音声拡張子だけをスキャンし、動画コンテナを除外する', () async {
    final directory = await Directory.systemTemp.createTemp('muzia-scanner-');
    addTearDown(() => directory.delete(recursive: true));
    for (final name in ['song.mp3', 'cover.M4A', 'movie.mp4', 'clip.MOV']) {
      await File('${directory.path}/$name').writeAsString('test');
    }
    final metadataService = _FakeMetadataService();
    final scanner = LocalFileScannerService(metadataService: metadataService);

    final events = await scanner.scan(directory.path).toList();
    final tracks = events.whereType<TrackFound>().map((event) => event.track);

    expect(tracks, hasLength(2));
    expect(metadataService.paths, contains(endsWith('song.mp3')));
    expect(metadataService.paths, contains(endsWith('cover.M4A')));
    expect(metadataService.paths, isNot(contains(endsWith('movie.mp4'))));
    expect(metadataService.paths, isNot(contains(endsWith('clip.MOV'))));
    expect(events.whereType<ScanCompleted>().single.candidateCount, 2);
  });

  test('メタデータ解析に失敗しても後続ファイルを処理し、問題を通知する', () async {
    final directory = await Directory.systemTemp.createTemp('muzia-scanner-');
    addTearDown(() => directory.delete(recursive: true));
    await File('${directory.path}/broken.mp3').writeAsString('broken');
    await File('${directory.path}/valid.mp3').writeAsString('valid');
    final scanner = LocalFileScannerService(
      metadataService: _FailingMetadataService(),
    );

    final events = await scanner.scan(directory.path).toList();

    expect(events.whereType<TrackFound>(), hasLength(1));
    expect(events.whereType<ScanIssueEvent>(), hasLength(1));
    expect(events.whereType<ScanCompleted>().single.foundCount, 1);
  });
}

class _FailingMetadataService implements MetadataService {
  @override
  Future<Track> read(File file) async {
    if (file.path.endsWith('broken.mp3')) {
      throw const FormatException('invalid metadata');
    }
    return Track(filePath: file.path, fileExtension: '.mp3');
  }
}
