import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/bulk_edit_plan.dart';
import 'package:muzia/features/library/domain/library_catalog.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';

Track _track(String path, {String? album, String? artist = 'Artist'}) =>
    Track(filePath: path, fileExtension: '.mp3', album: album, artist: artist);

void main() {
  final library = [
    _track('/a/1.mp3', album: 'Parallel Lines'),
    _track('/a/2.mp3', album: 'Parallel Lines'),
    _track('/a/3.mp3', album: 'Parallel Lines'),
    _track('/a/4.mp3', album: 'Parallel Lines'),
    _track('/b/1.mp3', album: 'Tidewater'),
    _track('/c/1.mp3', album: 'Removed', artist: 'X').copyWith(isRemoved: true),
    _track('/d/1.mp3', album: null),
  ];
  final catalog = LibraryCatalog(library);

  test('LibraryCatalog.albums は削除済みを除く全アルバム名を返す', () {
    expect(catalog.albums, ['Parallel Lines', 'Tidewater']);
  });

  test('部分選択でチェックなしなら選択曲だけを新アルバムへ分割する', () {
    final plan = planBulkEdit(
      selected: library.sublist(0, 2),
      catalog: catalog,
      request: const BulkEditRequest(album: 'Parallel Lines (Deluxe)'),
    );

    expect(plan.isValid, isTrue);
    expect(plan.targets.map((t) => t.filePath), ['/a/1.mp3', '/a/2.mp3']);
    expect(plan.values.fields, {MetadataField.album});
    expect(plan.values.album, 'Parallel Lines (Deluxe)');
    expect(plan.summary, [
      '選択した 2 曲だけを「Parallel Lines (Deluxe)」へ分割します。'
          '残り 2 曲は「Parallel Lines」のままです。',
    ]);
  });

  test('チェックありなら選択していない収録曲も含めてリネームし、他項目も同じ対象に適用する', () {
    final plan = planBulkEdit(
      selected: library.sublist(0, 2),
      catalog: catalog,
      request: const BulkEditRequest(
        album: 'Parallel Lines (Remastered)',
        releaseYear: 2024,
        includeUnselectedAlbumTracks: true,
      ),
    );

    expect(plan.isValid, isTrue);
    expect(plan.targets.map((t) => t.filePath), [
      '/a/1.mp3',
      '/a/2.mp3',
      '/a/3.mp3',
      '/a/4.mp3',
    ]);
    expect(plan.values.fields, {
      MetadataField.album,
      MetadataField.releaseYear,
    });
    expect(plan.summary, [
      'アルバム「Parallel Lines」の全 4 曲（選択していない 2 曲を含む）を'
          '「Parallel Lines (Remastered)」に変更します。',
      'リリース年を 2024 に変更します（4 曲）。',
    ]);
  });

  test('選択がアルバム全曲と一致すれば単純なリネームになる', () {
    final plan = planBulkEdit(
      selected: library.sublist(0, 4),
      catalog: catalog,
      request: const BulkEditRequest(album: 'PL'),
    );

    expect(plan.targets.length, 4);
    expect(plan.summary, ['アルバム「Parallel Lines」（4 曲）を「PL」に変更します。']);
  });

  test('既存アルバム名への変更は暗黙のマージになるためブロックする', () {
    final plan = planBulkEdit(
      selected: library.sublist(0, 2),
      catalog: catalog,
      request: const BulkEditRequest(album: 'Tidewater'),
    );

    expect(plan.isValid, isFalse);
    expect(plan.error, '「Tidewater」という名前のアルバムが既に存在します。');
  });

  test('複数アルバムにまたがる選択は選択曲だけを対象にする', () {
    final plan = planBulkEdit(
      selected: [library[0], library[4]],
      catalog: catalog,
      request: const BulkEditRequest(
        album: 'Mixed',
        includeUnselectedAlbumTracks: true,
      ),
    );

    expect(plan.targets.length, 2);
    expect(plan.summary, ['選択した 2 曲のアルバム名を「Mixed」に変更します。']);
  });

  test('現在と同じアルバム名は変更扱いにせず、他項目だけを適用する', () {
    final plan = planBulkEdit(
      selected: library.sublist(0, 2),
      catalog: catalog,
      request: const BulkEditRequest(
        album: 'Parallel Lines',
        artist: 'New Artist',
        genre: 'Pop',
      ),
    );

    expect(plan.isValid, isTrue);
    expect(plan.values.fields, {MetadataField.artist, MetadataField.genre});
    expect(plan.values.changes(MetadataField.album), isFalse);
    expect(plan.summary, [
      'アーティストを「New Artist」に変更します（2 曲）。',
      'ジャンルを「Pop」に変更します（2 曲）。',
    ]);
  });

  test('変更する項目がなければエラーになる', () {
    final plan = planBulkEdit(
      selected: library.sublist(0, 2),
      catalog: catalog,
      request: const BulkEditRequest(album: 'Parallel Lines'),
    );

    expect(plan.isValid, isFalse);
    expect(plan.error, '変更する項目を入力してください。');
  });

  test('曲名とトラック番号は更新対象に含めない', () {
    final plan = planBulkEdit(
      selected: library.sublist(0, 1),
      catalog: catalog,
      request: const BulkEditRequest(artist: 'A'),
    );

    expect(plan.values.changes(MetadataField.title), isFalse);
    expect(plan.values.changes(MetadataField.trackNumber), isFalse);
    expect(plan.values.changes(MetadataField.releaseInfo), isFalse);
  });
}
