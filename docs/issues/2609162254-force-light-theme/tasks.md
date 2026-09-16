# タスク

## 実装

- [x] `lib/app/app.dart` の `MaterialApp` に `themeMode: ThemeMode.light` を設定

## テスト

- [x] `test/muzia_theme_test.dart` に `themeMode` の検証と、
      `platformBrightness = dark` 時にライトで描画される検証を追加

## 動作確認

- [x] `flutter analyze`（No issues）
- [x] `flutter test`（92件成功）
- [ ] macOSのシステム外観をダークにして起動し、ライト表示になることを目視確認
