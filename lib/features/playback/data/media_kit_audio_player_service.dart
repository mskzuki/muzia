import 'dart:io';

import 'package:media_kit/media_kit.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';

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
