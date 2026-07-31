import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muzia/features/library/data/library_database.dart' hide Track;
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('メタデータ更新を保持し、元ファイルを変更しない', (tester) async {
    final directory = await Directory.systemTemp.createTemp('muzia-metadata-');
    addTearDown(() => directory.delete(recursive: true));
    final sourceFile = File('${directory.path}/song.mp3')
      ..writeAsStringSync('audio');
    final database = LibraryDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PersistentMusicRepository(database);
    final track = Track(
      filePath: sourceFile.path,
      fileExtension: '.mp3',
      title: 'Original',
    );

    await repository.registerFolder(directory.path, [track]);
    await repository.updateMetadataMany(
      [track.filePath],
      const MetadataValues(
        title: 'Edited',
        artist: 'New artist',
        album: 'New album',
        releaseInfo: '2025',
      ),
    );
    final restored = PersistentMusicRepository(database);
    await restored.load();

    expect(restored.tracks.single.title, 'Edited');
    expect(sourceFile.readAsStringSync(), 'audio');
  });
}
