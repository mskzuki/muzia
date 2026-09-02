# タスク

前提: [spec.md](spec.md) の「実装に先立つ確認事項」1〜2の方針についてユーザーの合意を得る。

## 実装

- [ ] `Track` に `durationMs` / `trackNumber` / `releaseYear` / `genre` を追加
      （`copyWith` / `valueOf` / `replaceMetadata` / `==` / `hashCode` を含む）
- [ ] `MetadataField` / `MetadataValues` に新項目を追加
- [ ] DBスキーマに列を追加し、マイグレーションを実装（既存データ保持）
- [ ] `metadata_service.dart` でタグから新項目を取り込む
- [ ] 既存 `releaseInfo` からの年の解釈方針を実装（確認事項2）
- [ ] 既存ジャンル一覧の取得API（`LibraryCatalog` または repository）

## テスト

- [ ] `Track` / `MetadataValues` の単体テスト更新
- [ ] マイグレーションのテスト（旧スキーマ→新スキーマ）
- [ ] メタデータ取り込みのテスト（項目あり/なしの音源）
- [ ] 永続化の往復テスト

## 動作確認

- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter test integration_test -d macos`（ライブラリ登録→再起動の保持）
- [ ] Windowsでの確認（実行できない場合は理由を報告）
