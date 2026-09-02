# タスク

前提: [spec.md](spec.md) の確認事項1〜3の方針についてユーザーの合意を得る。

## 実装

- [ ] 検索文字列の正規化（case / diacritic-insensitive）とマッチ方式の整理
- [ ] グループ化された検索結果モデルと表示（見出し+項目）
- [ ] 一致部分のハイライト描画（gold系トークン）
- [ ] ⌘F（Ctrl+F）フォーカスショートカット
- [ ] グループ項目選択時の遷移（確認事項2の方針に従う）

## テスト

- [ ] 正規化・マッチ・グルーピング・ハイライト範囲の単体テスト
- [ ] 検索結果表示・⌘FのWidgetテスト

## 動作確認

- [ ] `flutter analyze` / `flutter test`
- [ ] `flutter test integration_test -d macos`（検索フロー）
- [ ] `14-search.png` との目視比較
- [ ] Windowsでの確認（実行できない場合は理由を報告）
