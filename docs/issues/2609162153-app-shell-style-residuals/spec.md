# アプリシェルの残スタイル差分（ツールバー・テーブル・選択バー・プレイヤー・ダイアログ）

## 文書情報

- 種別: 既存実装の是正（UIデザイン適合・スタイル微調整）
- 作成日: 2026-09-16
- 参照: [docs/design_handoff/README.md](../../design_handoff/README.md) §1・§14・Layout skeleton、
  `screenshots/01-songs.png` / `14-search.png` / `15-context-menu.png` / `17-multi-select.png`、
  `reference_html/app.css`（px値の正）
- 前提課題: [2609162151-theme-token-completion](../2609162151-theme-token-completion/spec.md)
  （amber-12 / gray-a4 / shadow-2）
- 上位計画: [2609162150-design-alignment-phase2-plan](../2609162150-design-alignment-phase2-plan/spec.md)

## 事象

是正課題 2608222333 で構造は適合したが、2026-09-16 の突合で以下のスタイル差分が
残っていることを確認した。いずれも既存issue（2609021645〜1654）の要件に含まれていない。
実装箇所は特記なき限り `lib/features/app_shell/presentation/app_shell_page.dart`。

### ツールバー

| # | デザイン | 現状 |
|---|---|---|
| T1 | 戻る/進むチェブロン（‹ ›）の後、コンテンツ列の上にタイトル | チェブロンなし。タイトルは AppBar 左端（サイドバー上） |
| T2 | 検索フィールド左に ⋯（more）ボタン | なし |
| T3 | 件数「8,214 songs · 61.4 GB」（桁区切り、fgTertiary） | 「8214曲」（桁区切りなし、fgSecondary） |
| T4 | 検索フィールド 196×26、角丸4、非フォーカス時 gray-a3 塗り・枠なし、フォーカス時 白背景+インセットヘアライン+accent-a4 3px リング | 240×30、角丸6、常時 windowBg 塗り+borderSubtle 枠、フォーカス時 accent 2px 実線 |

### 楽曲テーブル・選択バー・メニュー

| # | デザイン | 現状 |
|---|---|---|
| L1 | 各セル下端に 0.5px gray-a2 ヘアライン（選択行は透明） | ゼブラとホバーのみ、区切り線なし |
| L2 | 各行の最右列に縦ケバブ（⋮、36px、fgTertiary、ホバーで fgSecondary、選択行は白82%） | なし。メニューは右クリックのみ |
| L3 | 選択バー: 高さ44px固定、padding 0 14 0 18、下辺 0.5px accent-a5、件数テキスト 13/medium fgPrimary | 縦padding 4px（高さ非固定）、下ボーダーなし、件数テキストが accentText |
| L4 | コンテキストメニュー各項目に先頭アイコン（▶ / 鉛筆 / ✕、幅15px） | テキストのみ |

### プレイヤーバー

| # | デザイン | 現状 |
|---|---|---|
| P1 | 2行目「アーティスト — アルバム」（12px fgSecondary） | アーティスト名のみ |
| P2 | 左右セクション 290px、中央 max-width 540px の flexible、コントロール間 gap 18、上罫線 0.5px、トラック gray-a4、ノブ 白11px+shadow-2、前後アイコン 19px / 再生内アイコン 16px | 左右 240px、シーク固定 420px、gap 4px+IconButton既定、上罫線 1px、トラック borderSubtle、ノブ windowBg 10px 影なし、アイコン一律 18px |

### ダイアログ・周辺画面

| # | デザイン | 現状 |
|---|---|---|
| D1 | 「ライブラリから削除」は destructive（red-11） | `library_removal_dialog.dart` の確定ボタンがテーマ既定の accent 塗り（`colorScheme.error` は定義済みだが未使用） |
| D2 | 空状態グリフの角丸 radius-5（12px） | `MuziaRadius.r6`（16px） |
| D3 | 警告バナー本文 amber-12、件数リード部のみ bold 700、下辺 0.5px amber-a5 | タイトル・本文とも amber-11、リード w500、下辺 borderSubtle |

## 原因

是正課題 2608222333 が構造・配色の適合を優先し、px単位のメトリクスと補助的な
要素（チェブロン、⋯、ケバブ、アイコン）を後回しにしたため。

## 実装に先立つ確認事項

1. **T1 チェブロンの機能範囲**: MVPのナビゲーションはサイドバー選択とアーティスト→
   アルバムの絞り込みのみ。チェブロンを「アーティスト/アルバムブラウザ内の選択履歴の
   戻る/進む」に限定して実装するか、履歴がない間は無効表示のUI枠のみとするか。
2. **T2 ⋯ボタン**: ハンドオフはメニュー内容を定義していない。内容が決まるまで
   見送る（本課題の対象外とする）方針で良いか。
3. **T3 合計サイズ**: ファイルサイズは `Track` に保持していない。桁区切りと色のみ
   適合させ、合計サイズ表示はモデル拡張とあわせて別途判断する方針で良いか。
4. **L2 ケバブ列**: ハンドオフ内で常設列か複数選択時限定かが曖昧
   （[2609021654](../2609021654-design-handoff-doc-inconsistency/spec.md) 事象7）。
   資料側の確認結果に従う。
5. **P2 プレイヤーバーの寸法**: transport 有効化（[2609021649](../2609021649-player-transport-enablement/spec.md)）
   と同じ箇所を触るため、同課題の実装時に合わせて調整する（本課題では要件のみ定義）。

## 要件

1. T3（桁区切り・fgTertiary）、T4、L1、L3、L4、P1、D1、D2、D3 を `app.css` の値に合わせる。
2. T1 は確認事項1の決定に従い、チェブロンとタイトル位置を適合させる。
3. L2 は確認事項4の決定に従い、ケバブ列を追加してコンテキストメニューと同じ項目を開く。
4. P2 は 2609021649 の実装時に本仕様の値を適用する。
5. D2 は [2609021651](../2609021651-empty-state-drop-zone/spec.md)、D3 は
   [2609021650](../2609021650-missing-files-banner-actions/spec.md) の実装と同時に
   行っても良い（重複作業を避けるため、先に着手した側で対応し tasks.md に記録する）。
6. 既存の Widget テスト（`test/app_shell_design_test.dart` / `test/track_table_design_test.dart`）
   を更新し、変更した寸法・色を検証する。

## 完了条件

- `01-songs.png` / `14-search.png` / `15-context-menu.png` / `17-multi-select.png` と
  実機表示を並べ、上記の各項目が一致する（MVP範囲外の列・ボタンの不在は許容）。
- `flutter analyze` / `flutter test` が通る。
- 確認事項1〜5の判断が作業報告に記載されている。
