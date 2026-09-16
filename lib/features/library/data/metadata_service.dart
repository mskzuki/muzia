import 'dart:io';
import 'dart:isolate';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:path/path.dart' as p;

abstract interface class MetadataService {
  Future<Track> read(File file);
}

class AudioMetadataService implements MetadataService {
  @override
  Future<Track> read(File file) => Isolate.run(() => _readMetadata(file.path));
}

/// `audio_metadata_reader`の同期処理をUI Isolateの外で実行する。
/// FileオブジェクトはIsolate間で渡さず、Sendableなパス文字列だけを渡す。
Track _readMetadata(String filePath) {
  final file = File(filePath);
  final value = readMetadata(file, getImage: false);
  return Track(
    filePath: filePath,
    fileExtension: p.extension(filePath).toLowerCase(),
    title: value.title,
    artist: value.artist,
    album: value.album,
    releaseInfo: value.year?.toString(),
    durationMs: value.duration?.inMilliseconds,
    trackNumber: value.trackNumber,
    releaseYear: _releaseYear(value.year),
    genre: _firstGenre(value.genres),
  );
}

/// タグに年がないファイルでもparserは `DateTime(0)` を返すことがある。
/// 年として意味を持たない0以下は未設定として扱う。
int? _releaseYear(DateTime? year) {
  if (year == null || year.year <= 0) return null;
  return year.year;
}

/// ジャンルは単一値として扱うため、タグに複数ある場合は先頭の値を採用する。
String? _firstGenre(List<String> genres) {
  for (final genre in genres) {
    final trimmed = genre.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return null;
}
