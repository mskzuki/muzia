import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('検索語で楽曲を絞り込み、クリアで一覧へ戻る', (tester) async {
    final repository = InMemoryMusicRepository();
    await repository.registerFolder('/tmp/music', const [
      Track(
        filePath: '/tmp/song.mp3',
        fileExtension: '.mp3',
        title: 'Neon Hours',
        artist: 'Midnight Arcade',
        album: 'Parallel Lines',
      ),
    ]);
    final viewModel = LibraryViewModel(repository: repository);
    await viewModel.initialize();

    await tester.pumpWidget(MuziaApp(libraryViewModel: viewModel));
    await tester.pump(const Duration(milliseconds: 300));
    final searchField = find.byKey(const ValueKey('library-search'));
    await tester.enterText(searchField, 'parallel');
    await tester.pump();
    expect(find.text('Neon Hours'), findsOneWidget);
    await tester.enterText(searchField, 'not found');
    await tester.pump();
    expect(find.text('該当する楽曲がありません'), findsOneWidget);
  });
}
