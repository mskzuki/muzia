# タスク

前提: [spec.md](spec.md) の確認事項1〜2の方針についてユーザーの合意を得る。

## 実装

- [ ] `AudioPlayerService` に位置/総時間ストリーム・シーク・音量・完了イベントを追加
- [ ] `media_kit` 実装で上記APIを提供
- [ ] PlayerViewModel: 位置購読・シーク・音量・暗黙キュー（表示中一覧順）・自動次曲送り
- [ ] UI: シークバー有効化+時間表示、前後ボタン有効化、音量スライダー
- [ ] 音量の永続化
- [ ] `TODO(playback)` の解消

## テスト

- [ ] PlayerViewModelの単体テスト（シーク・曲送り・末尾停止・音量）
- [ ] プレイヤーバーのWidgetテスト更新

## 動作確認

- [ ] `flutter analyze` / `flutter test`
- [ ] `flutter test integration_test -d macos`（再生フロー）
- [ ] Windowsでの確認（実行できない場合は理由を報告）
