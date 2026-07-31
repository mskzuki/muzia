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
  ];

  test('タイトル、アーティスト、アルバムを大文字小文字無視で検索する', () {
    expect(LibrarySearch.filter(tracks, 'NEON').single.filePath, 'one.mp3');
    expect(LibrarySearch.filter(tracks, 'arcade').single.filePath, 'one.mp3');
    expect(LibrarySearch.filter(tracks, 'DRIVE').single.filePath, 'two.mp3');
  });

  test('削除済み楽曲と0件を除外する', () {
    expect(LibrarySearch.filter(tracks, 'removed'), isEmpty);
    expect(LibrarySearch.filter(tracks, 'not found'), isEmpty);
    expect(LibrarySearch.filter(tracks, ''), hasLength(2));
  });
}
