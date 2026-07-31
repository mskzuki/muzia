# 楽曲再生・一時停止 実装タスク

## 実装前

- [ ] `media_kit`のmacOS / Windows対応と初期化方法を検証する
- [ ] 再生状態のモデルとPlayerViewModelの責務を確定する

## 実装

- [ ] `AudioPlayerService`インターフェースと実装を追加する
- [ ] 再生・一時停止・エラー状態をPlayerViewModelへ追加する
- [ ] プレイヤー領域と操作ボタンを実装する
- [ ] ファイル不存在と再生失敗の表示を実装する

## テスト

- [ ] Fakeプレイヤーで状態遷移とエラーを単体テストする
- [ ] プレイヤーUIの表示と操作をWidgetテストする
- [ ] テスト音源でmacOS / Windowsの再生・一時停止をIntegration Testする
- [ ] `flutter analyze` と `flutter test` を実行する

## 完了

- [ ] 完了条件と未実行確認を記録する

