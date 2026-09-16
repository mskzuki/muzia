import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/data/metadata_service.dart';

void main() {
  test('メタデータ解析の失敗を呼び出し元へ伝播する', () async {
    final file = File(
      '${Directory.systemTemp.path}/muzia-invalid-metadata.mp3',
    );
    await file.writeAsString('not an mp3');
    addTearDown(() => file.delete());

    expect(() => AudioMetadataService().read(file), throwsA(isA<Object>()));
  });

  test('タグから再生時間・トラック番号・年・ジャンルを取り込む', () async {
    final track = await AudioMetadataService().read(
      File('test/fixtures/tagged.mp3'),
    );

    expect(track.title, 'Tagged Song');
    expect(track.artist, 'Tagged Artist');
    expect(track.album, 'Tagged Album');
    expect(track.trackNumber, 7);
    expect(track.releaseYear, 2021);
    expect(track.genre, 'Rock');
    // 1秒の無音ファイル。MP3の再生時間は推定値のため幅を持たせる。
    expect(track.durationMs, isNotNull);
    expect(track.durationMs, inInclusiveRange(500, 2000));
  });

  test('タグにない項目はnullとして読み込む', () async {
    final track = await AudioMetadataService().read(
      File('test/fixtures/untagged.mp3'),
    );

    expect(track.trackNumber, isNull);
    expect(track.releaseYear, isNull);
    expect(track.genre, isNull);
  });
}
