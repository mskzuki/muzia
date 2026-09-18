# データエラー表示のモーダルアラート化（12-error）

## 文書情報

- 種別: 既存実装の是正（UIデザイン適合）
- 作成日: 2026-09-16
- 参照: [docs/design_handoff/README.md](../../design_handoff/README.md) §12、
  `screenshots/12-error.png`、`reference_html/app.css`（`.alert` / `.modal-scrim`）、
  `reference_html/screens3.jsx`
- 前提課題: [2609162151-theme-token-completion](../2609162151-theme-token-completion/spec.md)
  （`overlay` / `alertBadge` トークン）
- 上位計画: [2609162150-design-alignment-phase2-plan](../2609162150-design-alignment-phase2-plan/spec.md)

## 事象

デザイン §12 は、ライブラリDBを開けない場合に、ディム/デサチュレートされた一覧の
上へ 296px の macOS 風アラート（角丸12・shadow-6、アプリアイコン+赤警告バッジ、
タイトル、「音楽ファイルは無傷・再構築で再スキャンされる」旨のメッセージ、
縦積みボタン: 再構築（primary）/ 終了（secondary）/ Finderで表示（link））を重ねる。

現在の実装（`app_shell_page.dart` `_StatusMessage`、`AppShellStatus.error` /
`LibraryStatus.error`）はコンテンツ領域全体を汎用アイコン+「読み込みエラー」に
差し替えるのみで、

- モーダルではなくインライン表示で、背後に一覧が残らない
- 復旧アクション（再構築 / 終了 / 保存場所を開く）がない
- 「ファイルは無傷」という安心メッセージがない

requirements.md §7 の「基本的なエラー表示」はMVP範囲であり、既存issue群のいずれも
`12-error` を参照していない（未カバー）。

## 原因

エラー状態がローディング・空状態と同じ `_StatusMessage` で汎用実装され、
デザイン §12 の「データ破損は明示的に表出する」方針が反映されていない。

## 実装に先立つ確認事項

1. **アラート化の対象**: DB を開けない・破損している致命的エラーのみを対象とし、
   スキャン失敗などの回復可能な警告は既存バナーのままとする方針で良いか。
2. **「再構築」の範囲**: DBファイルを退避して新規作成し、登録フォルダを再スキャンする
   機能は現状存在しない。MVPでは「再試行」+「終了」に留め、「再構築」はリポジトリ層の
   API追加とあわせて実装するか判断する（ユーザーの音楽ファイルには一切触れない）。
3. **「Finderで表示」**: macOSはFinder、WindowsはExplorerでDBの保存場所を開く。
   `url_launcher` 等の新規パッケージ導入の可否。

2026-09-16 の暫定判断（質問が中断されたため推奨案で実装。異議があれば修正する）:

- 確認事項1: `AppShellStatus.error` / `LibraryStatus.error`（読み込み・保存に失敗し
  一覧を表示できない状態）をアラートの対象とし、スキャン失敗などの警告は既存バナーのまま。
- 確認事項2: 「再構築」はリポジトリ層の API が無いため見送り。ボタンは「再試行」
  （`LibraryViewModel.initialize` の再実行）と「終了」。
- 確認事項3: 「Finderで表示」は新規パッケージ導入が必要なため見送り。
- 補足: 背後には最後に読み込めた一覧（なければ空）を残し、操作不可にしてスクリムで覆う。
  アプリアイコンはブランド未決定のためグラデーションのプレースホルダ。

## 要件

1. 致命的エラー時に、コンテンツ領域を残したまま `overlay` スクリムを重ね、中央に
   296px 幅のアラート（角丸12、`panel` 背景、shadow-6 相当）を表示する。
2. アラートはアイコン+赤バッジ（`alertBadge`）、タイトル、本文（音楽ファイルは
   変更されない旨を含む）、縦積みボタンで構成する。ボタンの構成は確認事項2〜3の
   決定に従う。primary は `FilledButton`、secondary は soft、link は `TextButton`。
3. Esc / Enter のキーボード操作に対応する（Enter = primary）。
4. Widget テストでアラートの表示条件とボタンの動作を検証する。

## 完了条件

- `12-error.png` と実機表示を並べ、スクリム・アラート構成が一致する
  （アプリアイコンの実画像はブランド未決定のためプレースホルダを許容）。
- 致命的エラー以外の状態では従来表示が維持されている。
- `flutter analyze` / `flutter test` が通る。
- 確認事項1〜3の判断が作業報告に記載されている。
