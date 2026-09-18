import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/playback/data/playback_settings_store.dart';

void main() {
  late Directory tempDir;
  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('muzia-playback-settings');
  });
  tearDown(() => tempDir.delete(recursive: true));

  test('音量を保存し、読み直せる', () async {
    final store = FilePlaybackSettingsStore(directory: () async => tempDir);
    expect(await store.loadVolume(), isNull);

    await store.saveVolume(0.35);

    final reopened = FilePlaybackSettingsStore(directory: () async => tempDir);
    expect(await reopened.loadVolume(), 0.35);
  });

  test('ファイルが壊れていれば既定値（null）を返す', () async {
    await File('${tempDir.path}/playback_settings.json').writeAsString('{oops');
    final store = FilePlaybackSettingsStore(directory: () async => tempDir);
    expect(await store.loadVolume(), isNull);
  });
}
