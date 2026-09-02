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
    // 楽曲数のバッジ
    expect(
      find.descendant(of: sidebar, matching: find.text('2')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: sidebar,
        matching: find.text('アーティスト / アルバム'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sidebar, matching: find.text('フォルダを登録')),
      findsOneWidget,
    );
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
    expect(find.text('Midnight Arcade'), findsOneWidget);
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
