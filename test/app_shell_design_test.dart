import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/data/directory_service.dart';
import 'package:muzia/features/library/data/file_scanner_service.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';

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
];

class _PartialIssueScanner implements FileScannerService {
  @override
  Stream<ScanEvent> scan(String directoryPath) async* {
    yield const TrackFound(
      Track(filePath: 'valid.mp3', fileExtension: '.mp3', title: 'Valid song'),
    );
    yield ScanIssueEvent(kind: ScanIssueKind.metadata, filePath: 'broken.mp3');
    yield ScanCompleted(candidateCount: 2, foundCount: 1);
  }
}

class _AlwaysDirectoryService implements DirectoryService {
  @override
  Future<bool> isDirectory(String path) async => true;
}

Future<LibraryViewModel> _libraryWithTracks() async {
  final repository = InMemoryMusicRepository();
  await repository.registerFolder('/tmp/music', _tracks);
  final viewModel = LibraryViewModel(repository: repository);
  await viewModel.initialize();
  return viewModel;
}

void main() {
  testWidgets('ツールバーにセクション名・曲数・検索フィールドを表示する', (tester) async {
    final library = await _libraryWithTracks();
    await tester.pumpWidget(MuziaApp(libraryViewModel: library));
    await tester.pumpAndSettle();

    expect(find.text('楽曲'), findsWidgets);
    expect(find.text('2曲'), findsOneWidget);
    expect(find.byKey(const ValueKey('library-search')), findsOneWidget);
    // 検索フィールドは 196×26
    expect(
      tester.getSize(find.byKey(const ValueKey('search-field'))),
      const Size(196, 26),
    );
    // タイトルはサイドバー（224px）の右、コンテンツ列の上に置く
    final titleLeft = tester
        .getTopLeft(
          find.descendant(of: find.byType(AppBar), matching: find.text('楽曲')),
        )
        .dx;
    expect(titleLeft, greaterThanOrEqualTo(224));

    final toolbar = tester.widget<AppBar>(find.byType(AppBar));
    expect(toolbar.toolbarHeight, 52);
  });

  testWidgets('サイドバーはアイコンと件数付きの項目を表示する', (tester) async {
    final library = await _libraryWithTracks();
    await tester.pumpWidget(MuziaApp(libraryViewModel: library));
    await tester.pumpAndSettle();

    final sidebar = find.byKey(const ValueKey('sidebar'));
    expect(sidebar, findsOneWidget);
    expect(tester.getSize(sidebar).width, 224);
    expect(
      find.descendant(of: sidebar, matching: find.text('ライブラリ')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sidebar, matching: find.byIcon(Icons.music_note)),
      findsOneWidget,
    );
    // 楽曲 / アーティスト / アルバムの3項目に件数（桁区切り・tabular）
    for (final item in ['library', 'artists', 'albums']) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey('sidebar-item-$item')),
          matching: find.text('2'),
        ),
        findsOneWidget,
        reason: item,
      );
    }
    expect(
      find.descendant(of: sidebar, matching: find.text('アーティスト')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sidebar, matching: find.text('アルバム')),
      findsOneWidget,
    );
    expect(find.text('アーティスト / アルバム'), findsNothing);
    expect(
      find.descendant(of: sidebar, matching: find.text('フォルダを登録')),
      findsOneWidget,
    );
  });

  testWidgets('サイドバーの「アルバム」はアーティスト/アルバムブラウザを開く', (tester) async {
    final library = await _libraryWithTracks();
    await tester.pumpWidget(MuziaApp(libraryViewModel: library));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('sidebar-item-albums')));
    await tester.pumpAndSettle();

    // ツールバーのタイトルが切り替わり、ブラウザ（アーティスト一覧）が表示される
    final toolbar = find.byType(AppBar);
    expect(
      find.descendant(of: toolbar, matching: find.text('アルバム')),
      findsOneWidget,
    );
    expect(find.text('Midnight Arcade'), findsOneWidget);
    expect(find.byKey(const ValueKey('track-row-0')), findsNothing);
  });

  testWidgets('空状態はアクセントのグリフとフォルダ登録ボタンを表示する', (tester) async {
    await tester.pumpWidget(const MuziaApp());
    await tester.pumpAndSettle();

    final empty = find.byKey(const ValueKey('empty-state'));
    expect(empty, findsOneWidget);
    expect(
      find.descendant(of: empty, matching: find.byIcon(Icons.music_note)),
      findsOneWidget,
    );
    expect(find.text('ライブラリは空です'), findsOneWidget);
    // グリフの角丸は radius-5（12px）
    final glyph = tester.widget<Container>(
      find.descendant(of: empty, matching: find.byType(Container)).first,
    );
    expect(
      (glyph.decoration as BoxDecoration).borderRadius,
      BorderRadius.circular(MuziaRadius.r5),
    );
    // 空状態からもフォルダ登録を実行できる（サイドバーと合わせて2箇所）
    expect(
      find.descendant(of: empty, matching: find.text('フォルダを登録')),
      findsOneWidget,
    );
  });

  testWidgets('警告はamberのバナーとして表示する', (tester) async {
    final viewModel = LibraryViewModel(
      scanner: _PartialIssueScanner(),
      directoryService: _AlwaysDirectoryService(),
      repository: InMemoryMusicRepository(),
    );
    await viewModel.initialize();
    await viewModel.registerAndScan('/tmp/music');

    await tester.pumpWidget(MuziaApp(libraryViewModel: viewModel));
    await tester.pumpAndSettle();

    final banner = find.byKey(const ValueKey('warning-banner'));
    expect(banner, findsOneWidget);
    final container = tester.widget<Container>(
      find.descendant(of: banner, matching: find.byType(Container)).first,
    );
    expect(
      (container.decoration as BoxDecoration?)?.color ?? container.color,
      MuziaColors.light.warnSurface,
    );
    expect(
      find.descendant(
        of: banner,
        matching: find.byIcon(Icons.warning_amber_outlined),
      ),
      findsOneWidget,
    );
    // 本文は amber-12、リード（タイトル）は bold、下罫線は amber-a5
    final texts = tester.widgetList<Text>(
      find.descendant(of: banner, matching: find.byType(Text)),
    );
    expect(texts.first.style?.fontWeight, FontWeight.w700);
    for (final text in texts) {
      expect(text.style?.color, MuziaColors.light.warnTextStrong);
    }
    expect(
      (container.decoration as BoxDecoration).border?.bottom.color,
      MuziaColors.light.warnBorder,
    );
  });

  testWidgets('プレイヤーバーはtransport配置で再生・一時停止できる', (tester) async {
    final player = PlayerViewModel(service: FakeAudioPlayerService());
    await player.play(_tracks.first);
    await tester.pumpWidget(MuziaApp(playerViewModel: player));
    await tester.pump();

    final bar = find.byKey(const ValueKey('player-bar'));
    expect(bar, findsOneWidget);
    expect(tester.getSize(bar).height, 74);
    expect(find.text('Neon Hours'), findsOneWidget);
    // 2行目は「アーティスト — アルバム」
    expect(find.text('Midnight Arcade — Parallel Lines'), findsOneWidget);
    // 前後スキップは未対応のため無効状態で配置する
    final prev = tester.widget<IconButton>(
      find.byKey(const ValueKey('playback-previous')),
    );
    final next = tester.widget<IconButton>(
      find.byKey(const ValueKey('playback-next')),
    );
    expect(prev.onPressed, isNull);
    expect(next.onPressed, isNull);
    // シークバー（未対応のため無効）
    expect(find.byKey(const ValueKey('playback-seek')), findsOneWidget);

    expect(find.byTooltip('一時停止'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('playback-toggle')));
    await tester.pump();
    expect(find.byTooltip('再生'), findsOneWidget);
  });
}
