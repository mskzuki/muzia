# タスク

前提: [spec.md](spec.md) の確認事項1〜3の方針についてユーザーの合意を得る。
→ 2026-09-16 質問が中断されたため推奨案で暫定実装（spec.md 参照）。

## 実装

- [x] 検索文字列の正規化（case / diacritic-insensitive）とマッチ方式の整理（`LibrarySearch.normalize` / `matchRank`）
- [x] グループ化された検索結果モデル（`SearchResults`）と表示（件数行+見出し+項目）
- [x] 一致部分のハイライト描画（トークン `highlight` = gold-a4）
- [x] ⌘F（Ctrl+F）フォーカスショートカット
- [x] グループ項目選択時の遷移（ブラウザを該当アーティスト/アルバム選択で開く）

## テスト

- [x] 正規化・マッチ・グルーピング・ハイライト範囲の単体テスト（`test/library_search_test.dart`）
- [x] 検索結果表示・⌘FのWidgetテスト（`test/track_table_design_test.dart`）

## 動作確認

- [x] `flutter analyze`（No issues）/ `flutter test`（128件成功）
- [x] `flutter test integration_test/{search,app_shell,artist_album}_test.dart -d macos`（成功）
- [ ] `14-search.png` との目視比較（未実施。実機起動での確認が必要）
- [ ] Windowsでの確認（Ctrl+F含む。macOS環境のため未実施）
