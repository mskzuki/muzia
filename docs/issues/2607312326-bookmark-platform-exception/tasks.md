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
- macOS Integration Test: 既存7ファイルを個別に実行し全件成功。
  ディレクトリ一括実行（`flutter test integration_test -d macos`）はアプリの連続起動に
  失敗するため、ファイル単位で実行した。この起動失敗は変更前の `main` でも発生する。

### 未実行の確認

- ネイティブブックマークの失敗経路そのもののIntegration Test: 実フォルダの移動・削除と
  App Sandbox下でのアクセス権喪失が必要で、本環境では再現できないため未実行。
  該当経路は単体テスト（`test/security_scoped_bookmark_service_test.dart`、
  `test/library_repository_test.dart`）で検証している。
