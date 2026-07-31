import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/app/app.dart';

void main() {
  testWidgets('選択した曲をプレイヤー領域に表示し、一時停止できる', (tester) async {
    final player = PlayerViewModel(service: FakeAudioPlayerService());
    const track = Track(
      filePath: '/tmp/song.mp3',
      fileExtension: '.mp3',
      title: 'Neon Hours',
      artist: 'Midnight Arcade',
    );
    await player.play(track);
    await tester.pumpWidget(MuziaApp(playerViewModel: player));
    await tester.pump();

    expect(find.text('Neon Hours'), findsOneWidget);
    expect(find.byTooltip('一時停止'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('playback-toggle')));
    await tester.pump();
    expect(find.byTooltip('再生'), findsOneWidget);
  });
}
