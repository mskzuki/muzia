import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';

void main() {
  const track = Track(
    filePath: '/tmp/song.mp3',
    fileExtension: '.mp3',
    title: 'Neon Hours',
    artist: 'Midnight Arcade',
  );

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
}
