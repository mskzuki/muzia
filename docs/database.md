# Muzia データベース仕様書

## 1. 方針

Muziaのデータベースは、ローカル音楽ファイルを直接管理するものではなく、アプリ内のライブラリ情報を管理する。

データベースが保持する主な情報は以下である。

- 登録フォルダ
- 音楽ファイルのパスと検出状態
- アプリ内で表示・編集するメタデータ
- 音楽ファイルから最後に読み取ったメタデータ
- スキャン状態

元の音楽ファイルはデータベースの外部に存在する。MVPでは、アプリ上でメタデータを変更しても元ファイルへ書き戻さない。

## 2. 採用方針

- DBライブラリにはDriftを使用する
- DBエンジンにはSQLiteを使用する
- テーブル名・カラム名は英語のsnake_caseとする
- 主キーは整数の自動採番を使用する
- 時刻はUTCのISO 8601文字列として保存する
- パスはOSごとの形式を維持して保存する
- DBアクセスはRepositoryから行い、ViewやViewModelから直接アクセスしない
- DBスキーマの変更にはマイグレーションを追加する

## 3. エンティティ構成

MVPでは、アーティストとアルバムを独立したマスターテーブルにはしない。

楽曲テーブルに保持したメタデータをもとに、アーティスト一覧とアルバム一覧を生成する。

```text
library_folders 1 ─── * tracks

tracks
  ├── current metadata
  └── source metadata
```

この構成により、以下を簡単に扱えるようにする。

- 複数楽曲のメタデータ一括編集
- アーティスト名・アルバム名の変更
- ライブラリからの削除
- 再スキャンによるファイル由来メタデータの更新
- ユーザーが編集した値の保持

アーティスト・アルバムをマスターテーブルへ分離する必要が生じた場合は、将来のマイグレーションで対応する。

## 4. テーブル定義

### 4.1 `library_folders`

ライブラリに登録されたフォルダを管理する。

| カラム | 型 | NULL | 制約 | 説明 |
| --- | --- | --- | --- | --- |
| `id` | INTEGER | 不可 | PRIMARY KEY AUTOINCREMENT | フォルダID |
| `path` | TEXT | 不可 | UNIQUE | 登録フォルダの絶対パス |
| `is_active` | INTEGER | 不可 | DEFAULT 1 | 現在使用するフォルダかどうか |
| `last_scanned_at` | TEXT | 可 | - | 最後にスキャンした時刻 |
| `created_at` | TEXT | 不可 | - | 作成時刻 |
| `updated_at` | TEXT | 不可 | - | 更新時刻 |

MVPではアクティブなフォルダを1つとする。複数ライブラリ対応時に複数のアクティブフォルダへ拡張できる構造にしておく。

### 4.2 `tracks`

音楽ファイルの識別情報と、ライブラリ上の状態を管理する。

| カラム | 型 | NULL | 制約 | 説明 |
| --- | --- | --- | --- | --- |
| `id` | INTEGER | 不可 | PRIMARY KEY AUTOINCREMENT | 楽曲ID |
| `library_folder_id` | INTEGER | 不可 | FOREIGN KEY | 登録フォルダID |
| `file_path` | TEXT | 不可 | UNIQUE | 音楽ファイルの絶対パス |
| `file_extension` | TEXT | 不可 | - | 拡張子、小文字で保存 |
| `file_size` | INTEGER | 可 | - | 最後に確認したファイルサイズ（bytes） |
| `file_modified_at` | TEXT | 可 | - | 最後に確認したファイル更新時刻 |
| `last_seen_at` | TEXT | 可 | - | スキャンで最後に存在を確認した時刻 |
| `removed_at` | TEXT | 可 | - | ライブラリから削除した時刻 |
| `created_at` | TEXT | 不可 | - | 作成時刻 |
| `updated_at` | TEXT | 不可 | - | 更新時刻 |

`removed_at`がNULLの楽曲をライブラリ上のアクティブな楽曲とする。

