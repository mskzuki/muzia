# タスク

前提: [spec.md](spec.md) の確認事項1〜5についてユーザーの合意を得る。→ 2026-09-16 合意済み。
[2609162151-theme-token-completion](../2609162151-theme-token-completion/spec.md) の完了後に着手する。

## 実装

- [x] ツールバー: 件数の桁区切り・fgTertiary（T3）、検索フィールドのスタイル（T4、196×26・gray-a3塗り・フォーカスリング）
- [x] ツールバー: タイトル位置をコンテンツ列上へ（T1。チェブロンは見送り）
- [x] テーブル: 行ヘアライン（L1）、常設のケバブ列（L2）
- [x] 選択バーの寸法・ボーダー・文字色（L3。文言を「N 曲を選択中」に統一）
- [x] コンテキストメニューの先頭アイコン（L4）
- [x] プレイヤーバー2行目「アーティスト — アルバム」（P1）
- [x] 削除確認ボタンの destructive 化（D1）
- [x] 空状態グリフの角丸（D2）、警告バナーの色・ウェイト・ボーダー（D3）
- [x] プレイヤーバーの寸法（P2）→ 2609021649 で適用（2026-09-18）

## テスト

- [x] `test/app_shell_design_test.dart` / `test/track_table_design_test.dart` / `test/library_removal_dialog_test.dart` / `test/muzia_theme_test.dart` の更新

## 動作確認

- [x] `flutter analyze`（No issues）/ `flutter test`（122件成功）
- [x] `flutter test integration_test/{app_shell,search,removal}_test.dart -d macos`（成功）
- [ ] `01-songs.png` / `14-search.png` / `15-context-menu.png` / `17-multi-select.png` との目視比較（未実施。実機起動での確認が必要）
- [ ] Windowsでの確認（macOS環境のため未実施）
