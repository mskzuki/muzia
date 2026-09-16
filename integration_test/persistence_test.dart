import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/data/library_database.dart' hide Track;
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('保存済みライブラリを起動時に復元する', (tester) async {
    final database = LibraryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);
    const track = Track(
      filePath: '/tmp/persisted.mp3',
      fileExtension: '.mp3',
      title: 'Persisted song',
      artist: 'Artist',
      album: 'Album',
      durationMs: 215000,
      trackNumber: 3,
      releaseYear: 2024,
      genre: 'Jazz',
    );
    await repository.registerFolder('/tmp/music', const [track]);

    final restoredViewModel = LibraryViewModel(
      repository: PersistentMusicRepository(database),
    );
    await restoredViewModel.initialize();
    await tester.pumpWidget(MuziaApp(libraryViewModel: restoredViewModel));
    await tester.pumpAndSettle();

    expect(find.text('Persisted song'), findsOneWidget);
    // 再生時間・トラック番号・リリース年・ジャンルのUI表示は未対応のため、
    // 再起動後の読み込みで値が保持されることをモデルで確認する。
    expect(restoredViewModel.tracks.single, track);
  });
}
