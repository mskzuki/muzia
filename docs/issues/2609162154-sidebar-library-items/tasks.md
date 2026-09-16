# タスク

前提: [spec.md](spec.md) の確認事項1〜2についてユーザーの合意を得る。

## 実装

- [ ] `LibraryCatalog` にアーティスト数・アルバム数の集約を追加
- [ ] サイドバー項目を「楽曲 / アーティスト / アルバム」に分割し、件数（桁区切り・tabular）を表示
- [ ] 「アルバム」項目の遷移（確認事項1に従う）

## テスト

- [ ] 件数集約の単体テスト
- [ ] サイドバー項目の表示・選択のWidgetテスト（`test/app_shell_design_test.dart`）

## 動作確認

- [ ] `flutter analyze` / `flutter test`
- [ ] `flutter test integration_test -d macos`（スイート個別実行）
- [ ] `01-songs.png` との目視比較
