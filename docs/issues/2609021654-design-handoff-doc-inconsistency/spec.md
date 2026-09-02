# デザインハンドオフ資料内の不整合の是正

## 文書情報

- 種別: 文書の是正（実装対象なし）
- 作成日: 2026-09-02
- 参照: [docs/design_handoff/README.md](../../design_handoff/README.md)、
  `docs/design_handoff/screenshots/`、`docs/design_handoff/reference_html/`

## 事象

1. **索引にないスクリーンショット**: `screenshots/` に `30-fetch-trigger.png` 〜
   `36-partial-fail.png`（アルバムメタデータ取得フロー）が存在するが、READMEの
   スクリーンショット索引は `01`〜`19` のみ。対応する
   `reference_html/Album-Metadata-Fetch.html` / `metadata-fetch.jsx` /
   `metadata-fetch.css` もREADMEの「Files」節に記載がない。
   メタデータ取得はMVP後の機能（requirements.md §7「楽曲名、アルバム名、曲順、
   リリース情報、アルバムアートの表示・取得」）であり、v1.0ハンドオフの
   対象範囲かどうかが資料から判別できない。
2. **フレーム数の記載揺れ**: READMEの「Screens / Views」冒頭は「19 frames」、
   「Files」節は「18 frames」と記載が一致しない。
3. **重複・命名揺れの疑いがあるスクリーンショット**: `17-bulk-dialog.png` と
   `18-bulk-dialog.png`、`18-bulk-confirm.png` と `19-bulk-confirm.png`、
   `16-multi-select.png` と `17-multi-select.png` が併存しており、READMEの索引
   （16-song-edit / 17-multi-select / 18-bulk-dialog / 19-bulk-confirm）と
   番号がずれたファイルが残っている。旧版の消し忘れの可能性がある。

## 原因

ハンドオフ更新時（一括編集フローの3フレーム化、メタデータ取得フローの追加）に
README索引・Files節・旧スクリーンショットの整理が追随していない。

## 実装に先立つ確認事項

1. メタデータ取得フロー（30〜36）はv1.0ハンドオフの対象か、MVP後の先行資料か。
   デザインハンドオフの更新はユーザー（デザイン側）の確認を要するため、
   整理方針（READMEへ「MVP後」の注記付きで索引追加 / 別ディレクトリへ分離 / 削除）
   を確認してから変更する。
2. 番号ずれのスクリーンショット（事象3）はどちらが最新版か。

## 要件

1. READMEのスクリーンショット索引・Files節を実ファイルと一致させる
   （メタデータ取得フローの扱いは確認事項1の決定に従い、MVP範囲外である旨を
   明記する）。
2. フレーム数の記載を実際の数に統一する。
3. 旧版と確認されたスクリーンショットを削除する（確認事項2の決定に従う。
   確認できないものは残し、その旨を注記する）。

## 完了条件

- `screenshots/` / `reference_html/` の全ファイルがREADMEから参照されている、
  または対象外である旨が明記されている。
- フレーム数の記載が統一されている。
- AGENTS.md「デザインハンドオフ」の規定に従い、資料更新による既存画面への影響が
  ないこと（文書のみの変更であること）を作業報告に記載する。
