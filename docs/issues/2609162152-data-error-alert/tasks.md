# タスク

前提: [spec.md](spec.md) の確認事項1〜3についてユーザーの合意を得る。
[2609162151-theme-token-completion](../2609162151-theme-token-completion/spec.md) の完了後に着手する。

## 実装

- [ ] 致命的エラーの状態を `AppShellViewModel` / `LibraryViewModel` で区別できるようにする
- [ ] スクリム+中央アラートのWidget（296px、角丸12、バッジ、縦積みボタン）
- [ ] ボタンの動作（再試行 / 終了 / 保存場所を開く。再構築は確認事項2に従う）
- [ ] Esc / Enter のキーボード対応

## テスト

- [ ] アラート表示条件・ボタン動作のWidgetテスト

## 動作確認

- [ ] `flutter analyze` / `flutter test`
- [ ] `12-error.png` との目視比較
- [ ] Windowsでの確認（Explorerで開く動作。実行できない場合は理由を報告）
