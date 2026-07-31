# ライブラリ読み込みのたびにブックマーク行を書き戻す 課題仕様書

## 文書情報

- 課題ID: 2607312328
- 種別: 不具合（副作用）
- 対応する全体要件: FR-010
- ステータス: Draft
- 作成日: 2026-07-31

## 1. 事象

`PersistentMusicRepository.load()` が、ブックマークの内容が変わっていない場合でも
毎回 `library_folders` へUPDATEを実行する。

`load()` は `updateMetadataMany` と `markRemovedMany` の完了時に毎回呼ばれるため、
メタデータ編集・楽曲削除のたびに不要な書き込みが発生し、
`library_folders.updated_at` が実際の変更と無関係に更新され続ける。

## 2. 原因

`lib/features/library/data/music_repository.dart` の

```dart
if (folderPath != folder.path || bookmark != folder.securityScopedBookmark)
```

において、`bookmark` と `folder.securityScopedBookmark` は `Uint8List`。
`Uint8List` の `!=` は内容比較ではなく**同一性比較**であり、
`restoreBookmark` がMethodChannel経由で返す値は常に新しいインスタンスになるため、
内容が同一でも条件が常に真になる。

## 3. 要件

- [ ] REQ-001: ブックマークの内容が変化した場合だけ書き戻す。
- [ ] REQ-002: パスが変化した場合は従来どおり書き戻す。
- [ ] REQ-003: 読み込み処理が不要な副作用を持たないようにする。

## 4. 完了条件

- [ ] 内容が同一なら書き込みが発生しない。
- [ ] 内容が変化した場合は書き込まれることをテストで検証する。
- [ ] `flutter analyze` と `flutter test` が成功する。

## 5. 実装メモ

`package:flutter/foundation.dart` の `listEquals` で内容比較する。
`load()` が書き込みを行う設計自体は、将来的に読み取りと更新へ分離することが望ましい。
本課題では副作用の発生条件を正すところまでを対象とする。

## 6. 関連文書

- [データベース仕様](../../database.md)
- [macOSブックマーク対応](../2607312311-macos-security-scoped-bookmark/spec.md)
