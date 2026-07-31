# Muzia アーキテクチャ

## 1. 方針

Muziaは、MVVM（Model-View-ViewModel）を基本アーキテクチャとして採用する。

画面表示、画面の状態管理、データアクセス、プラットフォーム固有処理を分離し、以下を実現する。

- UIとアプリケーションロジックの分離
- macOS / Windows固有処理の隔離
- 単体テスト・Widgetテスト・Integration Testの実施しやすさ
- 音声再生、ファイルシステム、永続化方式の差し替えやすさ

## 2. レイヤー

```text
View
  ↓ ユーザー操作 / 状態購読
ViewModel
  ↓ アプリケーション操作
Repository / Service
  ↓ データアクセス / 外部機能
ファイルシステム・データベース・音声再生ライブラリ
```

### View

FlutterのWidgetで構成する画面層。

責務:

- 画面を表示する
- ユーザー操作をViewModelへ通知する
- ViewModelの状態を表示する
- ローディング、空状態、エラー状態を表示する

Viewは、ファイルシステム、データベース、音声再生ライブラリを直接呼び出してはならない。

### ViewModel

画面に必要な状態と、ユーザー操作に対応する処理を管理する。

責務:

- Viewへ公開する状態を保持する
- ユーザー操作をアプリケーション操作へ変換する
- RepositoryやServiceを呼び出す
- ローディング、成功、空状態、エラー状態を管理する
- Viewへ表示するデータを整形する

ViewModelはFlutterのWidgetに依存しないことを基本とする。

### Model / Domain

アプリケーションで扱うデータと、そのデータに関するルールを定義する。

例:

- `Track`
- `Artist`
- `Album`
- `Library`
- `PlaybackState`

Domainモデルには、特定のWidgetやデータベース実装の都合を持ち込まない。

### Repository

データの取得・保存方法を隠蔽する。

例:

- `MusicRepository`
- `LibraryRepository`
- `MetadataRepository`

Repositoryのインターフェースと実装を分離し、テスト時にはFakeやMockへ差し替えられるようにする。

Repositoryは、ファイルシステムやデータベースの詳細をViewModelへ漏らしてはならない。

### Service

外部機能やプラットフォーム機能へのアクセスを提供する。

例:

- `AudioPlayerService`
- `FileScannerService`
- `FilePickerService`
- `MetadataService`
- `LibraryStorageService`

macOS / Windows固有の処理や外部パッケージへの依存は、可能な限りService内に隔離する。

## 3. ディレクトリ構成

機能単位で整理し、各機能内にMVVMの責務を配置する。

```text
lib/
  app/
    app.dart
    router.dart
  features/
    library/
      presentation/
        library_page.dart
        library_view_model.dart
        library_state.dart
      domain/
        track.dart
        artist.dart
        album.dart
      data/
        music_repository.dart
        local_music_repository.dart
    player/
      presentation/
        player_bar.dart
        player_view_model.dart
        player_state.dart
      domain/
        playback_state.dart
      data/
        audio_player_service.dart
    settings/
      presentation/
      domain/
      data/
  shared/
    widgets/
    services/
    utils/
```

実際のディレクトリは機能の増加に応じて調整してよいが、UI、状態、ドメイン、データアクセスの責務は混在させない。

## 4. Muziaの主要な処理フロー

### ライブラリ読み込み

```text
LibraryPage
  ↓ 初期化
LibraryViewModel
  ↓
MusicRepository
  ↓
FileScannerService / LibraryStorageService
  ↓
LibraryViewModelが状態を更新
  ↓
LibraryPageが再描画
```

### 音楽フォルダの登録・変更

```text
View
  ↓ フォルダ選択
LibraryViewModel
  ↓
FilePickerService
  ↓
MusicRepository
  ↓
FileScannerService
  ↓
LibraryViewModelが結果を公開
```

### メタデータ編集

```text
View
  ↓ 編集内容を送信
LibraryViewModel
  ↓ 入力検証
MusicRepository
  ↓
ライブラリ情報を保存
  ↓
ViewModelが一覧・詳細の状態を更新
```

MVPのメタデータ編集では、アプリ内のライブラリ情報を変更する。元の音楽ファイルへの書き戻しは行わない。

### 楽曲再生

```text
View
  ↓ 楽曲を選択
PlayerViewModel
  ↓
AudioPlayerService
  ↓
音声再生ライブラリ
  ↓ 再生状態を通知
PlayerViewModel
  ↓
PlayerBarなどを更新
```

## 5. 状態管理

状態管理ライブラリは未決定である。採用後も、状態の所有者と公開範囲を明確にする。

- 画面固有の一時状態は、該当するViewまたはViewModelが管理する
- 複数画面で共有する状態は、適切な上位のViewModelまたはアプリケーション状態で管理する
- ライブラリ状態と再生状態を混在させない
- 非同期処理の状態を、初期化中・処理中・成功・空・失敗などで表現する
- ViewModelの状態変更を、Widgetが直接書き換えない

## 6. 依存関係のルール

- ViewはViewModelに依存してよい
- ViewModelはRepositoryとServiceに依存してよい
- RepositoryはServiceやデータソースに依存してよい
- DomainモデルはFlutter UI、データベース、外部ライブラリに依存しない
- 下位レイヤーから上位レイヤーへ直接依存しない
- 外部ライブラリは、可能な限りServiceまたはRepositoryの内部に隔離する

## 7. エラー処理

