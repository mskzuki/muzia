import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:path/path.dart' as p;

abstract interface class MetadataService {
  Future<Track> read(File file);
}

class AudioMetadataService implements MetadataService {
  @override
  Future<Track> read(File file) async {
    final metadata = await Future<Track>(() {
      final value = readMetadata(file, getImage: false);
      return Track(
        filePath: file.path,
        fileExtension: p.extension(file.path).toLowerCase(),
        title: value.title,
        artist: value.artist,
        album: value.album,
        releaseInfo: value.year?.toString(),
      );
    });
    return metadata;
  }
}
