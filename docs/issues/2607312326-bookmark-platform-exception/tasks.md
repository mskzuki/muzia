# ブックマーク失敗時にライブラリ全体が開けなくなる 対応タスク

## 実装前

- [x] `FlutterError` が `PlatformException` になる経路を確認する
- [x] アクセス権喪失を error と warning のどちらで扱うか確定する

## 実装

- [x] `NativeSecurityScopedBookmarkService` で `PlatformException` を捕捉する
- [x] `PersistentMusicRepository.load()` がブックマーク復元失敗でも楽曲を返すようにする
- [x] アクセス権喪失を `LibraryViewModel` の警告として通知する
- [x] `chooseAndScanFolder` を例外安全にする

## テスト

- [x] ブックマーク復元失敗でも楽曲一覧が表示されることをテストする
- [x] ブックマーク作成失敗がエラー表示になることをテストする
- [x] `flutter analyze` と `flutter test` を実行する

## 完了

- [x] 完了条件と未実行確認を記録する

### 実行した確認

- `flutter analyze`: 警告なし
- `flutter test`: 全件成功

### 未実行の確認

- macOS Integration Test（`flutter test integration_test -d macos`）: 実フォルダの移動・削除を伴う
  ネイティブブックマークの失敗は本環境で再現できないため未実行。
