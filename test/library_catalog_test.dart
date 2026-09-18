import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:muzia/features/library/domain/library_catalog.dart';
import 'package:muzia/features/library/presentation/artist_album_browser.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

void main() {
  final tracks = [
    const Track(
      filePath: '1.mp3',
      fileExtension: '.mp3',
      title: 'One',
      artist: 'Beta',
      album: 'B',
    ),
    const Track(
      filePath: '2.mp3',
      fileExtension: '.mp3',
      title: 'Two',
      artist: 'Alpha',
      album: 'A',
    ),
    const Track(
      filePath: '3.mp3',
      fileExtension: '.mp3',
      artist: 'Beta',
      album: 'B',
    ),
    const Track(
      filePath: '4.mp3',
      fileExtension: '.mp3',
      artist: 'Hidden',
      album: 'X',
      isRemoved: true,
    ),
    const Track(
      filePath: '5.mp3',
      fileExtension: '.mp3',
      artist: '',
      album: 'Empty',
    ),
    const Track(filePath: '6.mp3', fileExtension: '.mp3', artist: 'No Album'),
  ];

  test('重複、空欄、削除済み楽曲を除外して並べる', () {
    final catalog = LibraryCatalog(tracks);
    expect(catalog.artists, ['Alpha', 'Beta', 'No Album']);
    expect(catalog.albumsFor('Beta'), ['B']);
  });

  test('既存ジャンル一覧を重複なしで大文字小文字を無視して並べる', () {
    const genreTracks = [
      Track(filePath: 'g1.mp3', fileExtension: '.mp3', genre: 'rock'),
      Track(filePath: 'g2.mp3', fileExtension: '.mp3', genre: 'Jazz'),
      Track(filePath: 'g3.mp3', fileExtension: '.mp3', genre: 'Jazz'),
      Track(filePath: 'g4.mp3', fileExtension: '.mp3', genre: '  '),
      Track(filePath: 'g5.mp3', fileExtension: '.mp3'),
      // 削除済み楽曲のジャンルはサジェストに含めない。
      Track(
        filePath: 'g6.mp3',
        fileExtension: '.mp3',
        genre: 'Ambient',
        isRemoved: true,
      ),
      // アーティスト未設定でもジャンルは対象にする。
      Track(
        filePath: 'g7.mp3',
        fileExtension: '.mp3',
        artist: '',
        genre: 'Classical',
      ),
    ];
    final catalog = LibraryCatalog(genreTracks);
    expect(catalog.genres, ['Classical', 'Jazz', 'rock']);
  });

  test('アーティストとアルバムから楽曲を絞り込む', () {
    final catalog = LibraryCatalog(tracks);
    expect(
      catalog.tracksFor(artist: 'Beta', album: 'B').map((track) => track.title),
      ['One', null],
    );
    expect(catalog.tracksFor(artist: 'Hidden'), isEmpty);
  });

  test('楽曲はアルバム名 → トラック番号（未設定は末尾）→ タイトルの順に並べる', () {
    const ordered = [
      Track(
        filePath: 'a.mp3',
        fileExtension: '.mp3',
        artist: 'X',
        album: 'Second',
        trackNumber: 1,
        title: 'S1',
      ),
      Track(
        filePath: 'b.mp3',
        fileExtension: '.mp3',
        artist: 'X',
        album: 'First',
        trackNumber: 2,
        title: 'F2',
      ),
      Track(
        filePath: 'c.mp3',
        fileExtension: '.mp3',
        artist: 'X',
        album: 'First',
        title: 'F-none',
      ),
      Track(
        filePath: 'd.mp3',
        fileExtension: '.mp3',
        artist: 'X',
        album: 'First',
        trackNumber: 1,
        title: 'F1',
      ),
    ];
    final catalog = LibraryCatalog(ordered);
    expect(catalog.tracksFor(artist: 'X').map((track) => track.title), [
      'F1',
      'F2',
      'F-none',
      'S1',
    ]);
  });

  test('アーティスト / アルバムの集計（件数・代表ジャンル・合計時間・年）', () {
    const summarized = [
      Track(
        filePath: 'a.mp3',
        fileExtension: '.mp3',
        artist: 'X',
        album: 'A',
        genre: 'Rock',
        durationMs: 60000,
        releaseYear: 2020,
      ),
      Track(
        filePath: 'b.mp3',
        fileExtension: '.mp3',
        artist: 'X',
        album: 'A',
        genre: 'Rock',
        durationMs: 90000,
        releaseYear: 2020,
      ),
      Track(
        filePath: 'c.mp3',
        fileExtension: '.mp3',
        artist: 'X',
        album: 'B',
        genre: 'Jazz',
        durationMs: null,
        releaseYear: 2021,
      ),
      Track(
        filePath: 'd.mp3',
        fileExtension: '.mp3',
        artist: 'Y',
        album: 'A',
        genre: 'Pop',
      ),
    ];
    final catalog = LibraryCatalog(summarized);
    final artist = catalog.artistSummary('X');
    expect(artist.albumCount, 2);
    expect(artist.trackCount, 3);
    expect(artist.genre, 'Rock');
    expect(artist.totalDurationMs, 150000);

    final album = catalog.albumSummary('A', artist: 'X');
    expect(album.trackCount, 2);
    expect(album.releaseYear, 2020);
    expect(album.totalDurationMs, 150000);
    // アーティスト未指定なら収録曲の最多アーティスト
    expect(catalog.albumSummary('A').artist, 'X');
    expect(catalog.albumSummary('A').trackCount, 3);
  });

  testWidgets('アーティスト、アルバム、楽曲を順に表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MuziaTheme.light(),
        home: Scaffold(body: ArtistAlbumBrowser(tracks: tracks)),
      ),
    );

    expect(find.text('アーティスト'), findsWidgets);
    expect(find.text('Alpha'), findsWidgets);
    await tester.tap(find.text('Beta'));
    await tester.pump();
    // アーティスト選択時点で楽曲セクション（全楽曲）が出る
    expect(find.text('One'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('album-card-B')));
    await tester.pump();
    // アルバム詳細: ヒーロー + トラックリスト
    expect(find.byKey(const ValueKey('album-hero-meta')), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('album-back')));
    await tester.pump();
    expect(find.byKey(const ValueKey('artist-hero-meta')), findsOneWidget);
  });
}
