# タスク

## 実装

- [x] `MuziaColors` に overlay / panelTranslucent / sliderTrack / alertBadge / warnTextStrong を追加（ライト・ダーク）
- [x] ダイアログのスクリムを `overlay` トークンで統一（barrierColor）
- [x] `MuziaShadows`（shadow-1/2/3）を追加し、`artist_album_browser.dart` のハードコード影色を置換
- [x] `MuziaMotion`（カーブ・duration・Reduce Motion ヘルパー）を追加

## テスト

- [x] `test/muzia_theme_test.dart` に追加トークンの検証を追加
      （overlay / shadow / motion / Reduce Motion / ダイアログのスクリム色）

## 動作確認

- [x] `flutter analyze`（No issues）/ `flutter test`（92件成功）
- [ ] ダイアログのスクリム濃度を `18-bulk-dialog.png` と目視比較
      → フェーズ1（2609021645/1646）のダイアログ刷新時にまとめて確認する
