# 警告付き状態で検索0件の空状態が表示されない 課題仕様書

## 文書情報

- 課題ID: 2607312327
- 種別: 不具合（退行）
- 対応する全体要件: FR-008
- ステータス: Completed
- 作成日: 2026-07-31

## 1. 事象

一部のファイルを解析できず警告が出ているライブラリで検索を行い、
該当する楽曲が0件のとき、「該当する楽曲がありません」が表示されない。
警告行だけが残った空のリストが表示される。

## 2. 原因

`lib/features/app_shell/presentation/app_shell_page.dart` の
`switch (libraryViewModel.status)` において、検索0件を判定する

```dart
LibraryStatus.ready
    when searchQuery.trim().isNotEmpty && visibleTracks.isEmpty =>
```

のガードが `LibraryStatus.ready` にしか付いていない。
スキャンエラー分類（`docs/issues/2607312250-scan-error-classification/`）で
追加された `LibraryStatus.readyWithWarnings` には同じガードが無いため、
警告付き状態では検索0件の分岐に入らず `_TrackList` が描画される。

## 3. 再現手順

1. 解析できないファイルを含むフォルダを登録し、警告が表示される状態にする
2. 検索欄に、どの楽曲にも一致しない語を入力する

期待: 「該当する楽曲がありません」が表示される。
実際: 警告行だけの空リストが表示される。

## 4. 要件

- [x] REQ-001: `ready` と `readyWithWarnings` のどちらでも、検索0件の空状態を表示する。
- [x] REQ-002: 警告そのものは引き続き通知する。

## 5. 完了条件

- [x] 両ステータスで検索0件の空状態を表示する。
- [x] Widgetテストで検証する。
- [x] `flutter analyze` と `flutter test` が成功する。

## 6. 実装メモ

`ready` と `readyWithWarnings` は「楽曲一覧を表示できる状態」として同じ扱いになる箇所が
複数あるため、判定を1か所に集約する。

判定は `LibraryViewModel.canShowTracks` に集約し、`_MainContent` の分岐と
アーティスト / アルバム表示の条件で共有する。

警告行は `_TrackList` の先頭要素だったため、検索0件で一覧を描画しないと警告も消えていた。
REQ-002を満たすため、警告を一覧の外（`_WarningNotice`）へ出し、一覧と空状態の
どちらでも表示されるようにする。

## 7. 関連文書

- [ライブラリ検索](../../features/2607312001-library-search/spec.md)
- [スキャンエラー分類](../2607312250-scan-error-classification/spec.md)
