import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/data/library_database.dart' hide Track;
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';

void main() {
  test('登録フォルダと楽曲メタデータを保存して復元する', () async {
    final database = LibraryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);
    const track = Track(
      filePath: '/tmp/song.mp3',
      fileExtension: '.mp3',
      title: 'Song',
      artist: 'Artist',
      album: 'Album',
      releaseInfo: '2024',
    );

    await repository.registerFolder('/tmp/music', const [track]);
    await repository.updateMetadata('/tmp/song.mp3', title: 'Edited song');
    await repository.markRemoved('/tmp/song.mp3', true);
    final restored = PersistentMusicRepository(database);
    await restored.load();

    expect(restored.registeredFolder, '/tmp/music');
    expect(restored.tracks.single.title, 'Edited song');
    expect(restored.tracks.single.isRemoved, isTrue);
  });

  test('新しいフォルダの登録時に以前の楽曲を置き換える', () async {
    final database = LibraryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);
    const first = Track(filePath: '/tmp/first.mp3', fileExtension: '.mp3');
    const second = Track(filePath: '/tmp/second.mp3', fileExtension: '.mp3');

    await repository.registerFolder('/tmp/first', const [first]);
    await repository.registerFolder('/tmp/second', const [second]);
    final restored = PersistentMusicRepository(database);
    await restored.load();

    expect(restored.registeredFolder, '/tmp/second');
    expect(restored.tracks, [second]);
  });
}
