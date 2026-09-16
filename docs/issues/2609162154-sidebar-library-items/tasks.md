# タスク

前提: [spec.md](spec.md) の確認事項1〜2についてユーザーの合意を得る。→ 2026-09-16 合意済み。

## 実装

- [x] `LibraryCatalog` のアーティスト数・アルバム数を利用（`albums` は 2609021645 で追加済み）
- [x] サイドバー項目を「楽曲 / アーティスト / アルバム」に分割し、件数（桁区切り・tabular・11px）を表示
- [x] 「アルバム」項目の遷移（アーティスト/アルバムブラウザを開く。ツールバータイトルも切り替え）

## テスト

- [x] 桁区切りの単体テスト（`test/count_format_test.dart`）
- [x] サイドバー項目の表示・選択のWidgetテスト（`test/app_shell_design_test.dart`）

## 動作確認

- [x] `flutter analyze`（No issues）/ `flutter test`
- [x] `flutter test integration_test/artist_album_test.dart -d macos`（サイドバー項目名の変更に合わせて更新）
- [ ] `01-songs.png` との目視比較（未実施。実機起動での確認が必要）
