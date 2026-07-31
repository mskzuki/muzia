# レイヤー依存関係整理 実装タスク

## 実装前

- [x] architecture.mdの依存関係規約と該当importを確認する
- [x] Serviceの注入境界を確認する

## 実装

- [x] AudioPlayerServiceの契約とMediaKit実装を分離する
- [x] PlayerViewModelの具象Service自動生成を除去する
- [x] DirectoryServiceを追加し、LibraryViewModelのdart:io依存を除去する
- [x] アプリ起動時のMediaKit実装注入を接続する

## テスト

- [x] Domain/ViewModelから禁止依存がなくなったことを確認する
- [x] `flutter analyze` と `flutter test` を実行する

## 完了

- [x] 完了条件と未実行確認を記録する
