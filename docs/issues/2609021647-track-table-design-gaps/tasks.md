# タスク

前提: [spec.md](spec.md) の確認事項1〜2の方針についてユーザーの合意を得る。
→ 2026-09-16 合意済み（タイトル/アーティスト/アルバム/時間の昇降順、永続化なし、
イコライザは Reduce Motion で静止）。前提課題 2609021644 はコミット `17a2fa0` で完了。

## 実装

- [x] 時間列の追加（56px・右寄せ・tabular・null時「—」）と時間フォーマッタ（`domain/track_sort.dart` `formatTrackDuration`）
- [x] 再生中行のイコライザ（3本バー、再生中のみアニメーション、一時停止と Reduce Motion で静止）
- [x] 列ソート（ヘッダクリック、方向インジケータ、`sortTracks` に分離。未設定値は常に末尾）
- [x] ⌘I（Ctrl+I）ショートカットとメニュー表記（1曲選択で曲編集、2曲以上で一括編集）

## テスト

- [x] 時間フォーマット・ソートロジックの単体テスト（`test/track_sort_test.dart`）
- [x] イコライザ表示切替・列ソート・⌘IのWidgetテスト（`test/track_table_design_test.dart`）

## 動作確認

- [x] `flutter analyze`（No issues）/ `flutter test`（119件成功）
- [x] `flutter test integration_test/{app_shell,playback}_test.dart -d macos`（成功）
- [ ] `01-songs.png` との目視比較（未実施。実機起動での確認が必要）
- [ ] Windowsでの確認（Ctrl+I含む。macOS環境のため未実施）
