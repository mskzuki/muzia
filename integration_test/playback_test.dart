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
    artist: 'Hollow Coast',
    durationMs: 200000,
  );

  Future<(LibraryViewModel, PlayerViewModel, FakeAudioPlayerService)> pumpApp(
    WidgetTester tester,
  ) async {
    final repository = InMemoryMusicRepository();
    await repository.registerFolder('/tmp/music', const [track, second]);
    final library = LibraryViewModel(repository: repository);
    await library.initialize();
    final service = FakeAudioPlayerService();
    final player = PlayerViewModel(service: service);
    await tester.pumpWidget(
      MuziaApp(libraryViewModel: library, playerViewModel: player),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return (library, player, service);
  }

  Future<void> doubleClick(WidgetTester tester, String title) async {
    // デザインハンドオフ準拠: シングルクリックは選択、ダブルクリックで再生。
    await tester.tap(find.text(title));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text(title));
    await tester.pump();
  }

  testWidgets('楽曲を選択して再生・一時停止できる', (tester) async {
    await pumpApp(tester);
    await doubleClick(tester, 'Neon Hours');
    expect(find.byTooltip('一時停止'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('playback-toggle')));
    await tester.pump();
    expect(find.byTooltip('再生'), findsOneWidget);
  });

  testWidgets('再生位置を表示し、次の曲へ送れる', (tester) async {
    final (_, player, service) = await pumpApp(tester);
    await doubleClick(tester, 'Neon Hours');

    // 一覧の時間列にも同じ文字列が出るため、プレイヤーバー配下に限定する。
    final playerBar = find.byKey(const ValueKey('player-bar'));
    Finder inPlayer(String text) =>
        find.descendant(of: playerBar, matching: find.text(text));
    service.emitPosition(const Duration(seconds: 42));
    await tester.pump();
    expect(inPlayer('0:42'), findsOneWidget);
    expect(inPlayer('3:58'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('playback-next')));
    await tester.pump();
    expect(player.track, second);
    expect(service.playingPath, second.filePath);
    expect(inPlayer('3:20'), findsOneWidget);

    // 末尾の曲が終わったら停止する。
    service.emitCompleted();
    await tester.pump();
    expect(find.byTooltip('再生'), findsOneWidget);
    expect(player.track, second);
  });

  testWidgets('音量スライダーで音量を変更できる', (tester) async {
    final (_, player, service) = await pumpApp(tester);
    final slider = find.byKey(const ValueKey('playback-volume'));
    final rect = tester.getRect(slider);
    // トラックの中央付近へドラッグ
    await tester.drag(slider, Offset(-rect.width / 2, 0));
    await tester.pump();
    expect(player.volume, lessThan(0.9));
    expect(service.volume, player.volume);
  });
}
