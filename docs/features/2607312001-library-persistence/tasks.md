# ライブラリ永続化 実装タスク

## 実装前

- [x] Driftの生成コード、データベース配置、macOS / Windowsの保存先を検証する
- [x] `docs/database.md`のスキーマとRepository境界を確認する

## 実装

- [x] Driftのテーブル、DAO、Databaseクラスを追加する
- [x] 永続化Repositoryを追加する
- [x] 起動時読み込みと状態復元をViewModelへ接続する
- [x] DBエラーとマイグレーション基盤を実装する

## テスト

- [x] インメモリDBでCRUDとトランザクションをテストする
- [x] マイグレーションと起動時状態をテストする
- [x] 登録フォルダ、編集値、削除状態の復元Integration Testを追加する
- [x] `flutter analyze` と `flutter test` を実行する

## 完了

- [x] 完了条件と未実行確認を記録する
