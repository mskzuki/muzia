import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/metadata_edit_dialog.dart';

void main() {
  testWidgets('個別編集ダイアログに現在値と4項目を表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MetadataEditDialog(
          track: const Track(
            filePath: 'song.mp3',
            fileExtension: '.mp3',
            title: 'Title',
            artist: 'Artist',
            album: 'Album',
            releaseInfo: '2024',
          ),
        ),
      ),
    );

    expect(find.text('曲を編集'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Artist'), findsOneWidget);
    expect(find.text('Album'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
  });

  testWidgets('一括編集ダイアログに選択数と除外項目を表示する', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BulkMetadataEditDialog(count: 3)),
    );

    expect(find.text('3曲を選択中'), findsOneWidget);
    expect(find.text('曲名とトラック番号は、重複を避けるため一括編集できません。'), findsOneWidget);
    expect(find.text('アルバム情報の一括編集'), findsOneWidget);
  });
}
