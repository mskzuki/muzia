import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';

void main() {
  testWidgets('アプリシェルの基本レイアウトと空状態を表示する', (tester) async {
    await tester.pumpWidget(const MuziaApp());
    await tester.pumpAndSettle();

    expect(find.text('Muzia'), findsOneWidget);
    expect(find.text('ライブラリ'), findsOneWidget);
    expect(find.text('ライブラリは空です'), findsOneWidget);
    expect(find.text('再生する楽曲が選択されていません'), findsOneWidget);
  });

  testWidgets('ライブラリ読み込み中の状態を表示する', (tester) async {
    final completer = Completer<void>();
    final viewModel = AppShellViewModel(
      initializeLibrary: () => completer.future,
    );

    await tester.pumpWidget(MuziaApp(viewModel: viewModel));
    expect(find.text('ライブラリを読み込んでいます'), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();
    expect(find.text('ライブラリは空です'), findsOneWidget);
  });

  testWidgets('ライブラリ読み込みエラーを表示する', (tester) async {
    final viewModel = AppShellViewModel(
      initializeLibrary: () async => throw StateError('test error'),
    );

    await tester.pumpWidget(MuziaApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    expect(find.text('読み込みエラー'), findsOneWidget);
    expect(find.text('ライブラリの読み込みに失敗しました。'), findsOneWidget);
  });

  testWidgets('検索語を入力してクリアできる', (tester) async {
    await tester.pumpWidget(const MuziaApp());
    await tester.pumpAndSettle();
    final searchField = find.byKey(const ValueKey('library-search'));

    await tester.enterText(searchField, 'artist');
    await tester.pump();
    expect(find.text('artist'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(find.text('artist'), findsNothing);
  });
}
