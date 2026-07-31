import 'package:muzia/features/library/domain/track.dart';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:muzia/features/library/data/library_database.dart' hide Track;

abstract interface class MusicRepository {
  Future<void> load();
  String? get registeredFolder;
  List<Track> get tracks;
  Future<void> registerFolder(String path, List<Track> tracks);
  Future<void> updateMetadata(
    String filePath, {
    String? title,
    String? artist,
    String? album,
    String? releaseInfo,
  });
  Future<void> markRemoved(String filePath, bool removed);
  Future<void> markRemovedMany(List<String> filePaths, bool removed);
}

class InMemoryMusicRepository implements MusicRepository {
  String? _registeredFolder;
  List<Track> _tracks = const [];

  @override
  Future<void> load() async {}

  @override
  String? get registeredFolder => _registeredFolder;

  @override
  List<Track> get tracks => List.unmodifiable(_tracks);

  @override
  Future<void> registerFolder(String path, List<Track> tracks) async {
    _registeredFolder = path;
    _tracks = List.unmodifiable(tracks);
  }

  @override
  Future<void> updateMetadata(
    String filePath, {
    String? title,
    String? artist,
    String? album,
    String? releaseInfo,
  }) async {
    _tracks = _tracks
        .map(
          (track) => track.filePath == filePath
              ? track.copyWith(
                  title: title,
                  artist: artist,
                  album: album,
                  releaseInfo: releaseInfo,
                )
              : track,
        )
        .toList(growable: false);
  }

  @override
  Future<void> markRemoved(String filePath, bool removed) async {
    await markRemovedMany([filePath], removed);
  }

  @override
  Future<void> markRemovedMany(List<String> filePaths, bool removed) async {
    _tracks = _tracks
        .map(
          (track) => filePaths.contains(track.filePath)
              ? track.copyWith(isRemoved: removed)
              : track,
        )
        .toList(growable: false);
  }
}

class PersistentMusicRepository implements MusicRepository {
  PersistentMusicRepository(this._database);

  final LibraryDatabase _database;
  String? _registeredFolder;
  List<Track> _tracks = const [];

  static Future<PersistentMusicRepository> open() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final databaseDirectory = Directory(supportDirectory.path);
    await databaseDirectory.create(recursive: true);
    final database = LibraryDatabase(
      NativeDatabase(File(p.join(databaseDirectory.path, 'muzia.sqlite'))),
    );
    return PersistentMusicRepository(database);
  }

  @override
  String? get registeredFolder => _registeredFolder;

  @override
  List<Track> get tracks => List.unmodifiable(_tracks);

  @override
  Future<void> load() async {
    final folder = await (_database.select(
      _database.libraryFolders,
    )..where((table) => table.isActive.equals(true))).getSingleOrNull();
    if (folder == null) {
      _registeredFolder = null;
      _tracks = const [];
      return;
    }
    final rows = await (_database.select(
      _database.tracks,
    )..where((table) => table.libraryFolderId.equals(folder.id))).get();
    final loaded = <Track>[];
    for (final row in rows) {
      final metadata = await (_database.select(
        _database.trackMetadata,
      )..where((table) => table.trackId.equals(row.id))).getSingleOrNull();
      loaded.add(
        Track(
          filePath: row.filePath,
          fileExtension: row.fileExtension,
          title: metadata?.title,
          artist: metadata?.artist,
          album: metadata?.album,
          releaseInfo: metadata?.releaseInfo,
          isRemoved: row.removedAt != null,
        ),
      );
    }
    _registeredFolder = folder.path;
    _tracks = List.unmodifiable(loaded);
  }

  @override
  Future<void> registerFolder(String path, List<Track> tracks) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await _database.delete(_database.tracks).go();
      await (_database.update(
        _database.libraryFolders,
      )).write(const LibraryFoldersCompanion(isActive: Value(false)));
      final folderId = await _database
          .into(_database.libraryFolders)
          .insert(
            LibraryFoldersCompanion.insert(
              path: path,
              isActive: const Value(true),
              lastScannedAt: Value(now),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
      for (final track in tracks) {
        final trackId = await _database
            .into(_database.tracks)
            .insert(
              TracksCompanion.insert(
                libraryFolderId: folderId,
                filePath: track.filePath,
                fileExtension: track.fileExtension,
                removedAt: Value(track.isRemoved ? now : null),
                createdAt: now,
                updatedAt: now,
              ),
            );
        await _database
            .into(_database.trackMetadata)
            .insert(
              TrackMetadataCompanion.insert(
                trackId: Value(trackId),
                title: Value(track.title),
                artist: Value(track.artist),
                album: Value(track.album),
                releaseInfo: Value(track.releaseInfo),
                updatedAt: now,
              ),
            );
      }
    });
    _registeredFolder = path;
    _tracks = List.unmodifiable(tracks);
  }

  @override
  Future<void> updateMetadata(
    String filePath, {
    String? title,
    String? artist,
    String? album,
    String? releaseInfo,
  }) async {
    final row = await (_database.select(
      _database.tracks,
    )..where((table) => table.filePath.equals(filePath))).getSingle();
    final now = DateTime.now().toUtc();
    await (_database.update(
      _database.trackMetadata,
    )..where((table) => table.trackId.equals(row.id))).write(
      TrackMetadataCompanion(
        title: Value(title),
        artist: Value(artist),
        album: Value(album),
        releaseInfo: Value(releaseInfo),
        updatedAt: Value(now),
      ),
    );
    await load();
  }

  @override
  Future<void> markRemoved(String filePath, bool removed) async {
    await markRemovedMany([filePath], removed);
  }

  @override
  Future<void> markRemovedMany(List<String> filePaths, bool removed) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      for (final filePath in filePaths) {
        await (_database.update(
          _database.tracks,
        )..where((table) => table.filePath.equals(filePath))).write(
          TracksCompanion(
            removedAt: Value(removed ? now : null),
            updatedAt: Value(now),
          ),
        );
      }
    });
    await load();
  }
}

class LazyPersistentMusicRepository implements MusicRepository {
  PersistentMusicRepository? _delegate;

  Future<PersistentMusicRepository> _open() async {
    return _delegate ??= await PersistentMusicRepository.open();
  }

  @override
  Future<void> load() async => (await _open()).load();

  @override
  String? get registeredFolder => _delegate?.registeredFolder;

  @override
  List<Track> get tracks => _delegate?.tracks ?? const [];

  @override
  Future<void> registerFolder(String path, List<Track> tracks) async =>
      (await _open()).registerFolder(path, tracks);

  @override
  Future<void> updateMetadata(
    String filePath, {
    String? title,
    String? artist,
    String? album,
    String? releaseInfo,
  }) async => (await _open()).updateMetadata(
    filePath,
    title: title,
    artist: artist,
    album: album,
    releaseInfo: releaseInfo,
  );

  @override
  Future<void> markRemoved(String filePath, bool removed) async =>
      (await _open()).markRemoved(filePath, removed);

  @override
  Future<void> markRemovedMany(List<String> filePaths, bool removed) async =>
      (await _open()).markRemovedMany(filePaths, removed);
}
