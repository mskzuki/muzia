# 楽曲再生・一時停止 実装タスク

## 実装前

- [x] `media_kit`のmacOS / Windows対応と初期化方法を検証する
- [x] 再生状態のモデルとPlayerViewModelの責務を確定する

## 実装

- [x] `AudioPlayerService`インターフェースと実装を追加する
- [x] 再生・一時停止・エラー状態をPlayerViewModelへ追加する
- [x] プレイヤー領域と操作ボタンを実装する
- [x] ファイル不存在と再生失敗の表示を実装する

## テスト

- [x] Fakeプレイヤーで状態遷移とエラーを単体テストする
- [x] プレイヤーUIの表示と操作をWidgetテストする
- [x] FakeプレイヤーでmacOS Integration Testする。Windowsは環境上未実行。
- [x] `flutter analyze` と `flutter test` を実行する

## 完了

- [x] 完了条件と未実行確認を記録する
