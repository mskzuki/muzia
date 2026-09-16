# タスク

前提: [spec.md](spec.md) の確認事項1〜4についてユーザーの合意を得る。
[2609162151-theme-token-completion](../2609162151-theme-token-completion/spec.md) の完了後、
[2609021652](../2609021652-artist-detail-design-gaps/spec.md) と同一ブランチで着手する。

## 実装

- [ ] `LibraryCatalog.tracksFor` のトラック番号順ソート（D3）と # のトラック番号表示
- [ ] アーティスト全体のメタ集約（アルバム数・曲数・代表ジャンル・合計時間）（H2）
- [ ] アーティスト一覧ペイン: 幅 332px、サブヘッダ行、ヘアライン（A1）、行のインセット・選択スタイル（A2）、行の内容（A3）
- [ ] アーティストヒーロー: アバター 124px+shadow-3、下端区切り線（H1）
- [ ] アルバムセクション: 4カラムグリッド・ホバー影・選択表現（G1）、フッターの年表示（G2）
- [ ] アルバム詳細: ヒーロー（D1）とトラックリストヘッダ（D2）

## テスト

- [ ] ソート・メタ集約の単体テスト（`test/library_catalog_test.dart`）
- [ ] アルバム詳細表示・グリッドのWidgetテスト

## 動作確認

- [ ] `flutter analyze` / `flutter test`
- [ ] `flutter test integration_test -d macos`（スイート個別実行）
- [ ] `03-artists.png` / `05-artist-detail.png` / `06-album-detail.png` との目視比較
- [ ] Windowsでの確認（実行できない場合は理由を報告）
