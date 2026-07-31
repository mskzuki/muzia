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
    await tester.tap(find.text('アーティスト / アルバム'));
    await tester.pumpAndSettle();

    expect(find.text('Beta'), findsWidgets);
    final albumCard = find.ancestor(
      of: find.text('B').first,
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(albumCard);
    await tester.tap(albumCard);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
  });
}
