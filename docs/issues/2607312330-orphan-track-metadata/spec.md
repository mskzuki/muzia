# フォルダ再登録で track_metadata の孤児行が蓄積する 課題仕様書

## 文書情報

- 課題ID: 2607312330
- 種別: 不具合（データ整合性）
- 対応する全体要件: FR-010
- ステータス: Draft
- 作成日: 2026-07-31

## 1. 事象

音楽フォルダを登録・変更するたびに、参照先の楽曲が存在しない
`track_metadata` の行がDBへ残り続ける。

`track_source_metadata` は削除されるのに `track_metadata` は残るため、
2つのメタデータテーブルの整合が取れていない。

## 2. 原因

`lib/features/library/data/music_repository.dart` の `registerFolder` は

```dart
await _database.delete(_database.trackSourceMetadata).go();
await _database.delete(_database.tracks).go();
```

を実行するが、`trackMetadata` を削除していない。

`docs/database.md` が定める FOREIGN KEY が実装されておらず
（Driftの `references()` 未使用、`PRAGMA foreign_keys` も未設定）、
カスケード削除も働かない。

`tracks.id` が `AUTOINCREMENT` のため既存行とのPK衝突は発生せず、
エラーにならないまま静かに蓄積する。

## 3. 再現手順

1. 楽曲を含むフォルダAを登録する
2. 別のフォルダBを登録する
3. `track_metadata` の行数を確認する

期待: フォルダBの楽曲数と一致する。
実際: フォルダAとフォルダBの合計になる。

## 4. 要件

- [ ] REQ-001: フォルダ登録時に、参照先を失う `track_metadata` を削除する。
- [ ] REQ-002: `track_metadata` と `track_source_metadata` の行数が常に一致する。
- [ ] REQ-003: ユーザーの音楽ファイルには影響しない。

## 5. 完了条件

- [ ] フォルダ再登録後に孤児行が残らない。
- [ ] 行数の一致を検証するテストが追加され、成功する。
- [ ] `flutter analyze` と `flutter test` が成功する。

## 6. 実装メモ

短期的には `registerFolder` のトランザクション内で `trackMetadata` も削除する。
恒久対応としては `docs/database.md` の定義どおりに FOREIGN KEY を導入し、
`PRAGMA foreign_keys = ON` とカスケード削除で担保する。
外部キーの導入は既存DBのマイグレーションを伴うため、本課題では削除の追加までを対象とする。

## 7. 関連文書

- [データベース仕様](../../database.md)
- [ライブラリ永続化](../../features/2607312001-library-persistence/spec.md)
