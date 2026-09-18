import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/app/app.dart';

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
    artist: 'Hollow Coast',
  );

  Future<LibraryViewModel> libraryWith(List<Track> tracks) async {
    final repository = InMemoryMusicRepository();
    await repository.registerFolder('/tmp/music', tracks);
    final library = LibraryViewModel(repository: repository);
    await library.initialize();
    return library;
  }

  testWidgets('選択した曲をプレイヤー領域に表示し、一時停止できる', (tester) async {
    final player = PlayerViewModel(service: FakeAudioPlayerService());
    await player.play(track);
    await tester.pumpWidget(MuziaApp(playerViewModel: player));
    await tester.pump();

    expect(find.text('Neon Hours'), findsOneWidget);
    expect(find.byTooltip('一時停止'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('playback-toggle')));
    await tester.pump();
    expect(find.byTooltip('再生'), findsOneWidget);
  });

  testWidgets('再生位置と総時間を表示し、シークバーをドラッグするとシークする', (tester) async {
    final service = FakeAudioPlayerService();
    final player = PlayerViewModel(service: service);
    await player.play(track);
    await tester.pumpWidget(MuziaApp(playerViewModel: player));
    service.emitPosition(const Duration(seconds: 42));
    await tester.pump();

    expect(find.text('0:42'), findsOneWidget);
    expect(find.text('3:58'), findsOneWidget);

    final slider = tester.widget<Slider>(
      find.byKey(const ValueKey('playback-seek')),
    );
    expect(slider.onChanged, isNotNull);
    slider.onChangeEnd!(120);
    await tester.pump();
    expect(service.seekedTo, const Duration(seconds: 120));
    expect(find.text('2:00'), findsOneWidget);
  });

  testWidgets('曲が選択されていないときはシークバーと前後ボタンが無効', (tester) async {
    final player = PlayerViewModel(service: FakeAudioPlayerService());
    await tester.pumpWidget(MuziaApp(playerViewModel: player));
    await tester.pump();

    final slider = tester.widget<Slider>(
      find.byKey(const ValueKey('playback-seek')),
    );
    expect(slider.onChanged, isNull);
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('playback-next')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('一覧でダブルクリックした曲は表示中の一覧順で次の曲へ送れる', (tester) async {
    final library = await libraryWith(const [track, second]);
    final player = PlayerViewModel(service: FakeAudioPlayerService());
    await tester.pumpWidget(
      MuziaApp(libraryViewModel: library, playerViewModel: player),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Neon Hours'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Neon Hours'));
    await tester.pump();
    expect(player.track, track);
    expect(find.byTooltip('次の曲'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('playback-previous')))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const ValueKey('playback-next')));
    await tester.pump();
    expect(player.track, second);
    expect(find.text('Coastlines'), findsNWidgets(2)); // 一覧行 + プレイヤー
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('playback-next')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('音量スライダーで音量を変更できる', (tester) async {
    final service = FakeAudioPlayerService();
    final player = PlayerViewModel(service: service);
    await tester.pumpWidget(MuziaApp(playerViewModel: player));
    await tester.pump();

    final slider = tester.widget<Slider>(
      find.byKey(const ValueKey('playback-volume')),
    );
    expect(slider.value, 1.0);
    slider.onChanged!(0.4);
    await tester.pump();
    expect(service.volume, 0.4);
    expect(find.byTooltip('音量'), findsOneWidget);
  });
}
