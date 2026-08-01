import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:muzia/features/library/data/library_database.dart' hide Track;
import 'package:muzia/features/library/data/security_scoped_bookmark_service.dart';

abstract interface class MusicRepository {
  Future<void> load();
  String? get registeredFolder;
  List<Track> get tracks;

  /// 直近の [load] で、保存済みフォルダへのアクセス権を復元できなかったかどうか。
  /// 楽曲一覧の読み込み自体は成功しているため、エラーではなく警告として扱う。
  bool get folderAccessLost;
  Future<void> registerFolder(
    String path,
    List<Track> tracks, {
    Uint8List? securityScopedBookmark,
  });
  Future<void> updateMetadata(
    String filePath, {
    required MetadataValues values,
  });
  Future<void> updateMetadataMany(
    List<String> filePaths,
    MetadataValues values,
  );
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
  bool get folderAccessLost => false;

  @override
  Future<void> registerFolder(
    String path,
    List<Track> tracks, {
    Uint8List? securityScopedBookmark,
  }) async {
    _registeredFolder = path;
    _tracks = List.unmodifiable(tracks);
  }

  @override
  Future<void> updateMetadata(
    String filePath, {
    required MetadataValues values,
  }) async => updateMetadataMany([filePath], values);

  @override
  Future<void> updateMetadataMany(
    List<String> filePaths,
    MetadataValues values,
  ) async {
    _tracks = _tracks
        .map(
          (track) => filePaths.contains(track.filePath)
              ? track.replaceMetadata(values)
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
  PersistentMusicRepository(
    this._database, {
    SecurityScopedBookmarkService? bookmarkService,
  }) : _bookmarkService =
           bookmarkService ?? NativeSecurityScopedBookmarkService();

  final LibraryDatabase _database;
  final SecurityScopedBookmarkService _bookmarkService;
  String? _registeredFolder;
  List<Track> _tracks = const [];
  bool _folderAccessLost = false;

  static Future<PersistentMusicRepository> open({
    SecurityScopedBookmarkService? bookmarkService,
  }) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final databaseDirectory = Directory(supportDirectory.path);
    await databaseDirectory.create(recursive: true);
    final database = LibraryDatabase(
      NativeDatabase(File(p.join(databaseDirectory.path, 'muzia.sqlite'))),
    );
    return PersistentMusicRepository(
      database,
      bookmarkService: bookmarkService,
    );
  }

  @override
  String? get registeredFolder => _registeredFolder;

  @override
  List<Track> get tracks => List.unmodifiable(_tracks);

  @override
  bool get folderAccessLost => _folderAccessLost;

  @override
  Future<void> load() async {
    _folderAccessLost = false;
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
    var folderPath = folder.path;
    if (folder.securityScopedBookmark != null) {
      // フォルダのアクセス権を復元できなくても、保存済みの楽曲一覧は表示できる。
      // 失敗は警告として呼び出し元へ伝え、読み込み自体は続行する。
      final restored = await _restoreBookmark(folder.securityScopedBookmark!);
      if (restored == null) {
        _folderAccessLost = true;
      } else {
        folderPath = restored.path;
        if (folderPath != folder.path ||
            restored.bookmark != folder.securityScopedBookmark) {
          await (_database.update(
            _database.libraryFolders,
          )..where((table) => table.id.equals(folder.id))).write(
            LibraryFoldersCompanion(
              path: Value(folderPath),
              securityScopedBookmark: Value(restored.bookmark),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
        }
      }
    }
    _registeredFolder = folderPath;
    _tracks = List.unmodifiable(loaded);
  }

  /// [SecurityScopedBookmarkService] は失敗を `null` で返す契約だが、
  /// 差し替え可能な依存であるため、契約に反する例外でも読み込みを止めない。
  Future<RestoredSecurityScopedBookmark?> _restoreBookmark(
    Uint8List bookmark,
  ) async {
    try {
      return await _bookmarkService.restoreBookmark(bookmark);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> registerFolder(
    String path,
    List<Track> tracks, {
    Uint8List? securityScopedBookmark,
  }) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      await _database.delete(_database.trackSourceMetadata).go();
      await _database.delete(_database.tracks).go();
      await (_database.update(
        _database.libraryFolders,
      )).write(const LibraryFoldersCompanion(isActive: Value(false)));
      final folderId = await _database
          .into(_database.libraryFolders)
          .insert(
            LibraryFoldersCompanion.insert(
              path: path,
              securityScopedBookmark: Value(securityScopedBookmark),
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
        await _database
            .into(_database.trackSourceMetadata)
            .insert(
              TrackSourceMetadataCompanion.insert(
                trackId: Value(trackId),
                title: Value(track.title),
                artist: Value(track.artist),
                album: Value(track.album),
                releaseInfo: Value(track.releaseInfo),
                readAt: now,
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
    required MetadataValues values,
  }) async => updateMetadataMany([filePath], values);

  @override
  Future<void> updateMetadataMany(
    List<String> filePaths,
    MetadataValues values,
  ) async {
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      for (final filePath in filePaths) {
        final row = await (_database.select(
          _database.tracks,
        )..where((table) => table.filePath.equals(filePath))).getSingle();
        await (_database.update(
          _database.trackMetadata,
        )..where((table) => table.trackId.equals(row.id))).write(
          TrackMetadataCompanion(
            title: _column(values, MetadataField.title),
            artist: _column(values, MetadataField.artist),
            album: _column(values, MetadataField.album),
            releaseInfo: _column(values, MetadataField.releaseInfo),
            updatedAt: Value(now),
          ),
        );
      }
    });
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

/// 更新対象の項目だけを `UPDATE` に含める。対象外は [Value.absent] とし、
/// 既存の値をそのまま残す。
Value<String?> _column(MetadataValues values, MetadataField field) =>
    values.changes(field) ? Value(values.valueOf(field)) : const Value.absent();

class LazyPersistentMusicRepository implements MusicRepository {
  LazyPersistentMusicRepository({this._bookmarkService});

  final SecurityScopedBookmarkService? _bookmarkService;
  PersistentMusicRepository? _delegate;

  Future<PersistentMusicRepository> _open() async {
    return _delegate ??= await PersistentMusicRepository.open(
      bookmarkService: _bookmarkService,
    );
  }

  @override
  Future<void> load() async => (await _open()).load();

  @override
  String? get registeredFolder => _delegate?.registeredFolder;

  @override
  List<Track> get tracks => _delegate?.tracks ?? const [];

  @override
  bool get folderAccessLost => _delegate?.folderAccessLost ?? false;

  @override
  Future<void> registerFolder(
    String path,
    List<Track> tracks, {
    Uint8List? securityScopedBookmark,
  }) async => (await _open()).registerFolder(
    path,
    tracks,
    securityScopedBookmark: securityScopedBookmark,
  );

  @override
  Future<void> updateMetadata(
    String filePath, {
    required MetadataValues values,
  }) async => (await _open()).updateMetadata(filePath, values: values);

  @override
  Future<void> updateMetadataMany(
    List<String> filePaths,
    MetadataValues values,
  ) async => (await _open()).updateMetadataMany(filePaths, values);

  @override
  Future<void> markRemoved(String filePath, bool removed) async =>
      (await _open()).markRemoved(filePath, removed);

  @override
  Future<void> markRemovedMany(List<String> filePaths, bool removed) async =>
      (await _open()).markRemovedMany(filePaths, removed);
}
