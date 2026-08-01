# ブックマーク作成のネイティブ失敗をユーザーへ通知する 対応タスク

## 実装前

- [x] `createBookmark` と `restoreBookmark` のエラー扱いを分離する
- [x] 既存の登録エラー表示を利用することを確認する

## 実装・テスト

- [x] `createBookmark` の `PlatformException` を呼び出し元へ伝播する
- [x] サービス層でネイティブエラーを検証するテストを追加する
- [x] ViewModelでユーザー向けエラーへ変換されるテストを追加する
- [x] `flutter analyze` と `flutter test` を実行する

## 完了条件

- [x] 実行結果を記録する

### 実行した確認

- `flutter analyze`: 成功
- `flutter test`: 成功
