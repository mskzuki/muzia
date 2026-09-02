# タスク

前提: [spec.md](spec.md) の「実装に先立つ確認事項」1〜4の方針でユーザーの合意を得る。→ 2026-09-02 合意済み。

## フェーズ1: デザイントークン層

- [x] `lib/shared/theme/muzia_theme.dart` にトークン定義を実装する
  - [x] 色: accent系(indigo-3/9/10/11)、fg(gray-10/11/12)、面(windowBg/sidebarBg/panel)、
        rowStripe/rowHover/borderSubtle、amber/red系（`DESIGN_TOKENS.md` §1）
  - [x] スペーシング(4pxスケール)・角丸(3/4/6/8/12/16)・タイプスケール（§2〜§4）
  - [x] ライト/ダークの `ThemeData` と `ThemeExtension` を構築し `MuziaApp` に適用
- [x] 既存Widget内の生hexをトークン参照へ置換
      （残: `artist_album_browser.dart` の shadow-2 相当の影色1件。トークン表に
      影色の定義がないためコメントで根拠を明記して許容）
- [x] テーマのユニットテスト（`test/muzia_theme_test.dart`）

## フェーズ2: アプリシェル

- [x] ツールバー: 52px、「楽曲 · N曲」タイトル、右端検索フィールド（`01-songs` 準拠）
- [x] サイドバー: 224px、セクション見出し、アイコン+件数、選択=accent塗り+白文字
- [x] プレイヤーバー: 74px、左=曲情報 / 中央=transport+シークバー / 右=音量
      → 前後スキップ・シーク・音量は再生基盤未対応のため無効状態のUIのみ
      （`TODO(playback)` を記載。機能追加は別課題）
- [x] Widgetテスト更新（`test/app_shell_design_test.dart` ほか）

## フェーズ3: 楽曲一覧テーブル

- [x] テーブル化: 固定ヘッダ・30px行・ゼブラ・ホバー（# / タイトル / アーティスト / アルバム）
      → 「時間」列は再生時間データが `Track` にないため保留（spec.md 確認事項3と同根）
- [x] 行選択: クリック / ⌘(Ctrl)クリック / ⇧クリック、選択行=accent塗り+白文字、
      ダブルクリック再生（チェックボックス列を廃止）
- [x] 選択バー: 2曲以上で一覧上部に表示（accent-a3、「N曲を選択中」+一括編集）
- [x] コンテキストメニュー: 曲を再生 / 曲を編集… / ライブラリから削除…（赤）
      → 削除は右クリック行が選択に含まれる場合、選択全体を対象にする
- [x] 再生中行の強調（accentTextタイトル。イコライザアニメーションは任意のため未実装）
- [x] Widgetテスト更新（`test/track_table_design_test.dart`）

## フェーズ4: 周辺画面のスタイル適合

- [x] 空状態（`08-empty` 準拠のグリフ+説明+フォルダ登録ボタン。
      ドラッグ&ドロップゾーンはMVP範囲外の機能追加になるため見送り）
- [x] 警告バナー（`10-missing` のamberバナー様式。「閉じる/対処」アクションは
      ViewModelに解除APIがないため見送り）
- [x] アーティスト/アルバムブラウザのトークン適用（`03-artists` 準拠のソフト選択）
- [x] ダイアログへのトークン適用（dialogTheme: 角丸12・panel色・FilledButtonテーマ）

## 動作確認

- [x] `flutter analyze`（No issues）
- [x] `flutter test`（73件成功）
- [x] `flutter test integration_test -d macos`（全7件成功。一括実行では2件目以降が
      「Unable to start the app on the device」で起動に失敗するため個別実行で確認。
      変更前から連続起動時に発生しうる環境事象で、本変更とは無関係）
- [x] スクリーンショット比較（`verification/` に実機キャプチャを保存。
      `tool/design_preview_main.dart`（シードデータ起動用の一時エントリポイント）で
      実アプリを起動し、01-songs相当の一覧・行選択・⌘クリック複数選択+選択バー・
      右クリックメニュー・ダブルクリック再生+プレイヤーバーを確認。
      システム外観がダークのためダークテーマでの確認。ライトはWidgetテストで
      トークン値を検証済み）
- [ ] Windowsでの確認 → 本環境はmacOSのためWindowsでの実行不可。未確認として報告
