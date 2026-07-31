# メタデータ解析Isolate化 仕様書

## 文書情報

- 課題ID: 2607312255
- 種別: 性能是正
- 対応する全体要件: NFR-002
- ステータス: Completed
- 作成日: 2026-07-31

## 1. 目的

同期的な音声メタデータ解析でUIスレッドをブロックしないよう、解析処理を別Isolateで実行する。

## 2. 要件

- `audio_metadata_reader`の同期解析処理を`Isolate.run`内で実行する。
- Isolate間で渡す値はファイルパスなどSendableな値に限定する。
- 解析結果は既存の`Track`へ変換して返す。
- 解析失敗時の例外は呼び出し元へ伝播し、既存のスキャンエラー分類で扱えるようにする。

## 3. 完了条件

- `Future(() {...})`によるUI Isolate内の同期実行を除去する。
- Isolate化したMetadataServiceをスキャンへ接続する。
- `flutter analyze` と `flutter test` が成功する。
