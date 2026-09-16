# タスク

前提: [spec.md](spec.md) の確認事項1〜5についてユーザーの合意を得る。
[2609162151-theme-token-completion](../2609162151-theme-token-completion/spec.md) の完了後に着手する。

## 実装

- [ ] ツールバー: 件数の桁区切り・fgTertiary（T3）、検索フィールドのスタイル（T4）
- [ ] ツールバー: チェブロンとタイトル位置（T1、確認事項1に従う）
- [ ] テーブル: 行ヘアライン（L1）、ケバブ列（L2、確認事項4に従う）
- [ ] 選択バーの寸法・ボーダー・文字色（L3）
- [ ] コンテキストメニューの先頭アイコン（L4）
- [ ] プレイヤーバー2行目「アーティスト — アルバム」（P1）
- [ ] 削除確認ボタンの destructive 化（D1）
- [ ] 空状態グリフの角丸（D2）、警告バナーの色・ウェイト・ボーダー（D3）
      （2609021651 / 2609021650 側で先に対応した場合はここに記録）

## テスト

- [ ] `test/app_shell_design_test.dart` / `test/track_table_design_test.dart` の更新

## 動作確認

- [ ] `flutter analyze` / `flutter test`
- [ ] `flutter test integration_test -d macos`（スイート個別実行）
- [ ] `01-songs.png` / `14-search.png` / `15-context-menu.png` / `17-multi-select.png` との目視比較
- [ ] Windowsでの確認（実行できない場合は理由を報告）
