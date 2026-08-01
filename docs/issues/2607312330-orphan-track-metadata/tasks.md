# フォルダ再登録で track_metadata の孤児行が蓄積する 対応タスク

## 実装

- [x] `registerFolder` のトランザクション内で `trackMetadata` を削除する

## テスト

- [x] フォルダ再登録後に孤児行が残らないことをテストする
- [x] `flutter analyze` と `flutter test` を実行する

## 完了

- [x] 完了条件と未実行確認を記録する
- [x] 外部キー導入による恒久対応を残課題として記録する（spec.md 7節）

### 実行した確認

- `flutter analyze`: 警告なし
- `flutter test`: 全件成功
