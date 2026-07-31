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
