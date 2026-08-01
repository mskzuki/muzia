# スキャン失敗後に楽曲一覧が中途半端な状態で残る 課題仕様書

## 文書情報

- 課題ID: 2607312329
- 種別: 不具合
- 対応する全体要件: FR-002、FR-003
- ステータス: Completed
- 作成日: 2026-07-31

## 1. 事象

フォルダのスキャンが途中で失敗すると、`LibraryViewModel` が保持する楽曲一覧が
「新しいフォルダの途中までの結果」のまま残る。
永続層（`MusicRepository`）は旧フォルダの内容を保持しているため、
画面の状態と保存されている状態が食い違う。

エラー画面から復帰したときや、後続の操作が `_tracks` を参照したときに、
登録されていない楽曲が表示され得る。

## 2. 原因

`lib/features/library/presentation/library_view_model.dart` の `registerAndScan` は、
スキャン中に受け取った楽曲で `_tracks` を逐次差し替える。

```dart
case TrackFound(:final track):
  tracks.add(track);
  _tracks = List.unmodifiable(tracks);
  notifyListeners();
```

途中で例外が発生すると `_setError` へ遷移するが、`_tracks` は復元されない。
また、全件の解析に失敗した場合も `return` するだけで `_tracks` は戻らない。

## 3. 再現手順

1. 音楽フォルダAを登録し、楽曲が表示される状態にする
2. フォルダBのスキャン中にアクセスエラーを発生させる
3. エラー表示後のViewModelの `tracks` を確認する

期待: フォルダAの内容（＝永続層の内容）と一致する。
実際: フォルダBの途中までの結果が残る。

## 4. 要件

- [x] REQ-001: スキャン失敗時、楽曲一覧を永続層の内容へ戻す。
- [x] REQ-002: 失敗したスキャンの部分的な結果を保存しない。
- [x] REQ-003: 既存のエラー表示は維持する。

## 5. 完了条件

- [x] スキャン失敗後に `tracks` が永続層と一致する。
- [x] 単体テストで検証する。
- [x] `flutter analyze` と `flutter test` が成功する。

## 6. 実装メモ

`registerAndScan` の catch 節および解析全件失敗の分岐で
`_tracks = _repository.tracks` に戻す。

## 7. 関連文書

- [音楽フォルダ登録・初回スキャン](../../features/2607312001-folder-registration-scan/spec.md)
- [スキャンエラー分類](../2607312250-scan-error-classification/spec.md)
