# ブックマーク作成のネイティブ失敗をユーザーへ通知する

## 文書情報

- 種別: 不具合（エラー処理の是正）
- 対応する要件: FR-002
- 作成日: 2026-08-01
- ステータス: In progress

## 1. 事象

フォルダ登録時にmacOSのsecurity-scoped bookmark作成が失敗すると、
`NativeSecurityScopedBookmarkService` が `PlatformException` を `null` に変換する。
そのため、ブックマーク作成に失敗したことがユーザーへ通知されず、ブックマークなしで
登録処理が続行される。

## 2. 要件

- `createBookmark` のネイティブ失敗（`PlatformException`）を呼び出し元へ伝播する。
- `LibraryViewModel` は既存の「フォルダを登録できませんでした。」を表示する。
- `restoreBookmark` の失敗は既存どおり、保存済みライブラリを表示する警告として扱う。
- macOS以外やテスト環境でネイティブ実装がない場合の無効化動作は維持する。

## 3. 完了条件

- ブックマーク作成のネイティブエラーが未処理例外にならず、登録エラーとして表示される。
- サービス層とViewModel層の回帰テストがある。
- `flutter analyze` と `flutter test` が成功する。
