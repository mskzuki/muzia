# タスク

前提: [spec.md](spec.md) の確認事項1〜4についてユーザーの合意を得る。→ 2026-09-16 推奨案で暫定実装。
[2609162151-theme-token-completion](../2609162151-theme-token-completion/spec.md) の完了後、
[2609021652](../2609021652-artist-detail-design-gaps/spec.md) と同一ブランチで着手する。

## 実装

- [x] `LibraryCatalog.tracksFor` のトラック番号順ソート（D3）と # のトラック番号表示
- [x] アーティスト全体のメタ集約（`LibraryCatalog.artistSummary` / `albumSummary`）（H2）
- [x] アーティスト一覧ペイン: 幅 332px、サブヘッダ行、ヘアライン（A1）、行のインセット・選択スタイル（A2）、行の内容（A3）
- [x] アーティストヒーロー: アバター 124px+shadow-3、下端区切り線（H1）
- [x] アルバムセクション: 4カラムグリッド・ホバー影（G1）、フッターの年表示（G2）
- [x] アルバム詳細: ヒーロー（D1）とトラックリストヘッダ（D2）、戻る導線

## テスト

- [x] ソート・メタ集約の単体テスト（`test/library_catalog_test.dart`）
- [x] アルバム詳細表示・グリッドのWidgetテスト（`test/artist_album_browser_test.dart`）

## 動作確認

- [x] `flutter analyze`（No issues）/ `flutter test`（134件成功）
- [x] `flutter test integration_test/{artist_album,app_shell,search,removal}_test.dart -d macos`（成功）
- [ ] `03-artists.png` / `05-artist-detail.png` / `06-album-detail.png` との目視比較（未実施。実機起動での確認が必要）
- [ ] Windowsでの確認（macOS環境のため未実施）
