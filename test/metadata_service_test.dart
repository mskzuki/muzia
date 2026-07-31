import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/data/metadata_service.dart';

void main() {
  test('メタデータ解析の失敗を呼び出し元へ伝播する', () async {
    final file = File(
      '${Directory.systemTemp.path}/muzia-invalid-metadata.mp3',
    );
    await file.writeAsString('not an mp3');
    addTearDown(() => file.delete());

    expect(() => AudioMetadataService().read(file), throwsA(isA<Object>()));
  });
}
