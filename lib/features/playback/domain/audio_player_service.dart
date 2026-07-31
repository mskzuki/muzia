import 'dart:io';

import 'package:media_kit/media_kit.dart';

abstract interface class AudioPlayerService {
  Future<void> play(String filePath);
  Future<void> pause();
  Future<void> resume();
  Future<void> dispose();
}

class AudioPlaybackException implements Exception {
  const AudioPlaybackException(this.message);
  final String message;
}

class MediaKitAudioPlayerService implements AudioPlayerService {
  MediaKitAudioPlayerService() : _player = Player();
  final Player _player;

  @override
  Future<void> play(String filePath) async {
    if (!File(filePath).existsSync()) {
      throw const AudioPlaybackException('音楽ファイルが見つかりません。');
    }
    try {
      await _player.open(Media(filePath));
    } on Object {
      throw const AudioPlaybackException('音楽ファイルを再生できませんでした。');
    }
  }

  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> resume() => _player.play();
  @override
  Future<void> dispose() => _player.dispose();
}

class FakeAudioPlayerService implements AudioPlayerService {
  FakeAudioPlayerService({this.playError});
  final String? playError;
  String? playingPath;
  bool isPaused = false;
  int playCount = 0;

  @override
  Future<void> play(String filePath) async {
    if (playError != null) throw AudioPlaybackException(playError!);
    playingPath = filePath;
    isPaused = false;
    playCount++;
  }

  @override
  Future<void> pause() async => isPaused = true;
  @override
  Future<void> resume() async => isPaused = false;
  @override
  Future<void> dispose() async {}
}
