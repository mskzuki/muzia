# デザイントークンの補完（overlay / shadow / motion / 補助色）

## 文書情報

- 種別: 既存実装の是正（デザイントークン層の補完）
- 作成日: 2026-09-16
- 参照: [docs/design_handoff/DESIGN_TOKENS.md](../../design_handoff/DESIGN_TOKENS.md) §1・§4〜§6、
  [docs/issues/2608222333-design-handoff-alignment](../2608222333-design-handoff-alignment/spec.md)
- 上位計画: [2609162150-design-alignment-phase2-plan](../2609162150-design-alignment-phase2-plan/spec.md)

## 事象

是正課題 2608222333 で `lib/shared/theme/muzia_theme.dart` にトークン層を導入したが、
当時の画面が参照する値のみ定義されており、`DESIGN_TOKENS.md` に定義のある以下の
トークンが存在しない。後続のデザイン適合課題がこれらを必要とする。

| トークン | デザイン定義 | 現状 | 影響する課題 |
|---|---|---|---|
| `overlay` | モーダルスクリム black-a6（ライト約30%黒）/ black-a8（ダーク） | 未定義。全ダイアログの `barrierColor` がFlutter既定の `black54`（約54%黒） | 全ダイアログ、2609162152 |
| `panelTranslucent` | `rgba(255,255,255,0.7)` シートフッター | 未定義 | ダイアログ様式（2609021645/1646） |
| `gray-a4` | スライダートラック背景 | 未定義。`borderSubtle`（gray-a6）で代用 | 2609021649、2609162153 |
| `red-9` | `#E5484D` アラートバッジ背景 | 未定義（red-11 の `destructive` のみ） | 2609162152 |
| `amber-12` | `#4F3422` 警告バナー本文 | 未定義。`warnText`（amber-11）で代用 | 2609021650、2609162153 |
| `shadow-1/2/3` | 入力インセット / カード / ホバー浮き上がり | 未定義。`artist_album_browser.dart` に shadow-2 相当の影色がハードコード | 2609162155 |
| motion | curve `cubic-bezier(0.16, 1, 0.3, 1)`、open 160ms / close 100ms、Reduce Motion 対応 | 未定義 | 2609021647（イコライザ）、ダイアログ |
| Inspector title | 17px / 700 | 未定義（Inspector画面自体が未実装） | なし（任意） |

gold 系（検索ハイライト）は [2609021648](../2609021648-search-grouping-highlight/spec.md) が、
音質ティア色（Hi-Res / Lossless / Lossy）はMVP後のため本課題の対象外とする。

## 原因

トークン層の導入時に、画面から参照される値だけを定義し、`DESIGN_TOKENS.md` との
網羅性チェックを行っていなかった。

## 要件

1. `MuziaColors` に `overlay` / `panelTranslucent` / `sliderTrack`（gray-a4）/
   `alertBadge`（red-9）/ `warnTextStrong`（amber-12）をライト・ダーク両方で追加する。
2. `DialogThemeData.barrierColor`（または `showDialog` の共通ラッパー）で `overlay` を
   適用し、単曲編集・一括編集・削除確認の全ダイアログのスクリムをトークン化する。
3. `MuziaShadows`（shadow-1/2/3）を定義し、`artist_album_browser.dart` の
   ハードコードされた影色を置き換える。
4. `MuziaMotion`（カーブ・open/close duration）を定義し、
   `MediaQuery.disableAnimationsOf` を考慮して duration を返すヘルパーを用意する。
5. `test/muzia_theme_test.dart` に追加トークンの値検証を追加する。

## 完了条件

- `DESIGN_TOKENS.md` §1・§5・§6 の各項目が `muzia_theme.dart` に対応定義を持つ
  （対象外のものはコメントで理由を明記）。
- Widget 内に影色・スクリム色の生値が残っていない。
- `flutter analyze` / `flutter test` が通る。
