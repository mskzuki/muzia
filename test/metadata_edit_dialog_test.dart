import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/metadata_edit_dialog.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';
import 'package:muzia/shared/widgets/muzia_dialog.dart';

void main() {
  const track = Track(
    filePath: '/music/song.mp3',
    fileExtension: '.mp3',
    title: 'Black or White',
    artist: 'Michael Jackson',
    album: 'Dangerous',
    releaseInfo: '1991-11-11',
    trackNumber: 5,
    releaseYear: 1991,
    genre: 'Pop',
  );

  Widget wrap(Widget child) =>
      MaterialApp(theme: MuziaTheme.light(), home: child);

  Future<Future<MetadataValues?> Function()> openDialog(
    WidgetTester tester, {
    Track track = track,
    List<String> genreSuggestions = const [],
  }) async {
    MetadataValues? saved;
    var closed = false;
    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                saved = await showDialog<MetadataValues>(
                  context: context,
                  builder: (_) => MetadataEditDialog(
                    track: track,
                    genreSuggestions: genreSuggestions,
                  ),
                );
                closed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    return () async {
      expect(closed, isTrue, reason: 'ダイアログが閉じていない');
      return saved;
    };
  }

  testWidgets('曲編集ダイアログに識別情報と6項目の現在値を表示し、リリース情報は出さない', (tester) async {
    await tester.pumpWidget(wrap(const MetadataEditDialog(track: track)));
    await tester.pumpAndSettle();

    expect(find.text('曲を編集'), findsOneWidget);
    // ヘッダの識別行: アーティスト + 「曲名 — アルバム」
    expect(find.text('Black or White — Dangerous'), findsOneWidget);
    expect(find.text('Michael Jackson'), findsNWidgets(2));
    for (final label in ['曲名', 'アーティスト', 'アルバム', 'トラック', 'リリース年', 'ジャンル']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Black or White'), findsOneWidget);
    expect(find.text('Dangerous'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('1991'), findsOneWidget);
    expect(find.text('Pop'), findsOneWidget);
    expect(find.text('リリース情報'), findsNothing);
    expect(find.text('1991-11-11'), findsNothing);
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.byTooltip('閉じる'), findsOneWidget);

    // 曲名に初期フォーカスが当たる。
    final titleField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('edit-title')),
        matching: find.byType(TextField),
      ),
    );
    expect(titleField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('保存で6項目を返し、リリース情報は更新対象に含めない', (tester) async {
    final result = await openDialog(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('edit-track-number')),
        matching: find.byType(TextField),
      ),
      '',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('edit-release-year')),
        matching: find.byType(TextField),
      ),
      '2024',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    final saved = await result();
    expect(saved, isNotNull);
    expect(saved!.fields, MetadataEditDialog.fields);
    expect(saved.changes(MetadataField.releaseInfo), isFalse);
    expect(saved.title, 'Black or White');
    expect(saved.artist, 'Michael Jackson');
    expect(saved.album, 'Dangerous');
    // 空欄にしたトラック番号は未設定(null)として保存する。
    expect(saved.trackNumber, isNull);
    expect(saved.releaseYear, 2024);
    expect(saved.genre, 'Pop');
    // リリース情報は保持される。
    expect(track.replaceMetadata(saved).releaseInfo, '1991-11-11');
  });

  testWidgets('トラック番号とリリース年を検証し、不正なら保存しない', (tester) async {
    await tester.pumpWidget(wrap(const MetadataEditDialog(track: track)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('edit-track-number')),
        matching: find.byType(TextField),
      ),
      '0',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('edit-release-year')),
        matching: find.byType(TextField),
      ),
      '202',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    expect(find.text('トラック番号は1以上の整数で入力してください。'), findsOneWidget);
    expect(find.text('リリース年は4桁の数字で入力してください。'), findsOneWidget);
    // ダイアログは閉じていない。
    expect(find.text('曲を編集'), findsOneWidget);

    // リリース年は数字4桁までしか入力できない。
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('edit-release-year')),
        matching: find.byType(TextField),
      ),
      '20245a',
    );
    await tester.pumpAndSettle();
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('リリース年は4桁の数字で入力してください。'), findsNothing);
  });

  testWidgets('曲名が空なら保存しない', (tester) async {
    await tester.pumpWidget(wrap(const MetadataEditDialog(track: track)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('edit-title')),
        matching: find.byType(TextField),
      ),
      '  ',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    expect(find.text('曲名を入力してください。'), findsOneWidget);
  });

  testWidgets('ジャンルのチップをタップすると入力欄に反映される', (tester) async {
    final result = await openDialog(
      tester,
      genreSuggestions: const ['Alternative', 'Indie Rock', 'Pop'],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // 現在のジャンルと一致するチップは選択表示になる。
    expect(
      tester
          .widget<MuziaChip>(find.byKey(const ValueKey('genre-chip-Pop')))
          .selected,
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('genre-chip-Indie Rock')));
    await tester.pumpAndSettle();
    final genreField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('edit-genre')),
        matching: find.byType(TextField),
      ),
    );
    expect(genreField.controller?.text, 'Indie Rock');

    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();
    expect((await result())!.genre, 'Indie Rock');
  });

  testWidgets('キャンセルと閉じるボタンで値を返さずに閉じる', (tester) async {
    final result = await openDialog(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();
    expect(await result(), isNull);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('曲を編集'), findsOneWidget);
    await tester.tap(find.byTooltip('閉じる'));
    await tester.pumpAndSettle();
    expect(find.text('曲を編集'), findsNothing);
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