- ファイルアクセス、メタデータ解析、永続化、再生のエラーを適切に分類する
- ViewModelはViewが表示できる状態へエラーを変換する
- エラーを握りつぶさない
- ユーザーに不要な内部実装情報を表示しない
- 開発時に原因を追跡できるログを残す
- ユーザー固有のファイルパスや機密情報をログへ不用意に出力しない

## 8. テスト方針

### 単体テスト

以下を優先してテストする。

- Domainモデルのルール
- ViewModelの状態遷移
- 検索、フィルタリング、ソート
- アーティスト・アルバムのグルーピング
- メタデータ編集・一括編集
- ライブラリからの削除

RepositoryやServiceはFakeまたはMockへ差し替えてテストする。

### Widgetテスト

- ライブラリ一覧
- アーティスト・アルバム一覧
- 検索状態
- メタデータ編集画面
- 複数選択状態
- エラー、空状態、ローディング状態

### Integration Test

以下の主要フローを実際のデスクトップアプリで検証する。

- アプリ起動
- フォルダ登録・変更
- 楽曲一覧の表示
- 検索
- 楽曲の再生・一時停止
- メタデータ編集
- メタデータ一括編集
- ライブラリからの削除
- アプリ再起動後の状態保持

## 9. 設計判断の変更

アーキテクチャや主要ライブラリの選定を変更する場合は、以下を記録する。

- 変更理由
- 変更対象
- 既存コードへの影響
- テストへの影響
- macOS / Windowsへの影響

重要な設計判断は、`docs/decisions/`以下にADRとして記録する。

## 10. 使用ライブラリの選定

DBのテーブル定義、データの責務、スキャンや削除のルールは
[`docs/database.md`](database.md)に定義する。

### 10.1 選定基準

ライブラリは、以下の基準で選定する。

- macOS / Windowsの両方をサポートしている
- 現在のFlutter / Dart SDKで利用できる
- メンテナンスが継続されている
- ライセンスがプロジェクトの用途に適している
- テスト時に差し替えやすい
- 必要以上に依存関係を増やさない
- デスクトップで必要な処理を安定して実行できる

実際に使用するバージョンは`pubspec.yaml`を正とする。以下のバージョンは2026-07-31時点の調査結果であり、採用時に再確認する。

### 10.2 採用ライブラリ

| 用途 | 採用ライブラリ | 状態 | 選定理由・確認事項 |
| --- | --- | --- | --- |
| 状態管理 / DI | [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) | 採用 | 非同期状態、依存性注入、テスト用Provider差し替えに対応する。MVVMのViewModel管理に利用する。 |
| フォルダ選択 | [`file_selector`](https://pub.dev/packages/file_selector) | 採用 | Flutter公式パッケージで、macOS / Windowsのディレクトリ選択に対応する。macOSのファイルアクセスEntitlementを設定する。 |
| 永続化 | [`drift`](https://pub.dev/packages/drift) + [`drift_flutter`](https://pub.dev/packages/drift_flutter) | 採用 | SQLiteベースで、楽曲・アーティスト・アルバム・ライブラリ状態を関係データとして扱う。インメモリDBでテストできる構成にする。 |
| 音声再生 | [`media_kit`](https://pub.dev/packages/media_kit) + [`media_kit_libs_audio`](https://pub.dev/packages/media_kit_libs_audio) | 採用 | macOS / Windowsを含む広い音声形式に対応する。音声再生に必要なネイティブライブラリを追加する。 |
| メタデータ解析 | [`audio_metadata_reader`](https://pub.dev/packages/audio_metadata_reader) | 採用 | MP3、MP4、FLAC、OGGなどのメタデータ読み取りに使用する。MVPでは元ファイルへの書き戻しに使用しない。 |
| パス操作 | [`path`](https://pub.dev/packages/path) | 採用 | macOS / Windowsのパス区切り文字を意識せずパスを扱うために使用する。 |

### 10.3 検討した代替候補

#### 音声再生

[`just_audio`](https://pub.dev/packages/just_audio)は有力な候補だが、Windowsでは追加の実装パッケージが必要になる。macOSは標準対応だが、macOS / Windowsで同じ再生バックエンドを使いたいMuziaでは、現時点では`media_kit`を優先候補とする。

#### 永続化

[`sqflite_common_ffi`](https://pub.dev/packages/sqflite_common_ffi)もmacOS / Windowsとテスト用データベースをサポートする。ただし、Muziaでは楽曲、アーティスト、アルバム、登録フォルダ、ライブラリからの削除状態を扱うため、型安全なクエリとリアクティブな読み出しを持つDriftを優先候補とする。

#### ファイル選択

[`file_picker`](https://pub.dev/packages/file_picker)もmacOS / Windowsのディレクトリ選択に対応する。ただし、MVPで必要な機能はフォルダ選択が中心であるため、機能範囲がより明確な`file_selector`を優先候補とする。

### 10.4 採用後の検証項目

依存関係を追加した後、最小の検証用コードまたは検証ブランチで以下を確認する。

- macOS / WindowsのDebug・Releaseビルドが成功する
- `flutter analyze`と`flutter test`が成功する
- `integration_test`から主要APIを操作できる
- macOSのSandboxおよびファイルアクセスEntitlementで登録フォルダを読める
- Windowsでフォルダ選択ダイアログを開ける
- MP3、FLAC、M4A / AAC、WAV、OGGを読み込める
- 音声再生の開始・一時停止がmacOS / Windowsで動作する
- 楽曲数が増えた場合のスキャン・検索・保存性能に問題がない
- パッケージのライセンスが配布方法に適合する

検証で問題が見つかった場合は、候補を再評価し、採用ライブラリを確定する。
