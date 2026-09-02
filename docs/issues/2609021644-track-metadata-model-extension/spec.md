# 楽曲メタデータモデルの拡張（再生時間・トラック番号・リリース年・ジャンル）

## 文書情報

- 種別: 既存実装の是正（デザインハンドオフが前提とするデータの不足）
- 作成日: 2026-09-02
- 参照: [docs/design_handoff/README.md](../../design_handoff/README.md) §1・§14、
  `screenshots/01-songs.png` / `16-song-edit.png` / `18-bulk-dialog.png`、
  [docs/issues/2608222333-design-handoff-alignment/spec.md](../2608222333-design-handoff-alignment/spec.md) 確認事項3

## 事象

デザインハンドオフのMVP範囲の画面が前提とするデータを、現在の `Track` / DBスキーマが
保持していない。

- **再生時間**: 楽曲一覧の「時間」列（デザインでは56px右寄せ・tabular）。
  是正課題 2608222333 で「データがないため保留」とされたまま。
- **トラック番号**: 曲編集ダイアログ（`16-song-edit`）の「トラック」フィールド。
- **リリース年**: デザインは4桁 `YYYY` の構造化された年。現在は自由記述の
  `releaseInfo` 1項目のみ。
- **ジャンル**: 曲編集・一括編集ダイアログの「ジャンル」フィールド
  （単一値+既存ジャンルのサジェストチップ）。

現在の `Track`（[lib/features/library/domain/track.dart](../../../lib/features/library/domain/track.dart)）は
`filePath / fileExtension / title / artist / album / releaseInfo / isRemoved` のみ。

## 原因

MVP初期実装はFR-004の「最低限」の項目（タイトル/アーティスト/アルバム/リリース情報）
のみを対象にモデルを設計しており、デザイン確定後に必要になった項目が反映されていない。

## 実装に先立つ確認事項

1. **要件との関係**: FR-004 / FR-011 は「最低限、以下の項目を扱う」であり、項目追加は
   矛盾しない。ただしトラック番号・ジャンル・再生時間を正式に扱うなら
   `docs/requirements.md` FR-004（表示）・FR-011（編集対象）への追記が望ましい。
   要件更新の要否をユーザーに確認し、更新する場合は変更内容を作業報告に記載する。
2. **`releaseInfo` との関係**: デザインの「リリース年」は4桁年。既存の `releaseInfo`
   （自由記述）を年として解釈できる場合は移行し、解釈できない値は保持したまま
   年を未設定として扱う方針とする（データを破棄しない）。
3. **品質情報（フォーマット/サンプルレート/ビット深度）・アートワーク・お気に入り**は
   MVP後（requirements.md §7）のため本課題の対象外とする。

## 要件

1. `Track` に以下を追加する（すべてnullable）。
   - `durationMs`（int?）: 再生時間（ミリ秒）
   - `trackNumber`（int?）: トラック番号
   - `releaseYear`（int?）: リリース年（4桁）
   - `genre`（String?）: ジャンル（単一値）
2. DBスキーマ（`library_database.dart`）に同項目の列を追加し、マイグレーションを行う。
   既存レコードは新項目をnullとして読み込めること。
3. メタデータ解析（`metadata_service.dart`）で、タグから取得できる場合は
   再生時間・トラック番号・年・ジャンルを取り込む。取得できない場合はnull。
4. `MetadataValues` / `MetadataField` に編集可能項目として
   `trackNumber` / `releaseYear` / `genre` を追加する
   （UIへの反映は課題 2609021645 / 2609021646 で行う）。
5. ライブラリ全体から既存ジャンルの一覧（重複なし・ソート済み）を取得するAPIを
   用意する（編集ダイアログのサジェストチップ用）。
6. 元の音楽ファイルへの書き込みは行わない（FR-014）。

## 完了条件

- 新項目を含む楽曲の登録→再起動→読み込みで値が保持される（永続化テスト）。
- タグに各項目を持つテスト用音源で、スキャン後に値が取り込まれる。
- 既存DBからのマイグレーションで既存データが失われない（テストで検証）。
- `flutter analyze` / `flutter test` が通る。
