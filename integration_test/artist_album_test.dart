import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/data/file_scanner_service.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';

class _FakeScanner implements FileScannerService {
  @override
  Stream<ScanEvent> scan(String directoryPath) async* {
    yield const TrackFound(
      Track(
        filePath: 'one.mp3',
        fileExtension: '.mp3',
        title: 'One',
        artist: 'Beta',
        album: 'B',
      ),
    );
    yield ScanCompleted(candidateCount: 1, foundCount: 1);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('アーティストからアルバムと楽曲を表示する', (tester) async {
    final directory = await Directory.systemTemp.createTemp(
      'muzia-artist-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final libraryViewModel = LibraryViewModel(scanner: _FakeScanner());
    await libraryViewModel.registerAndScan(directory.path);

    await tester.pumpWidget(MuziaApp(libraryViewModel: libraryViewModel));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('sidebar')),
        matching: find.text('アーティスト'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beta'), findsWidgets);
    // アーティスト選択時点で全楽曲が見える（ウィンドウ高さによってはスクロールが必要）
    await tester.dragUntilVisible(
      find.text('One'),
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    expect(find.text('One'), findsOneWidget);
    final albumCard = find.byKey(const ValueKey('album-card-B'));
    await tester.dragUntilVisible(
      albumCard,
      find.byType(ListView).last,
      const Offset(0, 200),
    );
    await tester.tap(albumCard);
    await tester.pumpAndSettle();
    // アルバム詳細のトラックリストにも表示される
    expect(find.byKey(const ValueKey('album-hero-meta')), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('One'),
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    expect(find.text('One'), findsOneWidget);
  });
}
