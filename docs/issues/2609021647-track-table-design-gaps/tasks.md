# タスク

前提: [spec.md](spec.md) の確認事項1〜2の方針についてユーザーの合意を得る。
時間列は前提課題 2609021644（`durationMs`）の完了後に着手する。

## 実装

- [ ] 時間列の追加（56px・右寄せ・tabular・null時「—」）と時間フォーマッタ
- [ ] 再生中行のイコライザ（3本バー、再生中のみアニメーション、Reduce Motion対応）
- [ ] 列ソート（ヘッダクリック、方向インジケータ、ロジック分離）
- [ ] ⌘I（Ctrl+I）ショートカットとメニュー表記

## テスト

- [ ] 時間フォーマット・ソートロジックの単体テスト
- [ ] イコライザ表示切替・⌘IのWidgetテスト

## 動作確認

- [ ] `flutter analyze` / `flutter test`
- [ ] `flutter test integration_test -d macos`
- [ ] `01-songs.png` との目視比較
- [ ] Windowsでの確認（Ctrl+I含む。実行できない場合は理由を報告）
