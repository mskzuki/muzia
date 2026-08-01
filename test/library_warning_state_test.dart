import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/data/directory_service.dart';
import 'package:muzia/features/library/data/file_scanner_service.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';

/// 1件は読み込め、1件は解析できないスキャン。`readyWithWarnings` を作る。
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

/// Widgetテストは fake async のため実ファイルI/Oが完了しない。
class _AlwaysDirectoryService implements DirectoryService {
  @override
  Future<bool> isDirectory(String path) async => true;
}

Future<LibraryViewModel> _warnedLibrary() async {
  final viewModel = LibraryViewModel(
    scanner: _PartialIssueScanner(),
    directoryService: _AlwaysDirectoryService(),
    repository: InMemoryMusicRepository(),
  );
  // 画面側の initialize() で状態が巻き戻らないよう、先に初期化を済ませる。
  await viewModel.initialize();
  await viewModel.registerAndScan('/tmp/music');
  expect(viewModel.status, LibraryStatus.readyWithWarnings);
  return viewModel;
}

Future<void> _search(WidgetTester tester, String query) async {
  await tester.enterText(find.byKey(const ValueKey('library-search')), query);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('警告付き状態でも検索0件の空状態を表示する', (tester) async {
    final libraryViewModel = await _warnedLibrary();

    await tester.pumpWidget(MuziaApp(libraryViewModel: libraryViewModel));
    await tester.pumpAndSettle();
    await _search(tester, '一致しない検索語');

    expect(find.text('該当する楽曲がありません'), findsOneWidget);
  });

  testWidgets('検索0件でも警告は通知し続ける', (tester) async {
    final libraryViewModel = await _warnedLibrary();

    await tester.pumpWidget(MuziaApp(libraryViewModel: libraryViewModel));
    await tester.pumpAndSettle();
    await _search(tester, '一致しない検索語');

    expect(find.text('1件の音楽ファイルを解析できませんでした。'), findsOneWidget);
  });

  testWidgets('警告付き状態で検索が一致すれば楽曲を表示する', (tester) async {
    final libraryViewModel = await _warnedLibrary();

    await tester.pumpWidget(MuziaApp(libraryViewModel: libraryViewModel));
    await tester.pumpAndSettle();
    await _search(tester, 'Valid');

    expect(find.text('Valid song'), findsOneWidget);
    expect(find.text('該当する楽曲がありません'), findsNothing);
  });
}
