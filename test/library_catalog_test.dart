import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:muzia/features/library/domain/library_catalog.dart';
import 'package:muzia/features/library/presentation/artist_album_browser.dart';
import 'package:muzia/features/library/domain/track.dart';

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

  test('アーティストとアルバムから楽曲を絞り込む', () {
    final catalog = LibraryCatalog(tracks);
    expect(
      catalog.tracksFor(artist: 'Beta', album: 'B').map((track) => track.title),
      ['One', null],
    );
    expect(catalog.tracksFor(artist: 'Hidden'), isEmpty);
  });

  testWidgets('アーティスト、アルバム、楽曲を順に表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ArtistAlbumBrowser(tracks: tracks)),
      ),
    );

    expect(find.text('アーティスト'), findsWidgets);
    expect(find.text('Alpha'), findsWidgets);
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(find.text('B'), findsWidgets);
    await tester.tap(find.text('B').first);
    await tester.pump();
    expect(find.text('One'), findsOneWidget);
  });
}