### 4.3 `track_metadata`

アプリで表示・編集する現在のメタデータを管理する。

| カラム | 型 | NULL | 制約 | 説明 |
| --- | --- | --- | --- | --- |
| `track_id` | INTEGER | 不可 | PRIMARY KEY, FOREIGN KEY | 楽曲ID |
| `title` | TEXT | 可 | - | タイトル |
| `artist` | TEXT | 可 | - | アーティスト名 |
| `album` | TEXT | 可 | - | アルバム名 |
| `release_info` | TEXT | 可 | - | リリース情報 |
| `duration_ms` | INTEGER | 可 | - | 再生時間（milliseconds） |
| `updated_by_user_at` | TEXT | 可 | - | ユーザー編集が最後に行われた時刻 |
| `created_at` | TEXT | 不可 | - | 作成時刻 |
| `updated_at` | TEXT | 不可 | - | 更新時刻 |

一覧、検索、アーティスト一覧、アルバム一覧では、このテーブルの値を使用する。

### 4.4 `track_source_metadata`

音楽ファイルを最後に解析したときのメタデータを管理する。

| カラム | 型 | NULL | 制約 | 説明 |
| --- | --- | --- | --- | --- |
| `track_id` | INTEGER | 不可 | PRIMARY KEY, FOREIGN KEY | 楽曲ID |
| `title` | TEXT | 可 | - | ファイルから取得したタイトル |
| `artist` | TEXT | 可 | - | ファイルから取得したアーティスト名 |
| `album` | TEXT | 可 | - | ファイルから取得したアルバム名 |
| `release_info` | TEXT | 可 | - | ファイルから取得したリリース情報 |
| `duration_ms` | INTEGER | 可 | - | ファイルから取得した再生時間 |
| `read_at` | TEXT | 不可 | - | メタデータを解析した時刻 |

再スキャンでは、まずこのテーブルを更新する。
`track_metadata`に保存されたユーザー編集値は、再スキャンによって上書きしない。

## 5. データの責務

| データ | 正とする場所 | 説明 |
| --- | --- | --- |
| 音楽ファイルの内容 | ファイルシステム | アプリはMVPで変更しない |
| ファイルパス | `tracks.file_path` | 再生対象の参照先 |
| ファイルの存在確認 | `tracks.last_seen_at` | 最終スキャン時の状態 |
| 表示・検索するメタデータ | `track_metadata` | アプリ上の現在値 |
| ファイルから取得したメタデータ | `track_source_metadata` | 再スキャン時の参照値 |
| ライブラリからの削除状態 | `tracks.removed_at` | 元ファイルは削除しない |

## 6. インデックス

MVPでは以下のインデックスを作成する。

```sql
CREATE UNIQUE INDEX idx_library_folders_path
ON library_folders(path);

CREATE UNIQUE INDEX idx_tracks_file_path
ON tracks(file_path);

CREATE INDEX idx_tracks_library_folder_id
ON tracks(library_folder_id);

CREATE INDEX idx_tracks_removed_at
ON tracks(removed_at);

CREATE INDEX idx_track_metadata_artist
ON track_metadata(artist);

CREATE INDEX idx_track_metadata_album
ON track_metadata(album);

CREATE INDEX idx_track_metadata_title
ON track_metadata(title);
```

検索性能に問題が出た場合は、SQLite FTSの導入を検討する。MVP開始時点では、通常のLIKE検索で実装する。

## 7. ライブラリ操作のルール

### 7.1 フォルダ登録・変更

- 登録前にパスを正規化する
- 同じパスを重複登録しない
- フォルダ変更時は、変更前のフォルダに紐づくアクティブな楽曲へ`removed_at`を設定する
- フォルダ変更時は`library_folders.path`を新しいフォルダへ更新する
- フォルダ変更によって音楽ファイルを移動・削除しない
- 変更後に新しいフォルダをスキャンする

### 7.2 初回スキャン

