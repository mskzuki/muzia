import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/playback/data/playback_settings_store.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';

void main() {
  const track = Track(
    filePath: '/tmp/song.mp3',
    fileExtension: '.mp3',
    title: 'Neon Hours',
    artist: 'Midnight Arcade',
    durationMs: 238000,
  );
  const second = Track(
    filePath: '/tmp/second.mp3',
    fileExtension: '.mp3',
    title: 'Coastlines',
  );
  const third = Track(
    filePath: '/tmp/third.mp3',
    fileExtension: '.mp3',
    title: 'Paper Crowns',
  );
  const queue = [track, second, third];

  test('再生と一時停止を状態へ反映する', () async {
    final service = FakeAudioPlayerService();
    final viewModel = PlayerViewModel(service: service);

    await viewModel.play(track);
    expect(viewModel.status, PlaybackStatus.playing);
    expect(viewModel.track, track);
    expect(service.playingPath, track.filePath);
    await viewModel.togglePause();
    expect(viewModel.status, PlaybackStatus.paused);
    await viewModel.togglePause();
    expect(viewModel.status, PlaybackStatus.playing);
    viewModel.dispose();
  });

  test('再生失敗時は原因を表示用状態へ保持する', () async {
    final viewModel = PlayerViewModel(
      service: FakeAudioPlayerService(playError: 'デコードに失敗しました。'),
    );

    await viewModel.play(track);
    expect(viewModel.status, PlaybackStatus.error);
    expect(viewModel.errorMessage, 'デコードに失敗しました。');
    viewModel.dispose();
  });

  group('再生位置', () {
    test('サービスの位置と総時間を購読して反映する', () async {
      final service = FakeAudioPlayerService();
      final viewModel = PlayerViewModel(service: service);
      var notified = 0;
      viewModel.addListener(() => notified++);

      await viewModel.play(track);
      // 総時間が未取得の間はメタデータの再生時間を使う。
      expect(viewModel.duration, const Duration(milliseconds: 238000));
      service.emitDuration(const Duration(seconds: 240));
      service.emitPosition(const Duration(seconds: 42));
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.duration, const Duration(seconds: 240));
      expect(viewModel.position, const Duration(seconds: 42));
      expect(notified, greaterThanOrEqualTo(4));
      viewModel.dispose();
    });

    test('シークするとサービスへ位置を渡し、表示位置も更新する', () async {
      final service = FakeAudioPlayerService();
      final viewModel = PlayerViewModel(service: service);
      await viewModel.play(track);

      await viewModel.seek(const Duration(seconds: 90));

      expect(service.seekedTo, const Duration(seconds: 90));
      expect(viewModel.position, const Duration(seconds: 90));
      viewModel.dispose();
    });

    test('曲を切り替えると位置は0に戻る', () async {
      final service = FakeAudioPlayerService();
      final viewModel = PlayerViewModel(service: service);
      await viewModel.play(track);
      service.emitPosition(const Duration(seconds: 42));
      await Future<void>.delayed(Duration.zero);

      await viewModel.play(second);

      expect(viewModel.position, Duration.zero);
      viewModel.dispose();
    });
  });

  group('暗黙のキュー', () {
    test('再生開始時の一覧順で次の曲・前の曲へ移動できる', () async {
      final service = FakeAudioPlayerService();
      final viewModel = PlayerViewModel(service: service);

      await viewModel.play(track, queue: queue);
      expect(viewModel.canSkipPrevious, isFalse);
      expect(viewModel.canSkipNext, isTrue);

      await viewModel.next();
      expect(viewModel.track, second);
      expect(service.playingPath, second.filePath);
      expect(viewModel.canSkipPrevious, isTrue);

      await viewModel.next();
      expect(viewModel.track, third);
      expect(viewModel.canSkipNext, isFalse);

      await viewModel.previous();
      expect(viewModel.track, second);
      viewModel.dispose();
    });

    test('キューなしで再生した曲は前後スキップできない', () async {
      final viewModel = PlayerViewModel(service: FakeAudioPlayerService());
      await viewModel.play(track);
      expect(viewModel.canSkipPrevious, isFalse);
      expect(viewModel.canSkipNext, isFalse);
      viewModel.dispose();
    });

    test('前の曲は再生位置が3秒を超えていれば先頭へ戻す', () async {
      final service = FakeAudioPlayerService();
      final viewModel = PlayerViewModel(service: service);
      await viewModel.play(second, queue: queue);
      service.emitPosition(const Duration(seconds: 10));
      await Future<void>.delayed(Duration.zero);

      await viewModel.previous();

      expect(viewModel.track, second);
      expect(service.seekedTo, Duration.zero);
      expect(viewModel.position, Duration.zero);
      viewModel.dispose();
    });

    test('利用不可・削除済みの楽曲はキューから除く', () async {
      final service = FakeAudioPlayerService();
      final viewModel = PlayerViewModel(service: service);
      const missing = Track(
        filePath: '/tmp/missing.mp3',
        fileExtension: '.mp3',
        isAvailable: false,
      );
      const removed = Track(
        filePath: '/tmp/removed.mp3',
        fileExtension: '.mp3',
        isRemoved: true,
      );

      await viewModel.play(track, queue: [track, missing, removed, second]);
      await viewModel.next();

      expect(viewModel.track, second);
      viewModel.dispose();
    });

    test('曲の終端に達したら次の曲を自動再生する', () async {
      final service = FakeAudioPlayerService();
      final viewModel = PlayerViewModel(service: service);
      await viewModel.play(track, queue: queue);

      service.emitCompleted();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.track, second);
      expect(viewModel.status, PlaybackStatus.playing);
      expect(service.playCount, 2);
      viewModel.dispose();
    });

    test('末尾の曲が終わったら停止し、再生で先頭から再開する', () async {
      final service = FakeAudioPlayerService();
      final viewModel = PlayerViewModel(service: service);
      await viewModel.play(third, queue: queue);
      service.emitPosition(const Duration(seconds: 200));
      await Future<void>.delayed(Duration.zero);

      service.emitCompleted();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.track, third);
      expect(viewModel.status, PlaybackStatus.paused);
      expect(viewModel.position, Duration.zero);
      expect(service.playCount, 1);

      await viewModel.togglePause();
      expect(viewModel.status, PlaybackStatus.playing);
      expect(service.playCount, 2);
      viewModel.dispose();
    });
  });

  group('音量', () {
    test('音量を変更するとサービスへ反映し、確定時に保存する', () async {
      final service = FakeAudioPlayerService();
      final store = InMemoryPlaybackSettingsStore();
      final viewModel = PlayerViewModel(service: service, settingsStore: store);

      await viewModel.setVolume(0.4, persist: false);
      expect(viewModel.volume, 0.4);
      expect(service.volume, 0.4);
      expect(store.volume, isNull);

      await viewModel.setVolume(0.3);
      expect(store.volume, 0.3);
      viewModel.dispose();
    });

    test('初期化時に保存済みの音量を復元する', () async {
      final service = FakeAudioPlayerService();
      final store = InMemoryPlaybackSettingsStore(volume: 0.25);
      final viewModel = PlayerViewModel(service: service, settingsStore: store);
      expect(viewModel.volume, 1.0);

      await viewModel.initialize();

      expect(viewModel.volume, 0.25);
      expect(service.volume, 0.25);
      viewModel.dispose();
    });

    test('音量は0〜1に丸める', () async {
      final viewModel = PlayerViewModel(service: FakeAudioPlayerService());
      await viewModel.setVolume(1.5, persist: false);
      expect(viewModel.volume, 1.0);
      await viewModel.setVolume(-1, persist: false);
      expect(viewModel.volume, 0.0);
      viewModel.dispose();
    });
  });
}
