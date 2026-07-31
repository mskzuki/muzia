import 'dart:async';
import 'dart:io';

import 'package:muzia/features/library/data/metadata_service.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:path/path.dart' as p;

/// アプリが音楽ファイルとして取り込む拡張子。
///
/// メタデータ解析ライブラリの対応形式をそのまま採用すると、動画コンテナ
/// (`.mov` / `.mp4`) も候補になるため、アプリ側で音声形式を明示する。
const supportedAudioFileExtensions = <String>{
  '.mp3',
  '.flac',
  '.m4a',
  '.aac',
  '.wav',
  '.ogg',
  '.oga',
  '.opus',
};

abstract interface class FileScannerService {
  Stream<ScanEvent> scan(String directoryPath);
}

sealed class ScanEvent {
  const ScanEvent();
}

class TrackFound extends ScanEvent {
  const TrackFound(this.track) : super();

  final Track track;
}

enum ScanIssueKind { metadata }

class ScanIssueEvent extends ScanEvent {
  ScanIssueEvent({required this.kind, required this.filePath});

  final ScanIssueKind kind;
  final String filePath;
}

class ScanCompleted extends ScanEvent {
  ScanCompleted({required this.candidateCount, required this.foundCount});

  final int candidateCount;
  final int foundCount;
}

class FolderAccessException implements Exception {
  FolderAccessException(this.cause, this.stackTrace);

  final FileSystemException cause;
  final StackTrace stackTrace;
}

class LocalFileScannerService implements FileScannerService {
  LocalFileScannerService({MetadataService? metadataService})
    : _metadataService = metadataService ?? AudioMetadataService();

  final MetadataService _metadataService;

  @override
  Stream<ScanEvent> scan(String directoryPath) async* {
    final directory = Directory(directoryPath);
    var candidateCount = 0;
    var foundCount = 0;
    try {
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File || !_isSupported(entity.path)) continue;
        candidateCount++;
        try {
          final track = await _metadataService.read(entity);
          foundCount++;
          yield TrackFound(track);
        } on Object {
          yield ScanIssueEvent(
            kind: ScanIssueKind.metadata,
            filePath: entity.path,
          );
        }
      }
    } on FileSystemException catch (error, stackTrace) {
      throw FolderAccessException(error, stackTrace);
    }
    yield ScanCompleted(candidateCount: candidateCount, foundCount: foundCount);
  }

  bool _isSupported(String filePath) {
    return supportedAudioFileExtensions.contains(
      p.extension(filePath).toLowerCase(),
    );
  }
}