1. 登録フォルダ内の対応ファイルを列挙する
2. `file_path`で既存の楽曲を検索する
3. 未登録ファイルは`tracks`へ追加する
4. ファイルのメタデータを`track_source_metadata`へ保存する
5. 初回読み込み時は、同じ値を`track_metadata`へコピーする
6. `last_seen_at`を更新する
7. `library_folders.last_scanned_at`を更新する

### 7.3 再スキャン

- ファイルの存在を確認する
- ファイルサイズまたは更新時刻が変わった場合はメタデータを再解析する
- 解析結果は`track_source_metadata`へ保存する
- `track_metadata`のユーザー編集値は保持する
- スキャンで見つからないファイルは、DBから即時削除しない
- 見つからないファイルは再生時にエラーとして扱えるようにする

### 7.4 ライブラリからの削除

- ユーザーの確認後、対象楽曲の`removed_at`を設定する
- `track_metadata`と`track_source_metadata`は保持する
- 元の音楽ファイルは削除しない
- 通常の一覧、検索、アーティスト一覧、アルバム一覧から除外する
- 再スキャン時も、`removed_at`が設定された楽曲は自動で再登録しない

再登録・削除済み楽曲の復元機能はMVP後に検討する。

## 8. メタデータ編集のルール

- ユーザー編集は`track_metadata`へ保存する
- 元ファイルのメタデータは変更しない
- 一括編集は、選択した全楽曲に対して同一トランザクションで実行する
- 一括編集に失敗した場合は、可能な限り全体をロールバックする
- 編集後は`updated_by_user_at`と`updated_at`を更新する
- 再スキャン時にユーザー編集値を上書きしない

MVP後にファイルへの書き戻しを実装する場合は、現在の設計と競合するため、別途要件・DB仕様・安全確認を更新する。

## 9. アーティスト・アルバム一覧

アーティストとアルバムは、アクティブな楽曲の`track_metadata`から生成する。

概念的なクエリ:

```sql
SELECT DISTINCT artist
FROM track_metadata
JOIN tracks ON tracks.id = track_metadata.track_id
WHERE tracks.removed_at IS NULL
  AND artist IS NOT NULL
  AND artist <> ''
ORDER BY artist;
```

アルバム一覧では、選択したアーティストに一致するアクティブな楽曲からアルバム名を抽出する。

同名アーティスト・アルバムの統合や、複数アーティストの正規化はMVP後に検討する。

## 10. トランザクション

以下の処理はトランザクションで実行する。

- 楽曲追加と初期メタデータ保存
- メタデータの一括編集
- ライブラリからの削除
- フォルダ変更に伴うライブラリ状態更新

## 11. マイグレーション

- DBスキーマの変更にはDriftのマイグレーション機能を使用する
- 既存データを破棄するマイグレーションを行わない
- マイグレーション後に旧バージョンからの起動を検証する
- スキーマ変更時は単体テストまたはIntegration Testを追加する
- DBバージョンとアプリバージョンを混同しない

## 12. テスト要件

- インメモリDBでRepositoryをテストできること
- フォルダ登録・変更をテストすること
- 初回スキャンと再スキャンをテストすること
- ユーザー編集値が再スキャンで上書きされないことをテストすること
- 一括編集がトランザクションで処理されることをテストすること
- ライブラリから削除しても元ファイルを削除しないことをテストすること
- 削除済み楽曲が通常の一覧や検索に表示されないことをテストすること
- アプリ再起動後に登録フォルダ、編集値、削除状態が保持されることをテストすること

## 13. 未決定事項

- 対応する音声ファイル形式の最終確定
- ファイルパス変更・移動を検出する方法
- ファイルのハッシュ値を保持するか
- 削除済み楽曲を復元するUIをMVPに含めるか
- ユーザー編集値をファイル由来の値へ戻す機能
- 複数アーティスト・複数アルバムアーティストの扱い
- FTS検索を導入する基準
- DBのバックアップと復元
