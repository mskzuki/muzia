// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_database.dart';

// ignore_for_file: type=lint
class $LibraryFoldersTable extends LibraryFolders
    with TableInfo<$LibraryFoldersTable, LibraryFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _securityScopedBookmarkMeta =
      const VerificationMeta('securityScopedBookmark');
  @override
  late final GeneratedColumn<Uint8List> securityScopedBookmark =
      GeneratedColumn<Uint8List>(
        'security_scoped_bookmark',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastScannedAtMeta = const VerificationMeta(
    'lastScannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastScannedAt =
      GeneratedColumn<DateTime>(
        'last_scanned_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    path,
    securityScopedBookmark,
    isActive,
    lastScannedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('security_scoped_bookmark')) {
      context.handle(
        _securityScopedBookmarkMeta,
        securityScopedBookmark.isAcceptableOrUnknown(
          data['security_scoped_bookmark']!,
          _securityScopedBookmarkMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_scanned_at')) {
      context.handle(
        _lastScannedAtMeta,
        lastScannedAt.isAcceptableOrUnknown(
          data['last_scanned_at']!,
          _lastScannedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      securityScopedBookmark: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}security_scoped_bookmark'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastScannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_scanned_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LibraryFoldersTable createAlias(String alias) {
    return $LibraryFoldersTable(attachedDatabase, alias);
  }
}

class LibraryFolder extends DataClass implements Insertable<LibraryFolder> {
  final int id;
  final String path;
  final Uint8List? securityScopedBookmark;
  final bool isActive;
  final DateTime? lastScannedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LibraryFolder({
    required this.id,
    required this.path,
    this.securityScopedBookmark,
    required this.isActive,
    this.lastScannedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || securityScopedBookmark != null) {
      map['security_scoped_bookmark'] = Variable<Uint8List>(
        securityScopedBookmark,
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastScannedAt != null) {
      map['last_scanned_at'] = Variable<DateTime>(lastScannedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LibraryFoldersCompanion toCompanion(bool nullToAbsent) {
    return LibraryFoldersCompanion(
      id: Value(id),
      path: Value(path),
      securityScopedBookmark: securityScopedBookmark == null && nullToAbsent
          ? const Value.absent()
          : Value(securityScopedBookmark),
      isActive: Value(isActive),
      lastScannedAt: lastScannedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScannedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LibraryFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryFolder(
      id: serializer.fromJson<int>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      securityScopedBookmark: serializer.fromJson<Uint8List?>(
        json['securityScopedBookmark'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastScannedAt: serializer.fromJson<DateTime?>(json['lastScannedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'path': serializer.toJson<String>(path),
      'securityScopedBookmark': serializer.toJson<Uint8List?>(
        securityScopedBookmark,
      ),
      'isActive': serializer.toJson<bool>(isActive),
      'lastScannedAt': serializer.toJson<DateTime?>(lastScannedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LibraryFolder copyWith({
    int? id,
    String? path,
    Value<Uint8List?> securityScopedBookmark = const Value.absent(),
    bool? isActive,
    Value<DateTime?> lastScannedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LibraryFolder(
    id: id ?? this.id,
    path: path ?? this.path,
    securityScopedBookmark: securityScopedBookmark.present
        ? securityScopedBookmark.value
        : this.securityScopedBookmark,
    isActive: isActive ?? this.isActive,
    lastScannedAt: lastScannedAt.present
        ? lastScannedAt.value
        : this.lastScannedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LibraryFolder copyWithCompanion(LibraryFoldersCompanion data) {
    return LibraryFolder(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      securityScopedBookmark: data.securityScopedBookmark.present
          ? data.securityScopedBookmark.value
          : this.securityScopedBookmark,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastScannedAt: data.lastScannedAt.present
          ? data.lastScannedAt.value
          : this.lastScannedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryFolder(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('securityScopedBookmark: $securityScopedBookmark, ')
          ..write('isActive: $isActive, ')
          ..write('lastScannedAt: $lastScannedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    path,
    $driftBlobEquality.hash(securityScopedBookmark),
    isActive,
    lastScannedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryFolder &&
          other.id == this.id &&
          other.path == this.path &&
          $driftBlobEquality.equals(
            other.securityScopedBookmark,
            this.securityScopedBookmark,
          ) &&
          other.isActive == this.isActive &&
          other.lastScannedAt == this.lastScannedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LibraryFoldersCompanion extends UpdateCompanion<LibraryFolder> {
  final Value<int> id;
  final Value<String> path;
  final Value<Uint8List?> securityScopedBookmark;
  final Value<bool> isActive;
  final Value<DateTime?> lastScannedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LibraryFoldersCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.securityScopedBookmark = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastScannedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LibraryFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String path,
    this.securityScopedBookmark = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastScannedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : path = Value(path),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LibraryFolder> custom({
    Expression<int>? id,
    Expression<String>? path,
    Expression<Uint8List>? securityScopedBookmark,
    Expression<bool>? isActive,
    Expression<DateTime>? lastScannedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (securityScopedBookmark != null)
        'security_scoped_bookmark': securityScopedBookmark,
      if (isActive != null) 'is_active': isActive,
      if (lastScannedAt != null) 'last_scanned_at': lastScannedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LibraryFoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? path,
    Value<Uint8List?>? securityScopedBookmark,
    Value<bool>? isActive,
    Value<DateTime?>? lastScannedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LibraryFoldersCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      securityScopedBookmark:
          securityScopedBookmark ?? this.securityScopedBookmark,
      isActive: isActive ?? this.isActive,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (securityScopedBookmark.present) {
      map['security_scoped_bookmark'] = Variable<Uint8List>(
        securityScopedBookmark.value,
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastScannedAt.present) {
      map['last_scanned_at'] = Variable<DateTime>(lastScannedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryFoldersCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('securityScopedBookmark: $securityScopedBookmark, ')
          ..write('isActive: $isActive, ')
          ..write('lastScannedAt: $lastScannedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, Track> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _libraryFolderIdMeta = const VerificationMeta(
    'libraryFolderId',
  );
  @override
  late final GeneratedColumn<int> libraryFolderId = GeneratedColumn<int>(
    'library_folder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fileExtensionMeta = const VerificationMeta(
    'fileExtension',
  );
  @override
  late final GeneratedColumn<String> fileExtension = GeneratedColumn<String>(
    'file_extension',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _removedAtMeta = const VerificationMeta(
    'removedAt',
  );
  @override
  late final GeneratedColumn<DateTime> removedAt = GeneratedColumn<DateTime>(
    'removed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unavailableSinceMeta = const VerificationMeta(
    'unavailableSince',
  );
  @override
  late final GeneratedColumn<DateTime> unavailableSince =
      GeneratedColumn<DateTime>(
        'unavailable_since',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    libraryFolderId,
    filePath,
    fileExtension,
    durationMs,
    removedAt,
    unavailableSince,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Track> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('library_folder_id')) {
      context.handle(
        _libraryFolderIdMeta,
        libraryFolderId.isAcceptableOrUnknown(
          data['library_folder_id']!,
          _libraryFolderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_libraryFolderIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_extension')) {
      context.handle(
        _fileExtensionMeta,
        fileExtension.isAcceptableOrUnknown(
          data['file_extension']!,
          _fileExtensionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileExtensionMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('removed_at')) {
      context.handle(
        _removedAtMeta,
        removedAt.isAcceptableOrUnknown(data['removed_at']!, _removedAtMeta),
      );
    }
    if (data.containsKey('unavailable_since')) {
      context.handle(
        _unavailableSinceMeta,
        unavailableSince.isAcceptableOrUnknown(
          data['unavailable_since']!,
          _unavailableSinceMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Track map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Track(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      libraryFolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}library_folder_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileExtension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_extension'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      removedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}removed_at'],
      ),
      unavailableSince: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unavailable_since'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class Track extends DataClass implements Insertable<Track> {
  final int id;
  final int libraryFolderId;
  final String filePath;
  final String fileExtension;

  /// 再生時間（ミリ秒）。ファイル由来の値で、ユーザーは編集できない。
  final int? durationMs;
  final DateTime? removedAt;

  /// ファイルが見つからなくなった時刻。null なら利用可能。
  final DateTime? unavailableSince;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Track({
    required this.id,
    required this.libraryFolderId,
    required this.filePath,
    required this.fileExtension,
    this.durationMs,
    this.removedAt,
    this.unavailableSince,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['library_folder_id'] = Variable<int>(libraryFolderId);
    map['file_path'] = Variable<String>(filePath);
    map['file_extension'] = Variable<String>(fileExtension);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<DateTime>(removedAt);
    }
    if (!nullToAbsent || unavailableSince != null) {
      map['unavailable_since'] = Variable<DateTime>(unavailableSince);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      libraryFolderId: Value(libraryFolderId),
      filePath: Value(filePath),
      fileExtension: Value(fileExtension),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
      unavailableSince: unavailableSince == null && nullToAbsent
          ? const Value.absent()
          : Value(unavailableSince),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Track.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Track(
      id: serializer.fromJson<int>(json['id']),
      libraryFolderId: serializer.fromJson<int>(json['libraryFolderId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileExtension: serializer.fromJson<String>(json['fileExtension']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      removedAt: serializer.fromJson<DateTime?>(json['removedAt']),
      unavailableSince: serializer.fromJson<DateTime?>(
        json['unavailableSince'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'libraryFolderId': serializer.toJson<int>(libraryFolderId),
      'filePath': serializer.toJson<String>(filePath),
      'fileExtension': serializer.toJson<String>(fileExtension),
      'durationMs': serializer.toJson<int?>(durationMs),
      'removedAt': serializer.toJson<DateTime?>(removedAt),
      'unavailableSince': serializer.toJson<DateTime?>(unavailableSince),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Track copyWith({
    int? id,
    int? libraryFolderId,
    String? filePath,
    String? fileExtension,
    Value<int?> durationMs = const Value.absent(),
    Value<DateTime?> removedAt = const Value.absent(),
    Value<DateTime?> unavailableSince = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Track(
    id: id ?? this.id,
    libraryFolderId: libraryFolderId ?? this.libraryFolderId,
    filePath: filePath ?? this.filePath,
    fileExtension: fileExtension ?? this.fileExtension,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    removedAt: removedAt.present ? removedAt.value : this.removedAt,
    unavailableSince: unavailableSince.present
        ? unavailableSince.value
        : this.unavailableSince,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Track copyWithCompanion(TracksCompanion data) {
    return Track(
      id: data.id.present ? data.id.value : this.id,
      libraryFolderId: data.libraryFolderId.present
          ? data.libraryFolderId.value
          : this.libraryFolderId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileExtension: data.fileExtension.present
          ? data.fileExtension.value
          : this.fileExtension,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
      unavailableSince: data.unavailableSince.present
          ? data.unavailableSince.value
          : this.unavailableSince,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Track(')
          ..write('id: $id, ')
          ..write('libraryFolderId: $libraryFolderId, ')
          ..write('filePath: $filePath, ')
          ..write('fileExtension: $fileExtension, ')
          ..write('durationMs: $durationMs, ')
          ..write('removedAt: $removedAt, ')
          ..write('unavailableSince: $unavailableSince, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    libraryFolderId,
    filePath,
    fileExtension,
    durationMs,
    removedAt,
    unavailableSince,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          other.id == this.id &&
          other.libraryFolderId == this.libraryFolderId &&
          other.filePath == this.filePath &&
          other.fileExtension == this.fileExtension &&
          other.durationMs == this.durationMs &&
          other.removedAt == this.removedAt &&
          other.unavailableSince == this.unavailableSince &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TracksCompanion extends UpdateCompanion<Track> {
  final Value<int> id;
  final Value<int> libraryFolderId;
  final Value<String> filePath;
  final Value<String> fileExtension;
  final Value<int?> durationMs;
  final Value<DateTime?> removedAt;
  final Value<DateTime?> unavailableSince;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.libraryFolderId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileExtension = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.unavailableSince = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TracksCompanion.insert({
    this.id = const Value.absent(),
    required int libraryFolderId,
    required String filePath,
    required String fileExtension,
    this.durationMs = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.unavailableSince = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : libraryFolderId = Value(libraryFolderId),
       filePath = Value(filePath),
       fileExtension = Value(fileExtension),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Track> custom({
    Expression<int>? id,
    Expression<int>? libraryFolderId,
    Expression<String>? filePath,
    Expression<String>? fileExtension,
    Expression<int>? durationMs,
    Expression<DateTime>? removedAt,
    Expression<DateTime>? unavailableSince,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (libraryFolderId != null) 'library_folder_id': libraryFolderId,
      if (filePath != null) 'file_path': filePath,
      if (fileExtension != null) 'file_extension': fileExtension,
      if (durationMs != null) 'duration_ms': durationMs,
      if (removedAt != null) 'removed_at': removedAt,
      if (unavailableSince != null) 'unavailable_since': unavailableSince,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TracksCompanion copyWith({
    Value<int>? id,
    Value<int>? libraryFolderId,
    Value<String>? filePath,
    Value<String>? fileExtension,
    Value<int?>? durationMs,
    Value<DateTime?>? removedAt,
    Value<DateTime?>? unavailableSince,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TracksCompanion(
      id: id ?? this.id,
      libraryFolderId: libraryFolderId ?? this.libraryFolderId,
      filePath: filePath ?? this.filePath,
      fileExtension: fileExtension ?? this.fileExtension,
      durationMs: durationMs ?? this.durationMs,
      removedAt: removedAt ?? this.removedAt,
      unavailableSince: unavailableSince ?? this.unavailableSince,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (libraryFolderId.present) {
      map['library_folder_id'] = Variable<int>(libraryFolderId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileExtension.present) {
      map['file_extension'] = Variable<String>(fileExtension.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<DateTime>(removedAt.value);
    }
    if (unavailableSince.present) {
      map['unavailable_since'] = Variable<DateTime>(unavailableSince.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('libraryFolderId: $libraryFolderId, ')
          ..write('filePath: $filePath, ')
          ..write('fileExtension: $fileExtension, ')
          ..write('durationMs: $durationMs, ')
          ..write('removedAt: $removedAt, ')
          ..write('unavailableSince: $unavailableSince, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TrackMetadataTable extends TrackMetadata
    with TableInfo<$TrackMetadataTable, TrackMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseInfoMeta = const VerificationMeta(
    'releaseInfo',
  );
  @override
  late final GeneratedColumn<String> releaseInfo = GeneratedColumn<String>(
    'release_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseYearMeta = const VerificationMeta(
    'releaseYear',
  );
  @override
  late final GeneratedColumn<int> releaseYear = GeneratedColumn<int>(
    'release_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    title,
    artist,
    album,
    releaseInfo,
    trackNumber,
    releaseYear,
    genre,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('release_info')) {
      context.handle(
        _releaseInfoMeta,
        releaseInfo.isAcceptableOrUnknown(
          data['release_info']!,
          _releaseInfoMeta,
        ),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('release_year')) {
      context.handle(
        _releaseYearMeta,
        releaseYear.isAcceptableOrUnknown(
          data['release_year']!,
          _releaseYearMeta,
        ),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  TrackMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackMetadataData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      releaseInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_info'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      ),
      releaseYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}release_year'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TrackMetadataTable createAlias(String alias) {
    return $TrackMetadataTable(attachedDatabase, alias);
  }
}

class TrackMetadataData extends DataClass
    implements Insertable<TrackMetadataData> {
  final int trackId;
  final String? title;
  final String? artist;
  final String? album;
  final String? releaseInfo;
  final int? trackNumber;
  final int? releaseYear;
  final String? genre;
  final DateTime updatedAt;
  const TrackMetadataData({
    required this.trackId,
    this.title,
    this.artist,
    this.album,
    this.releaseInfo,
    this.trackNumber,
    this.releaseYear,
    this.genre,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<int>(trackId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || releaseInfo != null) {
      map['release_info'] = Variable<String>(releaseInfo);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['track_number'] = Variable<int>(trackNumber);
    }
    if (!nullToAbsent || releaseYear != null) {
      map['release_year'] = Variable<int>(releaseYear);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrackMetadataCompanion toCompanion(bool nullToAbsent) {
    return TrackMetadataCompanion(
      trackId: Value(trackId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      releaseInfo: releaseInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseInfo),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      releaseYear: releaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseYear),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrackMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackMetadataData(
      trackId: serializer.fromJson<int>(json['trackId']),
      title: serializer.fromJson<String?>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      releaseInfo: serializer.fromJson<String?>(json['releaseInfo']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      releaseYear: serializer.fromJson<int?>(json['releaseYear']),
      genre: serializer.fromJson<String?>(json['genre']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<int>(trackId),
      'title': serializer.toJson<String?>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'releaseInfo': serializer.toJson<String?>(releaseInfo),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'releaseYear': serializer.toJson<int?>(releaseYear),
      'genre': serializer.toJson<String?>(genre),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrackMetadataData copyWith({
    int? trackId,
    Value<String?> title = const Value.absent(),
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> releaseInfo = const Value.absent(),
    Value<int?> trackNumber = const Value.absent(),
    Value<int?> releaseYear = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    DateTime? updatedAt,
  }) => TrackMetadataData(
    trackId: trackId ?? this.trackId,
    title: title.present ? title.value : this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    releaseInfo: releaseInfo.present ? releaseInfo.value : this.releaseInfo,
    trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
    releaseYear: releaseYear.present ? releaseYear.value : this.releaseYear,
    genre: genre.present ? genre.value : this.genre,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TrackMetadataData copyWithCompanion(TrackMetadataCompanion data) {
    return TrackMetadataData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      releaseInfo: data.releaseInfo.present
          ? data.releaseInfo.value
          : this.releaseInfo,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      releaseYear: data.releaseYear.present
          ? data.releaseYear.value
          : this.releaseYear,
      genre: data.genre.present ? data.genre.value : this.genre,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackMetadataData(')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('releaseInfo: $releaseInfo, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('genre: $genre, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    title,
    artist,
    album,
    releaseInfo,
    trackNumber,
    releaseYear,
    genre,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackMetadataData &&
          other.trackId == this.trackId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.releaseInfo == this.releaseInfo &&
          other.trackNumber == this.trackNumber &&
          other.releaseYear == this.releaseYear &&
          other.genre == this.genre &&
          other.updatedAt == this.updatedAt);
}

class TrackMetadataCompanion extends UpdateCompanion<TrackMetadataData> {
  final Value<int> trackId;
  final Value<String?> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<String?> releaseInfo;
  final Value<int?> trackNumber;
  final Value<int?> releaseYear;
  final Value<String?> genre;
  final Value<DateTime> updatedAt;
  const TrackMetadataCompanion({
    this.trackId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.releaseInfo = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.genre = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TrackMetadataCompanion.insert({
    this.trackId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.releaseInfo = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.genre = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<TrackMetadataData> custom({
    Expression<int>? trackId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? releaseInfo,
    Expression<int>? trackNumber,
    Expression<int>? releaseYear,
    Expression<String>? genre,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (releaseInfo != null) 'release_info': releaseInfo,
      if (trackNumber != null) 'track_number': trackNumber,
      if (releaseYear != null) 'release_year': releaseYear,
      if (genre != null) 'genre': genre,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TrackMetadataCompanion copyWith({
    Value<int>? trackId,
    Value<String?>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<String?>? releaseInfo,
    Value<int?>? trackNumber,
    Value<int?>? releaseYear,
    Value<String?>? genre,
    Value<DateTime>? updatedAt,
  }) {
    return TrackMetadataCompanion(
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      releaseInfo: releaseInfo ?? this.releaseInfo,
      trackNumber: trackNumber ?? this.trackNumber,
      releaseYear: releaseYear ?? this.releaseYear,
      genre: genre ?? this.genre,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<int>(trackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (releaseInfo.present) {
      map['release_info'] = Variable<String>(releaseInfo.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (releaseYear.present) {
      map['release_year'] = Variable<int>(releaseYear.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackMetadataCompanion(')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('releaseInfo: $releaseInfo, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('genre: $genre, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TrackSourceMetadataTable extends TrackSourceMetadata
    with TableInfo<$TrackSourceMetadataTable, TrackSourceMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackSourceMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseInfoMeta = const VerificationMeta(
    'releaseInfo',
  );
  @override
  late final GeneratedColumn<String> releaseInfo = GeneratedColumn<String>(
    'release_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseYearMeta = const VerificationMeta(
    'releaseYear',
  );
  @override
  late final GeneratedColumn<int> releaseYear = GeneratedColumn<int>(
    'release_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    title,
    artist,
    album,
    releaseInfo,
    trackNumber,
    releaseYear,
    genre,
    readAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_source_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackSourceMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('release_info')) {
      context.handle(
        _releaseInfoMeta,
        releaseInfo.isAcceptableOrUnknown(
          data['release_info']!,
          _releaseInfoMeta,
        ),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('release_year')) {
      context.handle(
        _releaseYearMeta,
        releaseYear.isAcceptableOrUnknown(
          data['release_year']!,
          _releaseYearMeta,
        ),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    } else if (isInserting) {
      context.missing(_readAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  TrackSourceMetadataData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackSourceMetadataData(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      releaseInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_info'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      ),
      releaseYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}release_year'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      )!,
    );
  }

  @override
  $TrackSourceMetadataTable createAlias(String alias) {
    return $TrackSourceMetadataTable(attachedDatabase, alias);
  }
}

class TrackSourceMetadataData extends DataClass
    implements Insertable<TrackSourceMetadataData> {
  final int trackId;
  final String? title;
  final String? artist;
  final String? album;
  final String? releaseInfo;
  final int? trackNumber;
  final int? releaseYear;
  final String? genre;
  final DateTime readAt;
  const TrackSourceMetadataData({
    required this.trackId,
    this.title,
    this.artist,
    this.album,
    this.releaseInfo,
    this.trackNumber,
    this.releaseYear,
    this.genre,
    required this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<int>(trackId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || releaseInfo != null) {
      map['release_info'] = Variable<String>(releaseInfo);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['track_number'] = Variable<int>(trackNumber);
    }
    if (!nullToAbsent || releaseYear != null) {
      map['release_year'] = Variable<int>(releaseYear);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    map['read_at'] = Variable<DateTime>(readAt);
    return map;
  }

  TrackSourceMetadataCompanion toCompanion(bool nullToAbsent) {
    return TrackSourceMetadataCompanion(
      trackId: Value(trackId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      releaseInfo: releaseInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseInfo),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      releaseYear: releaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseYear),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      readAt: Value(readAt),
    );
  }

  factory TrackSourceMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackSourceMetadataData(
      trackId: serializer.fromJson<int>(json['trackId']),
      title: serializer.fromJson<String?>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      releaseInfo: serializer.fromJson<String?>(json['releaseInfo']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      releaseYear: serializer.fromJson<int?>(json['releaseYear']),
      genre: serializer.fromJson<String?>(json['genre']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<int>(trackId),
      'title': serializer.toJson<String?>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'releaseInfo': serializer.toJson<String?>(releaseInfo),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'releaseYear': serializer.toJson<int?>(releaseYear),
      'genre': serializer.toJson<String?>(genre),
      'readAt': serializer.toJson<DateTime>(readAt),
    };
  }

  TrackSourceMetadataData copyWith({
    int? trackId,
    Value<String?> title = const Value.absent(),
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> releaseInfo = const Value.absent(),
    Value<int?> trackNumber = const Value.absent(),
    Value<int?> releaseYear = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    DateTime? readAt,
  }) => TrackSourceMetadataData(
    trackId: trackId ?? this.trackId,
    title: title.present ? title.value : this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    releaseInfo: releaseInfo.present ? releaseInfo.value : this.releaseInfo,
    trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
    releaseYear: releaseYear.present ? releaseYear.value : this.releaseYear,
    genre: genre.present ? genre.value : this.genre,
    readAt: readAt ?? this.readAt,
  );
  TrackSourceMetadataData copyWithCompanion(TrackSourceMetadataCompanion data) {
    return TrackSourceMetadataData(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      releaseInfo: data.releaseInfo.present
          ? data.releaseInfo.value
          : this.releaseInfo,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      releaseYear: data.releaseYear.present
          ? data.releaseYear.value
          : this.releaseYear,
      genre: data.genre.present ? data.genre.value : this.genre,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackSourceMetadataData(')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('releaseInfo: $releaseInfo, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('genre: $genre, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    title,
    artist,
    album,
    releaseInfo,
    trackNumber,
    releaseYear,
    genre,
    readAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackSourceMetadataData &&
          other.trackId == this.trackId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.releaseInfo == this.releaseInfo &&
          other.trackNumber == this.trackNumber &&
          other.releaseYear == this.releaseYear &&
          other.genre == this.genre &&
          other.readAt == this.readAt);
}

class TrackSourceMetadataCompanion
    extends UpdateCompanion<TrackSourceMetadataData> {
  final Value<int> trackId;
  final Value<String?> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<String?> releaseInfo;
  final Value<int?> trackNumber;
  final Value<int?> releaseYear;
  final Value<String?> genre;
  final Value<DateTime> readAt;
  const TrackSourceMetadataCompanion({
    this.trackId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.releaseInfo = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.genre = const Value.absent(),
    this.readAt = const Value.absent(),
  });
  TrackSourceMetadataCompanion.insert({
    this.trackId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.releaseInfo = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.genre = const Value.absent(),
    required DateTime readAt,
  }) : readAt = Value(readAt);
  static Insertable<TrackSourceMetadataData> custom({
    Expression<int>? trackId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? releaseInfo,
    Expression<int>? trackNumber,
    Expression<int>? releaseYear,
    Expression<String>? genre,
    Expression<DateTime>? readAt,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (releaseInfo != null) 'release_info': releaseInfo,
      if (trackNumber != null) 'track_number': trackNumber,
      if (releaseYear != null) 'release_year': releaseYear,
      if (genre != null) 'genre': genre,
      if (readAt != null) 'read_at': readAt,
    });
  }

  TrackSourceMetadataCompanion copyWith({
    Value<int>? trackId,
    Value<String?>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<String?>? releaseInfo,
    Value<int?>? trackNumber,
    Value<int?>? releaseYear,
    Value<String?>? genre,
    Value<DateTime>? readAt,
  }) {
    return TrackSourceMetadataCompanion(
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      releaseInfo: releaseInfo ?? this.releaseInfo,
      trackNumber: trackNumber ?? this.trackNumber,
      releaseYear: releaseYear ?? this.releaseYear,
      genre: genre ?? this.genre,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<int>(trackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (releaseInfo.present) {
      map['release_info'] = Variable<String>(releaseInfo.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (releaseYear.present) {
      map['release_year'] = Variable<int>(releaseYear.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackSourceMetadataCompanion(')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('releaseInfo: $releaseInfo, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('genre: $genre, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$LibraryDatabase extends GeneratedDatabase {
  _$LibraryDatabase(QueryExecutor e) : super(e);
  $LibraryDatabaseManager get managers => $LibraryDatabaseManager(this);
  late final $LibraryFoldersTable libraryFolders = $LibraryFoldersTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $TrackMetadataTable trackMetadata = $TrackMetadataTable(this);
  late final $TrackSourceMetadataTable trackSourceMetadata =
      $TrackSourceMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryFolders,
    tracks,
    trackMetadata,
    trackSourceMetadata,
  ];
}

typedef $$LibraryFoldersTableCreateCompanionBuilder =
    LibraryFoldersCompanion Function({
      Value<int> id,
      required String path,
      Value<Uint8List?> securityScopedBookmark,
      Value<bool> isActive,
      Value<DateTime?> lastScannedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$LibraryFoldersTableUpdateCompanionBuilder =
    LibraryFoldersCompanion Function({
      Value<int> id,
      Value<String> path,
      Value<Uint8List?> securityScopedBookmark,
      Value<bool> isActive,
      Value<DateTime?> lastScannedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$LibraryFoldersTableFilterComposer
    extends Composer<_$LibraryDatabase, $LibraryFoldersTable> {
  $$LibraryFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get securityScopedBookmark => $composableBuilder(
    column: $table.securityScopedBookmark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastScannedAt => $composableBuilder(
    column: $table.lastScannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryFoldersTableOrderingComposer
    extends Composer<_$LibraryDatabase, $LibraryFoldersTable> {
  $$LibraryFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get securityScopedBookmark => $composableBuilder(
    column: $table.securityScopedBookmark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastScannedAt => $composableBuilder(
    column: $table.lastScannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryFoldersTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $LibraryFoldersTable> {
  $$LibraryFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<Uint8List> get securityScopedBookmark => $composableBuilder(
    column: $table.securityScopedBookmark,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastScannedAt => $composableBuilder(
    column: $table.lastScannedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LibraryFoldersTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $LibraryFoldersTable,
          LibraryFolder,
          $$LibraryFoldersTableFilterComposer,
          $$LibraryFoldersTableOrderingComposer,
          $$LibraryFoldersTableAnnotationComposer,
          $$LibraryFoldersTableCreateCompanionBuilder,
          $$LibraryFoldersTableUpdateCompanionBuilder,
          (
            LibraryFolder,
            BaseReferences<
              _$LibraryDatabase,
              $LibraryFoldersTable,
              LibraryFolder
            >,
          ),
          LibraryFolder,
          PrefetchHooks Function()
        > {
  $$LibraryFoldersTableTableManager(
    _$LibraryDatabase db,
    $LibraryFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<Uint8List?> securityScopedBookmark = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastScannedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LibraryFoldersCompanion(
                id: id,
                path: path,
                securityScopedBookmark: securityScopedBookmark,
                isActive: isActive,
                lastScannedAt: lastScannedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String path,
                Value<Uint8List?> securityScopedBookmark = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastScannedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => LibraryFoldersCompanion.insert(
                id: id,
                path: path,
                securityScopedBookmark: securityScopedBookmark,
                isActive: isActive,
                lastScannedAt: lastScannedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $LibraryFoldersTable,
      LibraryFolder,
      $$LibraryFoldersTableFilterComposer,
      $$LibraryFoldersTableOrderingComposer,
      $$LibraryFoldersTableAnnotationComposer,
      $$LibraryFoldersTableCreateCompanionBuilder,
      $$LibraryFoldersTableUpdateCompanionBuilder,
      (
        LibraryFolder,
        BaseReferences<_$LibraryDatabase, $LibraryFoldersTable, LibraryFolder>,
      ),
      LibraryFolder,
      PrefetchHooks Function()
    >;
typedef $$TracksTableCreateCompanionBuilder =
    TracksCompanion Function({
      Value<int> id,
      required int libraryFolderId,
      required String filePath,
      required String fileExtension,
      Value<int?> durationMs,
      Value<DateTime?> removedAt,
      Value<DateTime?> unavailableSince,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$TracksTableUpdateCompanionBuilder =
    TracksCompanion Function({
      Value<int> id,
      Value<int> libraryFolderId,
      Value<String> filePath,
      Value<String> fileExtension,
      Value<int?> durationMs,
      Value<DateTime?> removedAt,
      Value<DateTime?> unavailableSince,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$TracksTableFilterComposer
    extends Composer<_$LibraryDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get libraryFolderId => $composableBuilder(
    column: $table.libraryFolderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unavailableSince => $composableBuilder(
    column: $table.unavailableSince,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TracksTableOrderingComposer
    extends Composer<_$LibraryDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get libraryFolderId => $composableBuilder(
    column: $table.libraryFolderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unavailableSince => $composableBuilder(
    column: $table.unavailableSince,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TracksTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get libraryFolderId => $composableBuilder(
    column: $table.libraryFolderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileExtension => $composableBuilder(
    column: $table.fileExtension,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get unavailableSince => $composableBuilder(
    column: $table.unavailableSince,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TracksTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $TracksTable,
          Track,
          $$TracksTableFilterComposer,
          $$TracksTableOrderingComposer,
          $$TracksTableAnnotationComposer,
          $$TracksTableCreateCompanionBuilder,
          $$TracksTableUpdateCompanionBuilder,
          (Track, BaseReferences<_$LibraryDatabase, $TracksTable, Track>),
          Track,
          PrefetchHooks Function()
        > {
  $$TracksTableTableManager(_$LibraryDatabase db, $TracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> libraryFolderId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> fileExtension = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
                Value<DateTime?> unavailableSince = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TracksCompanion(
                id: id,
                libraryFolderId: libraryFolderId,
                filePath: filePath,
                fileExtension: fileExtension,
                durationMs: durationMs,
                removedAt: removedAt,
                unavailableSince: unavailableSince,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int libraryFolderId,
                required String filePath,
                required String fileExtension,
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
                Value<DateTime?> unavailableSince = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => TracksCompanion.insert(
                id: id,
                libraryFolderId: libraryFolderId,
                filePath: filePath,
                fileExtension: fileExtension,
                durationMs: durationMs,
                removedAt: removedAt,
                unavailableSince: unavailableSince,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TracksTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $TracksTable,
      Track,
      $$TracksTableFilterComposer,
      $$TracksTableOrderingComposer,
      $$TracksTableAnnotationComposer,
      $$TracksTableCreateCompanionBuilder,
      $$TracksTableUpdateCompanionBuilder,
      (Track, BaseReferences<_$LibraryDatabase, $TracksTable, Track>),
      Track,
      PrefetchHooks Function()
    >;
typedef $$TrackMetadataTableCreateCompanionBuilder =
    TrackMetadataCompanion Function({
      Value<int> trackId,
      Value<String?> title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> releaseInfo,
      Value<int?> trackNumber,
      Value<int?> releaseYear,
      Value<String?> genre,
      required DateTime updatedAt,
    });
typedef $$TrackMetadataTableUpdateCompanionBuilder =
    TrackMetadataCompanion Function({
      Value<int> trackId,
      Value<String?> title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> releaseInfo,
      Value<int?> trackNumber,
      Value<int?> releaseYear,
      Value<String?> genre,
      Value<DateTime> updatedAt,
    });

class $$TrackMetadataTableFilterComposer
    extends Composer<_$LibraryDatabase, $TrackMetadataTable> {
  $$TrackMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseInfo => $composableBuilder(
    column: $table.releaseInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackMetadataTableOrderingComposer
    extends Composer<_$LibraryDatabase, $TrackMetadataTable> {
  $$TrackMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseInfo => $composableBuilder(
    column: $table.releaseInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackMetadataTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $TrackMetadataTable> {
  $$TrackMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get releaseInfo => $composableBuilder(
    column: $table.releaseInfo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TrackMetadataTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $TrackMetadataTable,
          TrackMetadataData,
          $$TrackMetadataTableFilterComposer,
          $$TrackMetadataTableOrderingComposer,
          $$TrackMetadataTableAnnotationComposer,
          $$TrackMetadataTableCreateCompanionBuilder,
          $$TrackMetadataTableUpdateCompanionBuilder,
          (
            TrackMetadataData,
            BaseReferences<
              _$LibraryDatabase,
              $TrackMetadataTable,
              TrackMetadataData
            >,
          ),
          TrackMetadataData,
          PrefetchHooks Function()
        > {
  $$TrackMetadataTableTableManager(
    _$LibraryDatabase db,
    $TrackMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> trackId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> releaseInfo = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TrackMetadataCompanion(
                trackId: trackId,
                title: title,
                artist: artist,
                album: album,
                releaseInfo: releaseInfo,
                trackNumber: trackNumber,
                releaseYear: releaseYear,
                genre: genre,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> trackId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> releaseInfo = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                required DateTime updatedAt,
              }) => TrackMetadataCompanion.insert(
                trackId: trackId,
                title: title,
                artist: artist,
                album: album,
                releaseInfo: releaseInfo,
                trackNumber: trackNumber,
                releaseYear: releaseYear,
                genre: genre,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $TrackMetadataTable,
      TrackMetadataData,
      $$TrackMetadataTableFilterComposer,
      $$TrackMetadataTableOrderingComposer,
      $$TrackMetadataTableAnnotationComposer,
      $$TrackMetadataTableCreateCompanionBuilder,
      $$TrackMetadataTableUpdateCompanionBuilder,
      (
        TrackMetadataData,
        BaseReferences<
          _$LibraryDatabase,
          $TrackMetadataTable,
          TrackMetadataData
        >,
      ),
      TrackMetadataData,
      PrefetchHooks Function()
    >;
typedef $$TrackSourceMetadataTableCreateCompanionBuilder =
    TrackSourceMetadataCompanion Function({
      Value<int> trackId,
      Value<String?> title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> releaseInfo,
      Value<int?> trackNumber,
      Value<int?> releaseYear,
      Value<String?> genre,
      required DateTime readAt,
    });
typedef $$TrackSourceMetadataTableUpdateCompanionBuilder =
    TrackSourceMetadataCompanion Function({
      Value<int> trackId,
      Value<String?> title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> releaseInfo,
      Value<int?> trackNumber,
      Value<int?> releaseYear,
      Value<String?> genre,
      Value<DateTime> readAt,
    });

class $$TrackSourceMetadataTableFilterComposer
    extends Composer<_$LibraryDatabase, $TrackSourceMetadataTable> {
  $$TrackSourceMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseInfo => $composableBuilder(
    column: $table.releaseInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackSourceMetadataTableOrderingComposer
    extends Composer<_$LibraryDatabase, $TrackSourceMetadataTable> {
  $$TrackSourceMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseInfo => $composableBuilder(
    column: $table.releaseInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackSourceMetadataTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $TrackSourceMetadataTable> {
  $$TrackSourceMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get releaseInfo => $composableBuilder(
    column: $table.releaseInfo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$TrackSourceMetadataTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $TrackSourceMetadataTable,
          TrackSourceMetadataData,
          $$TrackSourceMetadataTableFilterComposer,
          $$TrackSourceMetadataTableOrderingComposer,
          $$TrackSourceMetadataTableAnnotationComposer,
          $$TrackSourceMetadataTableCreateCompanionBuilder,
          $$TrackSourceMetadataTableUpdateCompanionBuilder,
          (
            TrackSourceMetadataData,
            BaseReferences<
              _$LibraryDatabase,
              $TrackSourceMetadataTable,
              TrackSourceMetadataData
            >,
          ),
          TrackSourceMetadataData,
          PrefetchHooks Function()
        > {
  $$TrackSourceMetadataTableTableManager(
    _$LibraryDatabase db,
    $TrackSourceMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackSourceMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackSourceMetadataTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrackSourceMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> trackId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> releaseInfo = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<DateTime> readAt = const Value.absent(),
              }) => TrackSourceMetadataCompanion(
                trackId: trackId,
                title: title,
                artist: artist,
                album: album,
                releaseInfo: releaseInfo,
                trackNumber: trackNumber,
                releaseYear: releaseYear,
                genre: genre,
                readAt: readAt,
              ),
          createCompanionCallback:
              ({
                Value<int> trackId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> releaseInfo = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                required DateTime readAt,
              }) => TrackSourceMetadataCompanion.insert(
                trackId: trackId,
                title: title,
                artist: artist,
                album: album,
                releaseInfo: releaseInfo,
                trackNumber: trackNumber,
                releaseYear: releaseYear,
                genre: genre,
                readAt: readAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackSourceMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $TrackSourceMetadataTable,
      TrackSourceMetadataData,
      $$TrackSourceMetadataTableFilterComposer,
      $$TrackSourceMetadataTableOrderingComposer,
      $$TrackSourceMetadataTableAnnotationComposer,
      $$TrackSourceMetadataTableCreateCompanionBuilder,
      $$TrackSourceMetadataTableUpdateCompanionBuilder,
      (
        TrackSourceMetadataData,
        BaseReferences<
          _$LibraryDatabase,
          $TrackSourceMetadataTable,
          TrackSourceMetadataData
        >,
      ),
      TrackSourceMetadataData,
      PrefetchHooks Function()
    >;

class $LibraryDatabaseManager {
  final _$LibraryDatabase _db;
  $LibraryDatabaseManager(this._db);
  $$LibraryFoldersTableTableManager get libraryFolders =>
      $$LibraryFoldersTableTableManager(_db, _db.libraryFolders);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$TrackMetadataTableTableManager get trackMetadata =>
      $$TrackMetadataTableTableManager(_db, _db.trackMetadata);
  $$TrackSourceMetadataTableTableManager get trackSourceMetadata =>
      $$TrackSourceMetadataTableTableManager(_db, _db.trackSourceMetadata);
}
