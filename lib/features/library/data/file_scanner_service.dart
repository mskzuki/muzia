import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:muzia/features/library/data/metadata_service.dart';
import 'package:muzia/features/library/domain/track.dart';

abstract interface class FileScannerService {
  Stream<Track> scan(String directoryPath);
}

class LocalFileScannerService implements FileScannerService {
  LocalFileScannerService({MetadataService? metadataService})
    : _metadataService = metadataService ?? AudioMetadataService();

  final MetadataService _metadataService;

  @override
  Stream<Track> scan(String directoryPath) async* {
    final directory = Directory(directoryPath);
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File || !_isSupported(entity.path)) continue;
      try {
        yield await _metadataService.read(entity);
      } on Object {
        // A corrupt file should not stop the rest of the library scan.
      }
    }
  }

  bool _isSupported(String filePath) {
    final lowerPath = filePath.toLowerCase();
    return supportedFileExtensions.any(lowerPath.endsWith);
  }
}
