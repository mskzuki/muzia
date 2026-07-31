import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muzia/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('アプリシェルを起動して空状態を表示する', (tester) async {
    await tester.pumpWidget(const MuziaApp());
    await tester.pumpAndSettle();

    expect(find.text('Muzia'), findsOneWidget);
    expect(find.text('ライブラリは空です'), findsOneWidget);
    expect(find.text('再生する楽曲が選択されていません'), findsOneWidget);
  });
}
