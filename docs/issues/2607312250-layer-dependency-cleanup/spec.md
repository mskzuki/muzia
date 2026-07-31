# レイヤー依存関係整理 仕様書

## 文書情報

- 課題ID: 2607312250
- 種別: 設計是正
- 対応する全体要件: NFR-004、NFR-005
- ステータス: Completed
- 作成日: 2026-07-31

## 1. 目的

Domain層から外部ライブラリとOS APIへの依存を除去し、ViewModelから直接ファイルシステムへアクセスしない構造にする。

## 2. 要件

- `playback/domain` は`media_kit`、`dart:io`をimportしない。
- MediaKit実装は`playback/data`に隔離する。
- `PlayerViewModel`は`AudioPlayerService`の実装を自動生成せず、注入されたServiceだけを利用する。
- `LibraryViewModel`は`dart:io`をimportせず、Directory Service経由でフォルダを検証する。
- 既存のFake注入テストとmacOS/Windows向け実装を維持する。

## 3. 完了条件

- 対象層のimport依存が規約に適合する。
- 再生、フォルダ検証、既存テストが動作する。
- `flutter analyze` と `flutter test` が成功する。
