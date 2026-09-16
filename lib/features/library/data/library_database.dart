import 'package:drift/drift.dart';

part 'library_database.g.dart';

class LibraryFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
  BlobColumn get securityScopedBookmark => blob().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastScannedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get libraryFolderId => integer()();
  TextColumn get filePath => text().unique()();
  TextColumn get fileExtension => text()();

  /// 再生時間（ミリ秒）。ファイル由来の値で、ユーザーは編集できない。
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get removedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class TrackMetadata extends Table {
  IntColumn get trackId => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get releaseInfo => text().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get releaseYear => integer().nullable()();
  TextColumn get genre => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

class TrackSourceMetadata extends Table {
  IntColumn get trackId => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get releaseInfo => text().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get releaseYear => integer().nullable()();
  TextColumn get genre => text().nullable()();
  DateTimeColumn get readAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

@DriftDatabase(
  tables: [LibraryFolders, Tracks, TrackMetadata, TrackSourceMetadata],
)
class LibraryDatabase extends _$LibraryDatabase {
  LibraryDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(trackSourceMetadata);
      if (from < 3) {
        await m.addColumn(
          libraryFolders,
          libraryFolders.securityScopedBookmark,
        );
      }
      if (from < 4) {
        await m.addColumn(tracks, tracks.durationMs);
        await m.addColumn(trackMetadata, trackMetadata.trackNumber);
        await m.addColumn(trackMetadata, trackMetadata.releaseYear);
        await m.addColumn(trackMetadata, trackMetadata.genre);
        await m.addColumn(trackSourceMetadata, trackSourceMetadata.trackNumber);
        await m.addColumn(trackSourceMetadata, trackSourceMetadata.releaseYear);
        await m.addColumn(trackSourceMetadata, trackSourceMetadata.genre);
        // 既存の release_info（自由記述）が先頭4桁の年で始まる場合だけ
        // release_year へ移行する。解釈できない値は年を未設定のまま残し、
        // release_info 自体は変更しない（データを破棄しない）。
        for (final table in ['track_metadata', 'track_source_metadata']) {
          await customStatement('''
            UPDATE $table
            SET release_year = CAST(substr(trim(release_info), 1, 4) AS INTEGER)
            WHERE release_info IS NOT NULL
              AND (trim(release_info) GLOB '[0-9][0-9][0-9][0-9]'
                OR trim(release_info) GLOB '[0-9][0-9][0-9][0-9][^0-9]*')
              AND CAST(substr(trim(release_info), 1, 4) AS INTEGER) > 0
          ''');
        }
      }
    },
  );
}
