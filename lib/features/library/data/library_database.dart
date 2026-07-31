import 'package:drift/drift.dart';

part 'library_database.g.dart';

class LibraryFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
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
  BoolColumn get isRemoved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class TrackMetadata extends Table {
  IntColumn get trackId => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get releaseInfo => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

@DriftDatabase(tables: [LibraryFolders, Tracks, TrackMetadata])
class LibraryDatabase extends _$LibraryDatabase {
  LibraryDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());
}
