# ライブラリ永続化 実装タスク

## 実装前

- [ ] Driftの生成コード、データベース配置、macOS / Windowsの保存先を検証する
- [ ] `docs/database.md`のスキーマとRepository境界を確認する

## 実装

- [ ] Driftのテーブル、DAO、Databaseクラスを追加する
- [ ] `LibraryStorageService`とRepositoryを追加する
- [ ] 起動時読み込みと状態復元をViewModelへ接続する
- [ ] DBエラーとマイグレーション基盤を実装する

## テスト

- [ ] インメモリDBでCRUDとトランザクションをテストする
- [ ] マイグレーションと起動時状態をテストする
- [ ] 登録フォルダ、編集値、削除状態の再起動Integration Testを追加する
- [ ] `flutter analyze` と `flutter test` を実行する

## 完了

- [ ] 完了条件と未実行確認を記録する

