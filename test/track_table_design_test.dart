import 'package:flutter/foundation.dart';
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
    durationMs: 238000,
  ),
  Track(
    filePath: '/tmp/b.mp3',
    fileExtension: '.mp3',
    title: 'Coastlines',
    artist: 'Hollow Coast',
    album: 'Tidewater',
    durationMs: 261000,
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
  bool reduceMotion = true,
}) async {
  // 再生中行のイコライザは無限ループのため、既定では Reduce Motion で静止させて
  // pumpAndSettle が完了するようにする。
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  final library = await _libraryWithTracks();
  await tester.pumpWidget(
    MuziaApp(libraryViewModel: library, playerViewModel: player),
  );
  if (reduceMotion) {
    await tester.pumpAndSettle();
  } else {
    // イコライザが動いている間は settle しないため、数フレームだけ進める。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }
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
    // 「アーティスト」「アルバム」はサイドバー項目にもあるため、ヘッダセルに限定する
    for (final (field, label) in [('artist', 'アーティスト'), ('album', 'アルバム')]) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey('sort-$field')),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
    expect(find.text('時間'), findsOneWidget);
    // 時間列は m:ss、未取得は「—」
    expect(find.text('3:58'), findsOneWidget);
    expect(find.text('4:21'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);

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
    expect(find.text('1 曲を選択中'), findsNothing);

    await _metaTap(tester, find.text('Coastlines'));
    expect(find.text('2 曲を選択中'), findsOneWidget);
    expect(find.text('一括編集'), findsOneWidget);
    // 選択バーは高さ44px固定
    expect(
      tester.getSize(find.byKey(const ValueKey('selection-bar'))).height,
      44,
    );

    // 修飾キーなしのクリックで単一選択に戻る
    await tester.tap(find.text('Paper Crowns'));
    await tester.pump();
    expect(find.text('2 曲を選択中'), findsNothing);
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
    expect(find.text(_editShortcut), findsOneWidget);
    expect(find.text('ライブラリから削除…'), findsOneWidget);
    // 各項目の先頭アイコン（プレイヤーバーの再生アイコンと区別するためメニュー内に限定）
    Finder menuIcon(IconData icon) => find.descendant(
      of: find.byType(PopupMenuItem<String>),
      matching: find.byIcon(icon),
    );
    expect(menuIcon(Icons.play_arrow), findsOneWidget);
    expect(menuIcon(Icons.edit_outlined), findsOneWidget);
    expect(menuIcon(Icons.close), findsOneWidget);

    await tester.tap(find.text('曲を編集…'));
    await tester.pumpAndSettle();
    expect(find.text('曲を編集'), findsOneWidget);
  });

  testWidgets('各行のケバブ（⋮）からもコンテキストメニューを開ける', (tester) async {
    await _pumpApp(tester);

    expect(find.byIcon(Icons.more_vert), findsNWidgets(3));
    await tester.tap(find.byKey(const ValueKey('track-kebab-1')));
    await tester.pumpAndSettle();

    expect(find.text('曲を再生'), findsOneWidget);
    await tester.tap(find.text('曲を編集…'));
    await tester.pumpAndSettle();
    // ケバブの行（Coastlines）が編集対象になる
    expect(find.text('曲を編集'), findsOneWidget);
    expect(find.text('Coastlines — Tidewater'), findsOneWidget);
  });

  testWidgets('コンテキストメニューから削除確認を表示する', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Neon Hours'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ライブラリから削除…'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1曲をライブラリから削除しますか？'), findsOneWidget);
  });

  testWidgets('再生中の行タイトルをアクセント色で表示し、#セルをイコライザにする', (tester) async {
    final player = PlayerViewModel(service: FakeAudioPlayerService());
    await player.play(_tracks[1]);
    await _pumpApp(tester, player: player);

    final colors = MuziaColors.light;
    final title = tester.widgetList<Text>(find.text('Coastlines')).first;
    expect(title.style?.color, colors.accentText);
    expect(find.byKey(const ValueKey('now-playing-equalizer')), findsOneWidget);
    // 再生中の2行目は番号を出さない
    Finder numberIn(int row, String text) => find.descendant(
      of: find.byKey(ValueKey('track-row-$row')),
      matching: find.text(text),
    );
    expect(numberIn(0, '1'), findsOneWidget);
    expect(numberIn(1, '2'), findsNothing);
    expect(numberIn(2, '3'), findsOneWidget);
  });

  testWidgets('イコライザは再生中だけ動き、一時停止で止まる', (tester) async {
    final player = PlayerViewModel(service: FakeAudioPlayerService());
    await player.play(_tracks[1]);
    await _pumpApp(tester, player: player, reduceMotion: false);

    final bars = find.descendant(
      of: find.byKey(const ValueKey('now-playing-equalizer')),
      matching: find.byType(Container),
    );
    double firstBarHeight() => tester.getSize(bars.first).height;
    final before = firstBarHeight();
    await tester.pump(const Duration(milliseconds: 150));
    expect(firstBarHeight(), isNot(before));

    await player.togglePause();
    await tester.pump();
    final paused = firstBarHeight();
    await tester.pump(const Duration(milliseconds: 150));
    expect(firstBarHeight(), paused);
  });

  testWidgets('ヘッダクリックで列ソートし、再クリックで降順になる', (tester) async {
    await _pumpApp(tester);

    double rowY(String title) => tester.getTopLeft(find.text(title)).dy;
    // 登録順: Neon Hours, Coastlines, Paper Crowns
    expect(rowY('Neon Hours'), lessThan(rowY('Coastlines')));

    await tester.tap(find.byKey(const ValueKey('sort-title')));
    await tester.pump();
    expect(rowY('Coastlines'), lessThan(rowY('Neon Hours')));
    expect(rowY('Neon Hours'), lessThan(rowY('Paper Crowns')));
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sort-title')));
    await tester.pump();
    expect(rowY('Paper Crowns'), lessThan(rowY('Neon Hours')));
    expect(rowY('Neon Hours'), lessThan(rowY('Coastlines')));
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

    // 時間列: 未取得（—）は末尾
    await tester.tap(find.byKey(const ValueKey('sort-duration')));
    await tester.pump();
    expect(rowY('Neon Hours'), lessThan(rowY('Coastlines')));
    expect(rowY('Coastlines'), lessThan(rowY('Paper Crowns')));
  });

  testWidgets('行を選択して⌘I（Ctrl+I）で曲編集ダイアログを開く', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Neon Hours'));
    await tester.pump();
    await tester.sendKeyDownEvent(_editModifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.sendKeyUpEvent(_editModifier);
    await tester.pumpAndSettle();

    expect(find.text('曲を編集'), findsOneWidget);
    expect(find.text('Black or White — Dangerous'), findsNothing);
  });
}

final bool _isMac = defaultTargetPlatform == TargetPlatform.macOS;
final String _editShortcut = _isMac ? '⌘I' : 'Ctrl+I';
final LogicalKeyboardKey _editModifier = _isMac
    ? LogicalKeyboardKey.metaLeft
    : LogicalKeyboardKey.controlLeft;
