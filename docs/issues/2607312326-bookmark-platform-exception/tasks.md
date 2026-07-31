# ブックマーク失敗時にライブラリ全体が開けなくなる 対応タスク

## 実装前

- [ ] `FlutterError` が `PlatformException` になる経路を確認する
- [ ] アクセス権喪失を error と warning のどちらで扱うか確定する

## 実装

- [ ] `NativeSecurityScopedBookmarkService` で `PlatformException` を捕捉する
- [ ] `PersistentMusicRepository.load()` がブックマーク復元失敗でも楽曲を返すようにする
- [ ] アクセス権喪失を `LibraryViewModel` の警告として通知する
- [ ] `chooseAndScanFolder` を例外安全にする

## テスト

- [ ] ブックマーク復元失敗でも楽曲一覧が表示されることをテストする
- [ ] ブックマーク作成失敗がエラー表示になることをテストする
- [ ] `flutter analyze` と `flutter test` を実行する

## 完了

- [ ] 完了条件と未実行確認を記録する
