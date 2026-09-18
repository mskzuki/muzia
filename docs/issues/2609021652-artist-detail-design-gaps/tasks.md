# タスク

前提: [spec.md](spec.md) の確認事項1〜2の方針についてユーザーの合意を得る。
→ 2026-09-16 推奨案で暫定実装（spec.md 参照）。2609162155 と同時に実装。

## 実装

- [x] ヒーローの「再生」ボタン（先頭1曲を再生 → 2609021649 で楽曲リストを暗黙キューとする連続再生へ切り替え、2026-09-18）
- [x] アーティスト選択時点での楽曲セクション表示（アルバム選択はアルバム詳細画面へ遷移、2609162155 D1）
- [x] 楽曲行の拡充（28px プレースホルダ・時間・ダブルクリック再生・共通コンテキストメニュー）
- [x] 行スタイルの適合（40px 行、`.ts-row` 準拠）

## テスト

- [x] 楽曲セクションの表示・並び順の単体/Widgetテスト（`test/library_catalog_test.dart` / `test/artist_album_browser_test.dart`）
- [x] 行操作（再生・編集・削除）のWidgetテスト

## 動作確認

- [x] `flutter analyze`（No issues）/ `flutter test`（134件成功）
- [x] `flutter test integration_test/{artist_album,app_shell,search,removal}_test.dart -d macos`（成功）
- [ ] `05-artist-detail.png` との目視比較（未実施。実機起動での確認が必要）
- [ ] Windowsでの確認（macOS環境のため未実施）
