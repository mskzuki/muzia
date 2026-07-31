# フォルダ再登録で track_metadata の孤児行が蓄積する 対応タスク

## 実装

- [ ] `registerFolder` のトランザクション内で `trackMetadata` を削除する

## テスト

- [ ] フォルダ再登録後に孤児行が残らないことをテストする
- [ ] `flutter analyze` と `flutter test` を実行する

## 完了

- [ ] 完了条件と未実行確認を記録する
- [ ] 外部キー導入による恒久対応を残課題として記録する
