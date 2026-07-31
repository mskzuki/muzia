# macOSフォルダ権限の永続化

## 目的

macOSのApp Sandbox環境で、ユーザーが選択した音楽フォルダへのアクセス権をアプリ再起動後も維持する。

## 対象範囲

- フォルダ選択時のsecurity-scoped bookmark作成
- bookmarkのライブラリDBへの保存
- 起動時のbookmark復元とアクセス開始
- bookmarkがstaleになった場合の更新
- Windows、テスト用のインメモリ実装との互換性維持

## 要件

- macOSでは、選択フォルダのパスとsecurity-scoped bookmarkを保存する。
- 起動時は保存済みbookmarkを復元してからライブラリを利用可能にする。
- bookmark復元時にパスが更新された場合は、DBのbookmarkとパスを更新する。
- 既存のbookmarkを持たないデータは、従来どおりパスを読み込める。
- アプリは音楽ファイルを変更せず、bookmarkは読み取り専用で作成する。

## 完了条件

- 新規に登録したフォルダのbookmarkがDBに保存される。
- 再起動相当の復元処理でbookmarkが復元される。
- stale bookmarkが更新される。
- `flutter analyze` と `flutter test` が成功する。
