import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/data/file_availability_service.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

class _MissingB implements FileAvailabilityService {
  @override
  Future<bool> exists(String filePath) async => filePath != '/m/b.mp3';
}

const _tracks = [
  Track(
    filePath: '/m/a.mp3',
    fileExtension: '.mp3',
    title: 'Neon Hours',
    artist: 'Midnight Arcade',
    album: 'Parallel Lines',
    durationMs: 238000,
  ),
  Track(
    filePath: '/m/b.mp3',
    fileExtension: '.mp3',
    title: 'Static Bloom',
    artist: 'Cascade Theory',
    album: 'Half-Light',
    durationMs: 303000,
  ),
];

Future<LibraryViewModel> _library() async {
  final repository = InMemoryMusicRepository();
  await repository.registerFolder('/m', _tracks);
  final viewModel = LibraryViewModel(
    repository: repository,
    availabilityService: _MissingB(),
  );
  await viewModel.initialize();
  return viewModel;
}

Future<void> _pump(
  WidgetTester tester,
  LibraryViewModel library, {
  PlayerViewModel? player,
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(
    MuziaApp(libraryViewModel: library, playerViewModel: player),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('欠損ファイルのバナーを件数付きで表示し、✕で閉じられる', (tester) async {
    final library = await _library();
    await _pump(tester, library);

    final banner = find.byKey(const ValueKey('unavailable-banner'));
    expect(banner, findsOneWidget);
    expect(find.text('1曲が利用できません。'), findsOneWidget);
    expect(find.text('ファイルが前回のスキャン以降に移動または削除されました。'), findsOneWidget);
    expect(find.text('削除…'), findsOneWidget);
    // ツールバーの件数にも出る
    expect(find.text('2曲 · 1曲が利用不可'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('unavailable-dismiss')));
    await tester.pumpAndSettle();
    expect(banner, findsNothing);
  });

  testWidgets('該当行は淡色化し「利用不可」フラグと時間「—」を出す', (tester) async {
    final library = await _library();
    await _pump(tester, library);

    final row = find.byKey(const ValueKey('track-row-1'));
    expect(
      find.descendant(of: row, matching: find.text('利用不可')),
      findsOneWidget,
    );
    expect(find.descendant(of: row, matching: find.text('—')), findsOneWidget);
    expect(find.descendant(of: row, matching: find.text('5:03')), findsNothing);
    final title = tester.widget<Text>(
      find.descendant(of: row, matching: find.text('Static Bloom')),
    );
    expect(title.style?.color, MuziaColors.light.fgSecondary);
    final artist = tester.widget<Text>(
      find.descendant(of: row, matching: find.text('Cascade Theory')),
    );
    expect(artist.style?.color, MuziaColors.light.fgTertiary);
    // 利用可能な行には出ない
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('track-row-0')),
        matching: find.text('利用不可'),
      ),
      findsNothing,
    );
  });

  testWidgets('利用不可の行はダブルクリックで再生せず理由を表示する', (tester) async {
    final library = await _library();
    final service = FakeAudioPlayerService();
    await _pump(tester, library, player: PlayerViewModel(service: service));

    final row = find.text('Static Bloom');
    await tester.tap(row);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(row);
    await tester.pump();

    expect(service.playingPath, isNull);
    expect(find.textContaining('ファイルが見つかりません'), findsOneWidget);
  });

  testWidgets('バナーの「削除…」で利用不可の楽曲をライブラリから削除できる', (tester) async {
    final library = await _library();
    await _pump(tester, library);

    await tester.tap(find.byKey(const ValueKey('unavailable-remove')));
    await tester.pumpAndSettle();
    expect(find.textContaining('1曲をライブラリから削除しますか？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'ライブラリから削除'));
    await tester.pumpAndSettle();

    expect(find.text('Static Bloom'), findsNothing);
    expect(find.text('Neon Hours'), findsOneWidget);
    expect(find.byKey(const ValueKey('unavailable-banner')), findsNothing);
  });
}
