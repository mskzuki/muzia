# メタデータ解析Isolate化 実装タスク

## 実装前

- [x] 現在の`Future`ラップが別Isolateではないことを確認する
- [x] `Isolate.run`へ渡す引数と戻り値を確認する

## 実装

- [x] 同期メタデータ解析をトップレベルIsolate関数へ分離する
- [x] `AudioMetadataService`からIsolate関数を呼び出す
- [x] スキャンの解析エラー分類との互換性を確認する

## テスト

- [x] メタデータServiceの解析結果と失敗伝播を検証する
- [x] `flutter analyze` と `flutter test` を実行する

## 完了

- [x] 完了条件と未実行確認を記録する
