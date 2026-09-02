import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

const _tracks = [
  Track(
    filePath: '/tmp/a.flac',
    fileExtension: '.flac',
    title: 'Neon Hours',
    artist: 'Midnight Arcade',
    album: 'Parallel Lines',
  ),
  Track(
    filePath: '/tmp/b.mp3',
    fileExtension: '.mp3',
    title: 'Coastlines',
    artist: 'Hollow Coast',
    album: 'Tidewater',
  ),
  Track(
    filePath: '/tmp/c.mp3',
    fileExtension: '.mp3',
    title: 'Paper Crowns',
    artist: 'The Velvet Hours',
    album: 'Slow Burn',
  ),
];

Future<LibraryViewModel> _libraryWithTracks() async {
  final repository = InMemoryMusicRepository();
  await repository.registerFolder('/tmp/music', _tracks);
  final viewModel = LibraryViewModel(repository: repository);
  await viewModel.initialize();
  return viewModel;
}

Future<void> _pumpApp(
  WidgetTester tester, {
  PlayerViewModel? player,
}) async {
  final library = await _libraryWithTracks();
  await tester.pumpWidget(
    MuziaApp(libraryViewModel: library, playerViewModel: player),
  );
  await tester.pumpAndSettle();
}

Future<void> _metaTap(WidgetTester tester, Finder finder) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
  await tester.tap(finder);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
  await tester.pump();
}

void main() {
  testWidgets('テーブルヘッダと30pxの行を表示する', (tester) async {
    await _pumpApp(tester);

    expect(find.text('#'), findsOneWidget);
    expect(find.text('タイトル'), findsOneWidget);
    expect(find.text('アーティスト'), findsOneWidget);
    expect(find.text('アルバム'), findsOneWidget);

    final row = find.byKey(const ValueKey('track-row-0'));
    expect(row, findsOneWidget);
    expect(tester.getSize(row).height, 30);
    // チェックボックスは廃止
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('クリックで単一選択し、⌘クリックで選択を広げると選択バーが出る', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Neon Hours'));
    await tester.pump();
    // 単一選択では選択バーを表示しない
    expect(find.text('1曲を選択中'), findsNothing);

    await _metaTap(tester, find.text('Coastlines'));
    expect(find.text('2曲を選択中'), findsOneWidget);
    expect(find.text('一括編集'), findsOneWidget);

    // 修飾キーなしのクリックで単一選択に戻る
    await tester.tap(find.text('Paper Crowns'));
    await tester.pump();
    expect(find.text('2曲を選択中'), findsNothing);
  });

  testWidgets('ダブルクリックで再生する', (tester) async {
    final service = FakeAudioPlayerService();
    final player = PlayerViewModel(service: service);
    await _pumpApp(tester, player: player);

    final row = find.text('Coastlines');
    await tester.tap(row);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(service.playingPath, '/tmp/b.mp3');
    expect(find.byTooltip('一時停止'), findsOneWidget);
  });

  testWidgets('右クリックでコンテキストメニューを表示し曲を編集できる', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Neon Hours'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();

    expect(find.text('曲を再生'), findsOneWidget);
    expect(find.text('曲を編集…'), findsOneWidget);
    expect(find.text('ライブラリから削除…'), findsOneWidget);

    await tester.tap(find.text('曲を編集…'));
    await tester.pumpAndSettle();
    expect(find.text('曲を編集'), findsOneWidget);
  });

  testWidgets('コンテキストメニューから削除確認を表示する', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Neon Hours'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ライブラリから削除…'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('1曲をライブラリから削除しますか？'),
      findsOneWidget,
    );
  });

  testWidgets('再生中の行タイトルをアクセント色で表示する', (tester) async {
    final player = PlayerViewModel(service: FakeAudioPlayerService());
    await player.play(_tracks[1]);
    await _pumpApp(tester, player: player);

    final colors = MuziaColors.light;
    final title = tester.widgetList<Text>(find.text('Coastlines')).first;
    expect(title.style?.color, colors.accentText);
  });
}
