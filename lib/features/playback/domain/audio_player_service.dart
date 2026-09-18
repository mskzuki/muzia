import 'dart:async';

abstract interface class AudioPlayerService {
  Future<void> play(String filePath);
  Future<void> pause();
  Future<void> resume();

  /// 再生位置を移動する。
  Future<void> seek(Duration position);

  /// 音量を設定する（0.0〜1.0）。
  Future<void> setVolume(double volume);

  /// 再生位置の更新。
  Stream<Duration> get positionStream;

  /// 再生中の曲の総時間。取得できた時点で流れる。
  Stream<Duration> get durationStream;

  /// 曲の終端に到達したときに流れる。
  Stream<void> get completedStream;

  Future<void> dispose();
}

class AudioPlaybackException implements Exception {
  const AudioPlaybackException(this.message);
  final String message;
}

class FakeAudioPlayerService implements AudioPlayerService {
  FakeAudioPlayerService({this.playError});
  final String? playError;
  String? playingPath;
  bool isPaused = false;
  int playCount = 0;
  Duration? seekedTo;
  double volume = 1.0;

  final _position = StreamController<Duration>.broadcast();
  final _duration = StreamController<Duration>.broadcast();
  final _completed = StreamController<void>.broadcast();

  void emitPosition(Duration position) => _position.add(position);
  void emitDuration(Duration duration) => _duration.add(duration);
  void emitCompleted() => _completed.add(null);

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
  Future<void> seek(Duration position) async => seekedTo = position;
  @override
  Future<void> setVolume(double volume) async => this.volume = volume;
  @override
  Stream<Duration> get positionStream => _position.stream;
  @override
  Stream<Duration> get durationStream => _duration.stream;
  @override
  Stream<void> get completedStream => _completed.stream;
  @override
  Future<void> dispose() async {
    await _position.close();
    await _duration.close();
    await _completed.close();
  }
}
