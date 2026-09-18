import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';

void main() {
  const track = Track(
    filePath: '/tmp/song.mp3',
    fileExtension: '.mp3',
    title: 'Song',
    artist: 'Artist',
    album: 'Album',
    releaseInfo: '2024',
    durationMs: 215000,
    trackNumber: 3,
    releaseYear: 2024,
    genre: 'Jazz',
  );

  test('valueOfは数値項目を文字列表現で返す', () {
    expect(track.valueOf(MetadataField.trackNumber), '3');
    expect(track.valueOf(MetadataField.releaseYear), '2024');
    expect(track.valueOf(MetadataField.genre), 'Jazz');
  });

  test('replaceMetadataは対象外の新項目と再生時間を保持する', () {
    final replaced = track.replaceMetadata(
      const MetadataValues.partial(
        fields: {MetadataField.title},
        title: 'Edited',
      ),
    );
    expect(replaced.title, 'Edited');
    expect(replaced.durationMs, 215000);
    expect(replaced.trackNumber, 3);
    expect(replaced.releaseYear, 2024);
    expect(replaced.genre, 'Jazz');
  });

  test('replaceMetadataは対象にした新項目を差し替える', () {
    final replaced = track.replaceMetadata(
      const MetadataValues.partial(
        fields: {
          MetadataField.trackNumber,
          MetadataField.releaseYear,
          MetadataField.genre,
        },
        trackNumber: 5,
        releaseYear: 1999,
        genre: 'Rock',
      ),
    );
    expect(replaced.trackNumber, 5);
    expect(replaced.releaseYear, 1999);
    expect(replaced.genre, 'Rock');
    expect(replaced.title, 'Song');
    expect(replaced.durationMs, 215000);
  });

  test('既定コンストラクタのMetadataValuesは全項目を対象にする', () {
    final replaced = track.replaceMetadata(
      const MetadataValues(title: 'Only title'),
    );
    expect(replaced.title, 'Only title');
    expect(replaced.artist, isNull);
    expect(replaced.trackNumber, isNull);
    expect(replaced.releaseYear, isNull);
    expect(replaced.genre, isNull);
    // 再生時間は編集項目ではないため保持される。
    expect(replaced.durationMs, 215000);
  });

  test('新項目を含めて等価比較する', () {
    expect(track, track.copyWith());
    expect(track == track.copyWith(genre: 'Rock'), isFalse);
    expect(track == track.copyWith(trackNumber: 4), isFalse);
    expect(track == track.copyWith(releaseYear: 2000), isFalse);
    expect(track == track.copyWith(durationMs: 1), isFalse);
    expect(track == track.copyWith(isAvailable: false), isFalse);
    // 利用不可の状態はメタデータ更新で変わらない
    expect(
      track
          .copyWith(isAvailable: false)
          .replaceMetadata(const MetadataValues())
          .isAvailable,
      isFalse,
    );
  });
}
