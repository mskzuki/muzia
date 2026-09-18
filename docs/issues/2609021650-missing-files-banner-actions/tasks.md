# タスク

前提: [spec.md](spec.md) の確認事項1〜2の方針についてユーザーの合意を得る。→ 2026-09-16 推奨案で暫定実装。

## 実装

- [x] トラックの利用不可状態（`Track.isAvailable`、`tracks.unavailable_since`、起動時の検出/解除）
- [x] バナー: 件数表示+「削除…」アクション+閉じる✕（`showsUnavailableBanner` / `dismissUnavailableBanner`）
- [x] 該当行の淡色化・「利用不可」フラグ・時間「—」・再生抑止（SnackBar）
- [x] スキャン失敗警告との表示優先順位の整理（欠損バナーを上に両方表示）

## テスト

- [x] 利用不可の検出・解除の単体テスト（`test/library_availability_test.dart`、リポジトリ/マイグレーションテスト）
- [x] バナー表示/閉じる/削除フローのWidgetテスト（`test/unavailable_tracks_test.dart`）
- [x] 該当行表示のWidgetテスト

## 動作確認

- [x] `flutter analyze`（No issues）/ `flutter test`（143件成功）
- [x] `flutter test integration_test/{persistence,app_shell,playback,removal}_test.dart -d macos`（成功。
      ファイル移動→起動→バナー表示の実機確認は未実施）
- [ ] `10-missing.png` との目視比較（未実施。実機起動での確認が必要）
- [ ] Windowsでの確認（macOS環境のため未実施）
