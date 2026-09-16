import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/bulk_edit_plan.dart';
import 'package:muzia/features/library/domain/library_catalog.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/bulk_edit_confirm_dialog.dart';
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

  group('BulkMetadataEditDialog', () {
    final library = [
      const Track(
        filePath: '/a/1.mp3',
        fileExtension: '.mp3',
        title: 'Neon Hours',
        artist: 'Midnight Arcade',
        album: 'Parallel Lines',
        genre: 'Synth-pop',
      ),
      const Track(
        filePath: '/a/2.mp3',
        fileExtension: '.mp3',
        title: 'Golden Static',
        artist: 'Midnight Arcade',
        album: 'Parallel Lines',
        genre: 'Synth-pop',
      ),
      const Track(
        filePath: '/a/3.mp3',
        fileExtension: '.mp3',
        title: 'Ember',
        artist: 'Midnight Arcade',
        album: 'Parallel Lines',
      ),
      const Track(
        filePath: '/b/1.mp3',
        fileExtension: '.mp3',
        title: 'Coastlines',
        artist: 'Hollow Coast',
        album: 'Tidewater',
        genre: 'Alternative',
      ),
    ];
    final catalog = LibraryCatalog(library);

    Future<Future<BulkEditPlan?> Function()> openBulk(
      WidgetTester tester,
      List<Track> selected,
    ) async {
      BulkEditPlan? saved;
      var closed = false;
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  saved = await showDialog<BulkEditPlan>(
                    context: context,
                    builder: (_) => BulkMetadataEditDialog(
                      tracks: selected,
                      catalog: catalog,
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
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return () async {
        expect(closed, isTrue, reason: 'ダイアログが閉じていない');
        return saved;
      };
    }

    Finder input(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextField),
    );

    testWidgets('選択数チップ・対象アルバム・除外注記・4項目を常時表示し、項目ごとのチェックボックスは置かない', (
      tester,
    ) async {
      await openBulk(tester, library.sublist(0, 2));

      expect(find.text('アルバム情報の一括編集'), findsOneWidget);
      expect(find.text('2 曲を選択中'), findsOneWidget);
      expect(find.text('曲名とトラック番号は、重複を避けるため一括編集できません。'), findsOneWidget);
      for (final label in ['アーティスト', 'アルバム名', 'リリース年', 'ジャンル']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.byType(CheckboxListTile), findsNothing);
      // 共通する現在値はプレースホルダとして出る（対象アルバム名はヘッダにも出る）。
      expect(find.text('Midnight Arcade'), findsOneWidget);
      expect(find.text('Parallel Lines'), findsNWidgets(2));
      expect(find.text('Synth-pop'), findsNWidgets(2)); // プレースホルダ + チップ
      expect(find.text('YYYY'), findsOneWidget);
      // 部分選択なので「含めて変更する」チェックボックスが出る。
      expect(find.text('選択していない同じアルバムの曲も含めて変更する'), findsOneWidget);
      // 何も入力していない間は保存できない。
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '保存'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('値が混在する項目は「複数の値」、複数アルバムなら含めて変更の選択肢を出さない', (tester) async {
      await openBulk(tester, [library[0], library[3]]);

      expect(find.text('2 枚のアルバム'), findsOneWidget);
      expect(find.text('複数の値'), findsNWidgets(3)); // アーティスト・アルバム・ジャンル
      expect(find.text('選択していない同じアルバムの曲も含めて変更する'), findsNothing);
    });

    testWidgets('アルバム名だけ入力して保存すると分割の計画を返す', (tester) async {
      final result = await openBulk(tester, library.sublist(0, 2));

      await tester.enterText(input('bulk-album'), 'Parallel Lines (Deluxe)');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '保存'));
      await tester.pumpAndSettle();

      final plan = await result();
      expect(plan, isNotNull);
      expect(plan!.targets.length, 2);
      expect(plan.values.fields, {MetadataField.album});
      expect(plan.summary.single, contains('分割'));
    });

    testWidgets('含めて変更するをチェックすると選択外の収録曲も対象になる', (tester) async {
      final result = await openBulk(tester, library.sublist(0, 2));

      await tester.enterText(input('bulk-album'), 'PL');
      await tester.tap(find.byKey(const ValueKey('bulk-include-album')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '保存'));
      await tester.pumpAndSettle();

      final plan = await result();
      expect(plan!.targets.length, 3);
      expect(plan.request.includeUnselectedAlbumTracks, isTrue);
      expect(plan.summary.single, contains('全 3 曲'));
    });

    testWidgets('既存アルバム名への変更とリリース年の桁不足は保存をブロックする', (tester) async {
      await openBulk(tester, library.sublist(0, 2));

      await tester.enterText(input('bulk-album'), 'Tidewater');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '保存'));
      await tester.pumpAndSettle();
      expect(find.text('「Tidewater」という名前のアルバムが既に存在します。'), findsOneWidget);
      expect(find.text('アルバム情報の一括編集'), findsOneWidget);

      await tester.enterText(input('bulk-album'), '');
      await tester.enterText(input('bulk-release-year'), '202');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '保存'));
      await tester.pumpAndSettle();
      expect(find.text('リリース年は4桁の数字で入力してください。'), findsOneWidget);
    });

    testWidgets('ジャンルチップで入力し、空欄の項目は更新対象に含めない', (tester) async {
      final result = await openBulk(tester, library.sublist(0, 2));

      final chip = find.byKey(const ValueKey('bulk-genre-chip-Alternative'));
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '保存'));
      await tester.pumpAndSettle();

      final plan = await result();
      expect(plan!.values.fields, {MetadataField.genre});
      expect(plan.values.genre, 'Alternative');
      expect(plan.values.changes(MetadataField.album), isFalse);
      expect(plan.values.changes(MetadataField.artist), isFalse);
    });
  });

  testWidgets('確認ダイアログは変更内容の箇条書きと注記を表示し、戻る/適用を返す', (tester) async {
    final plan = planBulkEdit(
      selected: const [
        Track(filePath: '/a/1.mp3', fileExtension: '.mp3', album: 'A'),
      ],
      catalog: const LibraryCatalog([
        Track(filePath: '/a/1.mp3', fileExtension: '.mp3', album: 'A'),
        Track(filePath: '/a/2.mp3', fileExtension: '.mp3', album: 'A'),
      ]),
      request: const BulkEditRequest(album: 'B', genre: 'Pop'),
    );
    bool? result;
    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (_) => BulkEditConfirmDialog(plan: plan),
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
    expect(find.text('次の変更を適用します'), findsOneWidget);
    expect(find.text('選択した 1 曲だけを「B」へ分割します。残り 1 曲は「A」のままです。'), findsOneWidget);
    expect(find.text('ジャンルを「Pop」に変更します（1 曲）。'), findsOneWidget);
    expect(find.text('ファイルには書き込まれません（編集はライブラリ内にのみ保存されます）。'), findsOneWidget);
    await tester.tap(find.text('戻る'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('適用'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
