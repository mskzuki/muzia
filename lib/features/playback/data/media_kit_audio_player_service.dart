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
  Future<void> seek(Duration position) => _player.seek(position);

  /// media_kit の音量は 0〜100。
  @override
  Future<void> setVolume(double volume) =>
      _player.setVolume((volume.clamp(0.0, 1.0) * 100).toDouble());

  @override
  Stream<Duration> get positionStream => _player.stream.position;

  @override
  Stream<Duration> get durationStream => _player.stream.duration;

  /// `completed` は再生開始時に false も流れるため、true のみを通知する。
  @override
  Stream<void> get completedStream =>
      _player.stream.completed.where((completed) => completed);

  @override
  Future<void> dispose() => _player.dispose();
}
