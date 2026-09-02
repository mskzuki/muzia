import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('楽曲を選択して再生・一時停止できる', (tester) async {
    final repository = InMemoryMusicRepository();
    const track = Track(
      filePath: '/tmp/song.mp3',
      fileExtension: '.mp3',
      title: 'Neon Hours',
      artist: 'Midnight Arcade',
    );
    await repository.registerFolder('/tmp/music', const [track]);
    final library = LibraryViewModel(repository: repository);
    await library.initialize();
    final player = PlayerViewModel(service: FakeAudioPlayerService());
    await tester.pumpWidget(
      MuziaApp(libraryViewModel: library, playerViewModel: player),
    );
    await tester.pump(const Duration(milliseconds: 300));
    // デザインハンドオフ準拠: シングルクリックは選択、ダブルクリックで再生。
    await tester.tap(find.text('Neon Hours'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Neon Hours'));
    await tester.pump();
    expect(find.byTooltip('一時停止'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('playback-toggle')));
    await tester.pump();
    expect(find.byTooltip('再生'), findsOneWidget);
  });
}
