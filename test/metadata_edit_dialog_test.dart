import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
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
      MaterialApp(
        home: BulkMetadataEditDialog(
          tracks: const [
            Track(filePath: 'one.mp3', fileExtension: '.mp3', artist: 'Artist'),
            Track(filePath: 'two.mp3', fileExtension: '.mp3', artist: 'Artist'),
            Track(
              filePath: 'three.mp3',
              fileExtension: '.mp3',
              artist: 'Other',
            ),
          ],
        ),
      ),
    );

    expect(find.text('3曲を選択中'), findsOneWidget);
    expect(find.text('曲名とトラック番号は、重複を避けるため一括編集できません。'), findsOneWidget);
    expect(find.text('アルバム情報の一括編集'), findsOneWidget);
    // アーティストだけが混在している。アルバムとリリース年は全曲未設定なので一致扱い。
    expect(find.text('複数の値'), findsOneWidget);
  });

  testWidgets('一括編集ダイアログは共通する現在値を事前入力する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BulkMetadataEditDialog(
          tracks: const [
            Track(
              filePath: 'one.mp3',
              fileExtension: '.mp3',
              artist: 'Shared artist',
              album: 'Album A',
            ),
            Track(
              filePath: 'two.mp3',
              fileExtension: '.mp3',
              artist: 'Shared artist',
              album: 'Album B',
            ),
          ],
        ),
      ),
    );

    // 全曲で一致するアーティストは事前入力される。
    expect(find.text('Shared artist'), findsOneWidget);
    // 混在するアルバムは空欄のまま。
    expect(find.text('Album A'), findsNothing);
    expect(find.text('複数の値'), findsOneWidget);
  });

  testWidgets('チェックしていない項目を更新対象に含めない', (tester) async {
    MetadataValues? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                saved = await showDialog<MetadataValues>(
                  context: context,
                  builder: (_) => const BulkMetadataEditDialog(
                    tracks: [
                      Track(
                        filePath: 'one.mp3',
                        fileExtension: '.mp3',
                        title: 'Keep me',
                        artist: 'Old artist',
                        album: 'Old album',
                      ),
                    ],
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // 何もチェックしていない状態では保存できない。
    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '保存'),
    );
    expect(saveButton.onPressed, isNull);

    // アーティストだけを対象にする。
    await tester.tap(find.byKey(const ValueKey('bulk-target-artist')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Old artist'),
      'New artist',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.fields, {MetadataField.artist});
    expect(saved!.artist, 'New artist');
    // アルバムはチェックしていないので更新対象に含まれない。
    expect(saved!.changes(MetadataField.album), isFalse);
    expect(saved!.changes(MetadataField.title), isFalse);
  });
}
