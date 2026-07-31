import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muzia/features/library/data/library_database.dart' hide Track;
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('論理削除しても元ファイルを削除しない', (tester) async {
    final directory = await Directory.systemTemp.createTemp('muzia-removal-');
    addTearDown(() => directory.delete(recursive: true));
    final sourceFile = File('${directory.path}/song.mp3')
      ..writeAsStringSync('audio');
    final database = LibraryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);
    final track = Track(filePath: sourceFile.path, fileExtension: '.mp3');

    await repository.registerFolder(directory.path, [track]);
    await repository.markRemovedMany([track.filePath], true);

    expect(sourceFile.existsSync(), isTrue);
    expect(sourceFile.readAsStringSync(), 'audio');
    final restored = PersistentMusicRepository(database);
    await restored.load();
    expect(restored.tracks.single.isRemoved, isTrue);
  });
}
