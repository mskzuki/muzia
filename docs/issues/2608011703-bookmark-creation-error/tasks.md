# フォルダ登録失敗で楽曲一覧が消える 対応タスク

## 実装前

- [x] `_setError` の呼び出し元を洗い出し、致命的エラーと操作失敗に仕分ける
- [x] SnackBar の発火に `failureRevision` 方式で足りることを確認する
- [x] 既存の `test/library_test.dart` の登録失敗3件が現行の期待値のまま通るか確認する
- [x] 継続要件 REQ-001〜003 を検証している既存テストを特定し、変更対象から外す

## 実装

- [x] `LibraryViewModel` に `_reportFailure` と `failureRevision` を追加する
- [x] `chooseAndScanFolder` の失敗を `_reportFailure` に切り替える
- [x] `registerAndScan` の検証エラー・重複登録・メタデータ全件解析失敗・
      `FolderAccessException`・その他のスキャン失敗を `_reportFailure` に切り替える
- [x] `_setError` を初期化失敗など一覧が無い経路専用にする
- [x] `AppShellPage` に `ref.listen` を追加し、SnackBar で `errorMessage` を表示する

## テスト

- [x] 一覧表示中の登録失敗で `status` と `tracks` が変わらないことを検証する（ViewModel）
- [x] 同じ失敗を2回起こすと `failureRevision` が2回増えることを検証する（ViewModel）
- [x] 一覧が無い状態の失敗が `LibraryStatus.error` のままであることを検証する（ViewModel）
- [x] サイドバーの「フォルダを登録」をタップして失敗させ、SnackBar が出て
      楽曲一覧が画面に残ることを検証する（Widget、UIから到達する経路）
- [x] `flutter analyze` と `flutter test` を実行する
- [x] `flutter test integration_test -d macos` を実行する（実行したがmacOSアプリのデバッグ接続失敗）

## 完了

- [x] 完了条件と未実行確認を記録する
- [x] `spec.md` のステータスを Completed にする

### 実行した確認

- `flutter analyze` 成功
- `flutter test` 成功（53 tests）
- `flutter test integration_test -d macos` 実行

### 未実行の確認

- macOS Integration Testは、アプリのビルド後にデバッグ接続を確立できず、6件が起動失敗。
  `Failed to foreground app; open returned 1` / `Error waiting for a debug connection`。
