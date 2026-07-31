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
  );
}
