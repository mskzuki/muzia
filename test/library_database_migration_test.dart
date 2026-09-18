import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/data/library_database.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// スキーマv3（トラック番号・リリース年・ジャンル・再生時間の列が
/// 存在しない時点）のDBファイルを組み立てる。
/// driftはマイグレーション時に `user_version` を参照する。
void _createV3Database(String path) {
  final db = sqlite.sqlite3.open(path);
  db.execute('''
    CREATE TABLE library_folders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      path TEXT NOT NULL UNIQUE,
      security_scoped_bookmark BLOB NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      last_scanned_at INTEGER NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  db.execute('''
    CREATE TABLE tracks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      library_folder_id INTEGER NOT NULL,
      file_path TEXT NOT NULL UNIQUE,
      file_extension TEXT NOT NULL,
      removed_at INTEGER NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  for (final table in ['track_metadata', 'track_source_metadata']) {
    final timeColumn = table == 'track_metadata' ? 'updated_at' : 'read_at';
    db.execute('''
      CREATE TABLE $table (
        track_id INTEGER NOT NULL PRIMARY KEY,
        title TEXT NULL,
        artist TEXT NULL,
        album TEXT NULL,
        release_info TEXT NULL,
        $timeColumn INTEGER NOT NULL
      );
    ''');
  }
  db.execute(
    "INSERT INTO library_folders (id, path, is_active, created_at, updated_at) "
    "VALUES (1, '/tmp/music', 1, 0, 0)",
  );
  final rows = <(int, String, String?)>[
    // 旧スキャン結果の形式（DateTime.toString()）は先頭4桁が年。
    (1, '/tmp/scanned.mp3', '2004-01-01 00:00:00.000'),
    // ユーザーが編集した4桁の年。
    (2, '/tmp/edited.mp3', '2025'),
    // 年として解釈できない自由記述。
    (3, '/tmp/freeform.mp3', 'unknown era'),
    // 未設定。
    (4, '/tmp/empty.mp3', null),
    // タグに年がないファイルを旧実装でスキャンした結果（DateTime(0)由来）。
    (5, '/tmp/zero.mp3', '0000-01-01 00:00:00.000'),
  ];
  for (final (id, filePath, releaseInfo) in rows) {
    db.execute(
      'INSERT INTO tracks '
      '(id, library_folder_id, file_path, file_extension, created_at, updated_at) '
      "VALUES ($id, 1, '$filePath', '.mp3', 0, 0)",
    );
    final releaseInfoSql = releaseInfo == null ? 'NULL' : "'$releaseInfo'";
    db.execute(
      'INSERT INTO track_metadata '
      '(track_id, title, release_info, updated_at) '
      "VALUES ($id, 'Title $id', $releaseInfoSql, 0)",
    );
    db.execute(
      'INSERT INTO track_source_metadata '
      '(track_id, title, release_info, read_at) '
      "VALUES ($id, 'Title $id', $releaseInfoSql, 0)",
    );
  }
  db.execute('PRAGMA user_version = 3');
  db.close();
}

void main() {
  late Directory tempDirectory;
  late File databaseFile;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('muzia-migration-');
    databaseFile = File('${tempDirectory.path}/muzia.sqlite');
    _createV3Database(databaseFile.path);
  });

  tearDown(() => tempDirectory.delete(recursive: true));

  test('v3からのマイグレーションで既存データを失わず新列をnullで読み込む', () async {
    final database = LibraryDatabase(NativeDatabase(databaseFile));
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);

    await repository.load();

    expect(repository.registeredFolder, '/tmp/music');
    expect(repository.tracks, hasLength(5));
    expect(repository.tracks.map((track) => track.title), [
      'Title 1',
      'Title 2',
      'Title 3',
      'Title 4',
      'Title 5',
    ]);
    // release_info は移行後も元の値のまま保持される。
    expect(repository.tracks.map((track) => track.releaseInfo), [
      '2004-01-01 00:00:00.000',
      '2025',
      'unknown era',
      null,
      '0000-01-01 00:00:00.000',
    ]);
    // 旧スキーマに存在しなかった項目はnullとして読み込める。
    for (final track in repository.tracks) {
      expect(track.durationMs, isNull);
      expect(track.trackNumber, isNull);
      expect(track.genre, isNull);
    }
    // v5 で追加した unavailable_since は null = 利用可能として読み込む。
    expect(repository.tracks.every((track) => track.isAvailable), isTrue);
  });

  test('release_infoを年として解釈できる場合だけrelease_yearへ移行する', () async {
    final database = LibraryDatabase(NativeDatabase(databaseFile));
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);

    await repository.load();

    expect(repository.tracks.map((track) => track.releaseYear), [
      2004,
      2025,
      null,
      null,
      // 年0000は年として意味を持たないため移行しない。
      null,
    ]);
    // 元データ（track_source_metadata）にも同じ解釈を適用する。
    final sourceRows = await database
        .select(database.trackSourceMetadata)
        .get();
    expect(sourceRows.map((row) => row.releaseYear), [
      2004,
      2025,
      null,
      null,
      null,
    ]);
  });
}
