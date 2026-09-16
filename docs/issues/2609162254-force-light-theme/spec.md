# 表示テーマをライトに固定する

## 文書情報

- 種別: 既存実装の是正（表示設定の変更・ユーザー指示）
- 作成日: 2026-09-16
- 参照: [lib/app/app.dart](../../../lib/app/app.dart)、
  [lib/shared/theme/muzia_theme.dart](../../../lib/shared/theme/muzia_theme.dart)、
  [docs/design_handoff/README.md](../../design_handoff/README.md)

## 事象

`MaterialApp` に `theme`（ライト）と `darkTheme`（ダーク）の両方が設定され、
`themeMode` が未指定（既定 `ThemeMode.system`）のため、OSの外観設定がダークの場合は
ダークテーマで描画される。ユーザーの指示により、OS設定に関わらずライト表示に固定する。

## 原因

是正課題 2608222333 でハンドオフの「full light/dark support」に従い両テーマを用意し、
OS追従を既定としていた。

## 要件との関係（確認事項）

デザインハンドオフ README は「full light/dark support」を掲げており、本変更はこれと
異なる。本課題はユーザーの明示的な指示による表示設定の変更であり、ダークテーマの
トークン定義（`MuziaTheme.dark()` / `MuziaColors.dark`）は削除せず残す。将来ダーク対応を
再度有効にする場合は `themeMode` を `ThemeMode.system` に戻すだけで済む構造を維持する。

## 要件

1. `MaterialApp.themeMode` を `ThemeMode.light` に固定する。
2. `darkTheme` の定義と既存のダークトークンのテストは維持する。
3. OSの外観がダークの状態でもライトテーマで描画されることをWidgetテストで検証する。

## 完了条件

- OS設定がダークモードでもアプリがライトテーマで表示される。
- `flutter analyze` / `flutter test` が通る。
