import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/presentation/library_removal_dialog.dart';

void main() {
  testWidgets('削除対象数と元ファイルを残す説明を表示する', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LibraryRemovalDialog(count: 2)),
    );

    expect(find.textContaining('2曲をライブラリから削除しますか？'), findsOneWidget);
    expect(find.textContaining('元の音楽ファイルは削除'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.text('ライブラリから削除'), findsNWidgets(2));
  });
}
