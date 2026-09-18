import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/library_search.dart';
import 'package:muzia/features/library/domain/track.dart';

void main() {
  const tracks = [
    Track(
      filePath: 'one.mp3',
      fileExtension: '.mp3',
      title: 'Neon Hours',
      artist: 'Midnight Arcade',
      album: 'Parallel Lines',
    ),
    Track(
      filePath: 'two.mp3',
      fileExtension: '.mp3',
      title: 'Golden Static',
      artist: 'The Other',
      album: 'Night Drive',
    ),
    Track(
      filePath: 'three.mp3',
      fileExtension: '.mp3',
      title: 'Hidden',
      artist: 'Removed Artist',
      album: 'Hidden',
      isRemoved: true,
    ),
    Track(
      filePath: 'four.mp3',
      fileExtension: '.mp3',
      title: 'Café Noir',
      artist: 'Björk Tribute',
      album: 'Northbound',
    ),
    Track(
      filePath: 'five.mp3',
      fileExtension: '.mp3',
      title: 'Coastlines',
      artist: 'Hollow Coast',
      album: 'Northbound',
    ),
  ];

  test('タイトル、アーティスト、アルバムを大文字小文字無視で検索する', () {
    expect(LibrarySearch.filter(tracks, 'NEON').single.filePath, 'one.mp3');
    expect(LibrarySearch.filter(tracks, 'arcade').single.filePath, 'one.mp3');
    expect(LibrarySearch.filter(tracks, 'DRIVE').single.filePath, 'two.mp3');
  });

  test('削除済み楽曲と0件を除外する', () {
    expect(LibrarySearch.filter(tracks, 'removed'), isEmpty);
    expect(LibrarySearch.filter(tracks, 'not found'), isEmpty);
    expect(LibrarySearch.filter(tracks, ''), hasLength(4));
  });

  test('ダイアクリティカルマークの差を無視する', () {
    expect(LibrarySearch.normalize('Café Björk Ñ'), 'cafe bjork n');
    expect(LibrarySearch.filter(tracks, 'cafe').single.filePath, 'four.mp3');
    expect(LibrarySearch.filter(tracks, 'BJORK').single.filePath, 'four.mp3');
  });

  test('単語の前方一致を部分一致より上位に並べ、部分一致も結果に含める', () {
    // 'coast' は Coastlines / Hollow Coast（前方一致）。'line' は Coastlines と
    // Parallel Lines（単語前方一致）。
    final byLine = LibrarySearch.filter(tracks, 'line');
    expect(byLine.map((t) => t.filePath), ['one.mp3', 'five.mp3']);
    expect(LibrarySearch.matchRank('Parallel Lines', 'line'), 0);
    expect(LibrarySearch.matchRank('Coastlines', 'line'), 1);
    expect(LibrarySearch.matchRank('Coastlines', 'xyz'), isNull);
  });

  test('アルバム / アーティスト / 楽曲にグループ化する', () {
    final results = LibrarySearch.search(tracks, 'north');
    expect(results.albums.single.name, 'Northbound');
    expect(results.albums.single.artist, 'Björk Tribute');
    expect(results.albums.single.trackCount, 2);
    expect(results.artists, isEmpty);
    expect(results.tracks.map((t) => t.filePath), ['four.mp3', 'five.mp3']);
    expect(results.total, 3);

    final byArtist = LibrarySearch.search(tracks, 'hollow');
    expect(byArtist.artists.single.name, 'Hollow Coast');
    expect(byArtist.artists.single.albumCount, 1);
    expect(byArtist.artists.single.trackCount, 1);
    expect(byArtist.albums, isEmpty);

    expect(LibrarySearch.search(tracks, 'zzz').isEmpty, isTrue);
    expect(LibrarySearch.search(tracks, '').tracks, hasLength(4));
  });

  test('ハイライト範囲は元の文字列上のインデックスで返す', () {
    final range = LibrarySearch.matchRange('Northern Line', 'north')!;
    expect((range.start, range.end), (0, 5));
    final accented = LibrarySearch.matchRange('Café Noir', 'CAFE')!;
    expect((accented.start, accented.end), (0, 4));
    expect(LibrarySearch.matchRange('Coastlines', 'line')?.start, 5);
    expect(LibrarySearch.matchRange('Coastlines', ''), isNull);
    expect(LibrarySearch.matchRange(null, 'a'), isNull);
  });
}
