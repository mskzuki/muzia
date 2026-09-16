# サイドバーのライブラリ項目構成と件数表示

## 文書情報

- 種別: 既存実装の是正（UIデザイン適合）
- 作成日: 2026-09-16
- 参照: [docs/design_handoff/README.md](../../design_handoff/README.md) Layout skeleton「Sidebar」、
  `screenshots/01-songs.png`、`reference_html/app.css`（`.side-item .cnt`）、
  [docs/requirements.md](../../requirements.md) §7・§10
- 上位計画: [2609162150-design-alignment-phase2-plan](../2609162150-design-alignment-phase2-plan/spec.md)

## 事象

デザインのサイドバー LIBRARY セクションは Songs / Artists / Albums / Genres の4項目で、
各項目の右端に桁区切り・tabular figures の件数（8,214 / 412 / 736 / 24）を表示する。

現在の実装（`app_shell_page.dart` サイドバー部）は「楽曲」（件数あり）と、結合された
「アーティスト / アルバム」（件数 `null`）の2項目のみで、件数に桁区切りがない。
requirements.md §10 の画面構成初期案も「ライブラリ / アーティスト / アルバム」を
個別項目として挙げている。

Genres と PLAYLISTS セクションはMVP後（requirements.md §7）のため対象外とする。

## 原因

アーティスト/アルバムブラウザが「アーティスト→アルバム」の2ペイン1画面として実装され、
サイドバー項目もそれに合わせて結合された。

## 実装に先立つ確認事項

1. **「アルバム」項目の遷移先**: requirements.md §7 のMVPは「アーティストごとに
   アルバムを一覧表示」のみで、アルバム単独のグリッド画面（`02-albums`）は明示されて
   いない。本課題では「アルバム」項目を追加し、選択時はアーティスト/アルバムブラウザ
   を開く（グリッド画面はMVP後）方針で良いか。
2. **件数の定義**: アーティスト数・アルバム数は `LibraryCatalog` の集約（削除済み
   楽曲を除く）を用いる。

2026-09-16 の合意: 確認事項1 は「アーティスト/アルバムブラウザを開く」（グリッド画面は
MVP後）、確認事項2 は記載どおり `LibraryCatalog.artists` / `LibraryCatalog.albums` の件数。
桁区切りは `lib/shared/format/count_format.dart` の `formatCount` で行う。

## 要件

1. サイドバーの LIBRARY セクションを「楽曲 / アーティスト / アルバム」の3項目にし、
   各項目に右寄せ・tabular figures・桁区切りの件数を表示する。
2. 「アーティスト」「アルバム」の遷移先は確認事項1の決定に従う。選択状態
   （accent 塗り+白文字）は既存の項目と同じ表現にする。
3. 件数の算出は `LibraryCatalog` 側に置き、単体テストで検証する。

## 完了条件

- `01-songs.png` と実機表示を並べ、サイドバー項目の構成・件数表示が一致する
  （Genres / PLAYLISTS の不在はMVP範囲判断として許容）。
- 件数算出の単体テストと、項目選択のWidgetテストがある。
- `flutter analyze` / `flutter test` が通る。
- 確認事項1〜2の判断が作業報告に記載されている。
