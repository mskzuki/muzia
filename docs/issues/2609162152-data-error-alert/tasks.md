# タスク

前提: [spec.md](spec.md) の確認事項1〜3についてユーザーの合意を得る。→ 2026-09-16 推奨案で暫定実装。
[2609162151-theme-token-completion](../2609162151-theme-token-completion/spec.md) の完了後に着手する。

## 実装

- [x] 既存の error 状態を対象にし、`LibraryViewModel.initialize` をエラー後に再実行可能にした
- [x] スクリム+中央アラートのWidget（`presentation/data_error_alert.dart`）
- [x] ボタンの動作（再試行 / 終了。再構築・保存場所を開くは見送り）
- [x] Enter で再試行（閉じる操作はないため Esc は割り当てない）

## テスト

- [x] アラート表示条件・ボタン動作のWidgetテスト（`test/data_error_alert_test.dart`）

## 動作確認

- [x] `flutter analyze`（No issues）/ `flutter test`（145件成功）
- [ ] `12-error.png` との目視比較（未実施。実機起動での確認が必要）
- [ ] Windowsでの確認（macOS環境のため未実施。「保存場所を開く」は見送りのため対象外）
