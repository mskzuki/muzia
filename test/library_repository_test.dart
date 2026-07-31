import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/data/library_database.dart' hide Track;
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';

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
    await repository.updateMetadata(
      '/tmp/song.mp3',
      values: const MetadataValues(
        title: 'Edited song',
        artist: 'Artist',
        album: 'Album',
        releaseInfo: '2024',
      ),
    );
    await repository.markRemoved('/tmp/song.mp3', true);
    final restored = PersistentMusicRepository(database);
    await restored.load();

    expect(restored.registeredFolder, '/tmp/music');
    expect(restored.tracks.single.title, 'Edited song');
    expect(restored.tracks.single.isRemoved, isTrue);

    final source = await (database.select(
      database.trackSourceMetadata,
    )).getSingle();
    expect(source.title, 'Song');
    expect(source.artist, 'Artist');
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

  test('複数楽曲を論理削除して元データを保持する', () async {
    final database = LibraryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);
    const first = Track(filePath: '/tmp/one.mp3', fileExtension: '.mp3');
    const second = Track(filePath: '/tmp/two.mp3', fileExtension: '.mp3');

    await repository.registerFolder('/tmp/music', const [first, second]);
    await repository.markRemovedMany([first.filePath, second.filePath], true);
    final restored = PersistentMusicRepository(database);
    await restored.load();

    expect(restored.tracks, hasLength(2));
    expect(restored.tracks.every((track) => track.isRemoved), isTrue);
  });

  test('複数楽曲のメタデータを同一更新として保存する', () async {
    final database = LibraryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);
    const first = Track(
      filePath: '/tmp/one.mp3',
      fileExtension: '.mp3',
      title: 'One',
    );
    const second = Track(
      filePath: '/tmp/two.mp3',
      fileExtension: '.mp3',
      title: 'Two',
    );

    await repository.registerFolder('/tmp/music', const [first, second]);
    await repository.updateMetadataMany(
      [first.filePath, second.filePath],
      const MetadataValues.partial(
        fields: {MetadataField.artist, MetadataField.album},
        artist: 'Shared artist',
        album: 'Shared album',
      ),
    );
    final restored = PersistentMusicRepository(database);
    await restored.load();

    expect(restored.tracks.map((track) => track.artist), [
      'Shared artist',
      'Shared artist',
    ]);
    expect(restored.tracks.map((track) => track.album), [
      'Shared album',
      'Shared album',
    ]);
    expect(restored.tracks.map((track) => track.title), ['One', 'Two']);
  });

  test('一括編集で対象にしなかった項目は既存値を保持する', () async {
    final database = LibraryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);
    const track = Track(
      filePath: '/tmp/one.mp3',
      fileExtension: '.mp3',
      title: 'Original title',
      artist: 'Original artist',
      album: 'Original album',
      releaseInfo: '2024',
    );

    await repository.registerFolder('/tmp/music', const [track]);
    // リリース年だけを対象にする。他の3項目は fields に含めない。
    await repository.updateMetadataMany(
      [track.filePath],
      const MetadataValues.partial(
        fields: {MetadataField.releaseInfo},
        releaseInfo: '2025',
      ),
    );
    final restored = PersistentMusicRepository(database);
    await restored.load();

    final saved = restored.tracks.single;
    expect(saved.releaseInfo, '2025');
    expect(saved.title, 'Original title');
    expect(saved.artist, 'Original artist');
    expect(saved.album, 'Original album');
  });

  test('個別編集は4項目すべてを対象とし、空欄はnullとして反映する', () async {
    final database = LibraryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);
    const track = Track(
      filePath: '/tmp/one.mp3',
      fileExtension: '.mp3',
      title: 'Original title',
      artist: 'Original artist',
      album: 'Original album',
      releaseInfo: '2024',
    );

    await repository.registerFolder('/tmp/music', const [track]);
    // 既定コンストラクタは4項目すべてが対象。個別編集フォームの挙動。
    await repository.updateMetadata(
      track.filePath,
      values: const MetadataValues(title: 'New title'),
    );
    final restored = PersistentMusicRepository(database);
    await restored.load();

    final saved = restored.tracks.single;
    expect(saved.title, 'New title');
    expect(saved.artist, isNull);
    expect(saved.album, isNull);
    expect(saved.releaseInfo, isNull);
  });
}
