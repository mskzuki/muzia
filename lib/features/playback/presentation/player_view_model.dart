import 'package:flutter/foundation.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';

enum PlaybackStatus { idle, loading, playing, paused, error }

class PlayerViewModel extends ChangeNotifier {
  PlayerViewModel({AudioPlayerService? service})
    : _service = service ?? MediaKitAudioPlayerService();
  final AudioPlayerService _service;
  PlaybackStatus _status = PlaybackStatus.idle;
  Track? _track;
  String? _errorMessage;

  PlaybackStatus get status => _status;
  Track? get track => _track;
  String? get errorMessage => _errorMessage;
  bool get isPlaying => _status == PlaybackStatus.playing;

  Future<void> play(Track track) async {
    _track = track;
    _status = PlaybackStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.play(track.filePath);
      _status = PlaybackStatus.playing;
    } on AudioPlaybackException catch (error) {
      _status = PlaybackStatus.error;
      _errorMessage = error.message;
    } on Object {
      _status = PlaybackStatus.error;
      _errorMessage = '音楽ファイルを再生できませんでした。';
    }
    notifyListeners();
  }

  Future<void> togglePause() async {
    if (_status == PlaybackStatus.playing) {
      await _service.pause();
      _status = PlaybackStatus.paused;
    } else if (_status == PlaybackStatus.paused) {
      await _service.resume();
      _status = PlaybackStatus.playing;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
