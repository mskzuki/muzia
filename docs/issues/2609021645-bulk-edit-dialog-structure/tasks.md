# タスク

前提: [spec.md](spec.md) の「実装に先立つ確認事項」1〜3の方針についてユーザーの合意を得る。
→ 2026-09-16 合意済み（spec.md 末尾の「合意と実装方針」参照）。

## 実装

- [x] チェックボックス方式を廃止し、4フィールド常時表示に変更
      （空欄=変更しない。共通値はプレースホルダ表示）
- [x] 「選択していない同じアルバムの曲も含めて変更する」チェックボックスと
      分割/リネームの適用ロジック（`domain/bulk_edit_plan.dart` の `planBulkEdit`）
- [x] 既存アルバム名への変更ブロックとエラーメッセージ（`LibraryCatalog.albums` を追加）
- [x] リリース年の4桁数値バリデーション
- [x] ジャンルフィールド+サジェストチップ
- [x] 確認ダイアログの文面を分割/リネーム説明+「ファイルには書き込まれません…」に変更
      （`presentation/bulk_edit_confirm_dialog.dart`。「戻る」で入力を保って再表示）
- [x] ヘッダ（チップ「N 曲を選択中」+対象名+✕）とダイアログ様式の適合（440px、`MuziaDialog` 流用）

## テスト

- [x] 分割（部分選択→新アルバム名）のロジックテスト（`test/bulk_edit_plan_test.dart`）
- [x] リネーム（チェックあり/全曲選択）のロジックテスト
- [x] 既存アルバム名ブロックのテスト
- [x] ダイアログのWidgetテスト更新（常時表示・確認文面・戻る/適用）

## 動作確認

- [x] `flutter analyze`（No issues）/ `flutter test`（110件成功）
- [x] `flutter test integration_test/{app_shell,metadata_editing}_test.dart -d macos`（成功。
      一括編集フロー専用のIntegration Testは既存になく、追加は 2609162150 の全体確認で検討）
- [ ] `18-bulk-dialog.png` / `19-bulk-confirm.png` との目視比較（未実施。実機起動での確認が必要）
- [ ] Windowsでの確認（macOS環境のため未実施）
