# 警告付き状態で検索0件の空状態が表示されない 対応タスク

## 実装

- [x] 楽曲一覧を表示できる状態の判定を集約する
- [x] 検索0件のガードを両ステータスで共有する

## テスト

- [x] 警告付き状態で検索0件の空状態をWidgetテストする
- [x] `flutter analyze` と `flutter test` を実行する

## 完了

- [x] 完了条件と未実行確認を記録する

### 実行した確認

- `flutter analyze`: 警告なし
- `flutter test`: 全件成功

### 未実行の確認

- macOS Integration Test（`flutter test integration_test -d macos`）: 未実行。
  対象の分岐はWidgetテストで検証済み。
