import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/playback/data/playback_settings_store.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';

enum PlaybackStatus { idle, loading, playing, paused, error }

class PlayerViewModel extends ChangeNotifier {
  PlayerViewModel({
    required this._service,
    PlaybackSettingsStore? settingsStore,
  }) : _settingsStore = settingsStore ?? InMemoryPlaybackSettingsStore() {
    _subscriptions = [
      _service.positionStream.listen(_onPosition),
      _service.durationStream.listen(_onDuration),
      _service.completedStream.listen((_) => unawaited(_onCompleted())),
    ];
  }

  /// 「前の曲」でひとつ前へ戻る代わりに先頭へ戻す再生位置の閾値。
  static const previousRestartThreshold = Duration(seconds: 3);

  final AudioPlayerService _service;
  final PlaybackSettingsStore _settingsStore;
  late final List<StreamSubscription<void>> _subscriptions;
  PlaybackStatus _status = PlaybackStatus.idle;
  Track? _track;
  String? _errorMessage;
  Duration _position = Duration.zero;
  Duration? _serviceDuration;
  double _volume = 1.0;

  /// 再生開始時点の表示中一覧（検索・ソート適用後）を暗黙のキューとする。
  List<Track> _queue = const [];

  /// 末尾の曲が終端に達して停止した状態。次の再生は先頭から開き直す。
  bool _completedAtEnd = false;

  PlaybackStatus get status => _status;
  Track? get track => _track;
  String? get errorMessage => _errorMessage;
  bool get isPlaying => _status == PlaybackStatus.playing;
  Duration get position => _position;
  double get volume => _volume;

  /// 総時間。サービスから取得できるまではメタデータの再生時間を使う。
  Duration get duration {
    final fromService = _serviceDuration;
    if (fromService != null && fromService > Duration.zero) return fromService;
    final ms = _track?.durationMs;
    return ms == null || ms <= 0 ? Duration.zero : Duration(milliseconds: ms);
  }

  int get _queueIndex {
    final current = _track;
    if (current == null) return -1;
    return _queue.indexWhere((item) => item.filePath == current.filePath);
  }

  bool get canSkipPrevious => _queueIndex > 0;
  bool get canSkipNext => _queueIndex >= 0 && _queueIndex < _queue.length - 1;

  /// 保存済みの設定（音量）を復元する。
  Future<void> initialize() async {
    final saved = await _settingsStore.loadVolume();
    if (saved != null) await setVolume(saved, persist: false);
  }

  /// [queue] は再生開始時点の表示中一覧。省略時は前後スキップできない。
  Future<void> play(Track track, {List<Track>? queue}) async {
    _queue = (queue ?? [track])
        .where((item) => !item.isRemoved && item.isAvailable)
        .toList(growable: false);
    await _open(track);
  }

  Future<void> _open(Track track) async {
    _track = track;
    _status = PlaybackStatus.loading;
    _errorMessage = null;
    _position = Duration.zero;
    _serviceDuration = null;
    _completedAtEnd = false;
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
      if (_completedAtEnd) {
        await _open(_track!);
        return;
      }
      await _service.resume();
      _status = PlaybackStatus.playing;
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    if (_track == null) return;
    final clamped = position < Duration.zero
        ? Duration.zero
        : (duration > Duration.zero && position > duration
              ? duration
              : position);
    await _service.seek(clamped);
    _position = clamped;
    notifyListeners();
  }

  Future<void> next() async {
    if (!canSkipNext) return;
    await _open(_queue[_queueIndex + 1]);
  }

  Future<void> previous() async {
    if (_track == null) return;
    if (_position > previousRestartThreshold || !canSkipPrevious) {
      await seek(Duration.zero);
      return;
    }
    await _open(_queue[_queueIndex - 1]);
  }

  /// 音量を 0.0〜1.0 で設定する。ドラッグ中は [persist] を false にし、
  /// 確定時にだけ保存する。
  Future<void> setVolume(double volume, {bool persist = true}) async {
    _volume = volume.clamp(0.0, 1.0);
    await _service.setVolume(_volume);
    notifyListeners();
    if (persist) await _settingsStore.saveVolume(_volume);
  }

  void _onPosition(Duration position) {
    _position = position;
    notifyListeners();
  }

  void _onDuration(Duration duration) {
    _serviceDuration = duration;
    notifyListeners();
  }

  Future<void> _onCompleted() async {
    if (canSkipNext) {
      await next();
      return;
    }
    _completedAtEnd = true;
    _status = PlaybackStatus.paused;
    _position = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _service.dispose();
    super.dispose();
  }
}
