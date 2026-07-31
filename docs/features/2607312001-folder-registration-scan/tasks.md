# 音楽フォルダ登録・初回スキャン 実装タスク

## 実装前

- [x] `spec.md`、要件、DB仕様、アプリシェルの対象範囲を確認する
- [x] `file_selector`、`audio_metadata_reader`、`path`の対応形式とデスクトップ動作を検証する
- [x] 必要な依存関係とmacOSのファイルアクセス設定を確定する

## 実装

- [x] フォルダ選択Serviceとパス検証を実装する
- [x] 対応形式判定と非同期ファイルスキャンを実装する
- [x] メタデータ解析Serviceを実装する
- [x] 楽曲・メタデータ保存用Repositoryの差し替え境界を実装する
- [x] 登録、変更、重複、空、エラー状態をViewModelへ追加する
- [x] 楽曲一覧とスキャン状態のUIを実装する

## テスト

- [x] パス検証、拡張子判定、メタデータ変換を単体テストする
- [ ] Repositoryを一時ディレクトリ・テストDBでテストする（Drift実装は後続スペック）
- [x] 一覧のloading、empty、error、成功状態をWidgetテストする
- [ ] フォルダ登録から一覧表示までをIntegration Testする
- [ ] テスト前後で音楽ファイルが変更されないことを確認する
- [x] `flutter analyze` と `flutter test` を実行する
- [ ] macOS / WindowsのIntegration Testを実行する

## 完了

- [x] 完了条件と未実行確認を`spec.md`または作業報告へ反映する
