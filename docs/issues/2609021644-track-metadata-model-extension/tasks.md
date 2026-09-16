# タスク

前提: [spec.md](spec.md) の「実装に先立つ確認事項」1〜2の方針についてユーザーの合意を得る。

- 確認事項1: 要件更新を実施した。`docs/requirements.md` FR-004（表示項目）と
  FR-011（編集対象。再生時間は編集対象外と明記）に新項目を追記。
- 確認事項2: spec記載の方針どおり実装。`releaseInfo` の先頭4桁が年として解釈
  できる場合のみ `releaseYear` へ移行し、`releaseInfo` 自体は変更しない。
  旧実装がタグなしファイルに保存した `0000-01-01 ...` は年として移行しない。

## 実装

- [x] `Track` に `durationMs` / `trackNumber` / `releaseYear` / `genre` を追加
      （`copyWith` / `valueOf` / `replaceMetadata` / `==` / `hashCode` を含む）
- [x] `MetadataField` / `MetadataValues` に新項目を追加
      （既定コンストラクタが全項目対象になるため、単曲編集ダイアログは
      既存4項目のみを対象とする `partial` に変更し、UI未対応項目の消失を防止）
- [x] DBスキーマに列を追加し、マイグレーションを実装（既存データ保持。
      `durationMs` は `tracks`、編集可能な3項目は `track_metadata` /
      `track_source_metadata` に追加。schemaVersion 3→4）
- [x] `metadata_service.dart` でタグから新項目を取り込む
- [x] 既存 `releaseInfo` からの年の解釈方針を実装（確認事項2）
- [x] 既存ジャンル一覧の取得API（`LibraryCatalog.genres`）

## テスト

- [x] `Track` / `MetadataValues` の単体テスト更新（`test/track_test.dart`）
- [x] マイグレーションのテスト（`test/library_database_migration_test.dart`。
      旧スキーマDBを組み立てるため `sqlite3` をdev依存に追加）
- [x] メタデータ取り込みのテスト（`test/fixtures/` のタグあり/なし音源）
- [x] 永続化の往復テスト（`test/library_repository_test.dart` に追加）

## 動作確認

- [x] `flutter analyze`
- [x] `flutter test`
- [x] Integration Test（macOS）: 全7スイートを個別実行で成功。
      `flutter test integration_test -d macos` の一括実行は2スイート目以降の
      アプリ再起動が「Error waiting for a debug connection」で失敗する
      （本変更と無関係の環境事象。変更のないスイートでも発生し、個別実行では再現しない）
- [ ] Windowsでの確認（macOS環境のため実行不可。Windows環境での確認が必要）
