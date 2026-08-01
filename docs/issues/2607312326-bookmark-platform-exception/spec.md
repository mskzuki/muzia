# ブックマーク失敗時にライブラリ全体が開けなくなる 課題仕様書

## 文書情報

- 課題ID: 2607312326
- 種別: 不具合
- 対応する全体要件: FR-002、FR-010
- ステータス: Completed
- 作成日: 2026-07-31

## 1. 事象

登録した音楽フォルダを移動・削除・リネームした後にアプリを起動すると、
「ライブラリの読み込みに失敗しました。」が表示され、ライブラリ全体が開けなくなる。

楽曲、メタデータ、削除状態はDBに無傷で残っているにもかかわらず、
フォルダのアクセス権を復元できないだけで全ての情報が閲覧できなくなる。

## 2. 原因

`lib/features/library/data/security_scoped_bookmark_service.dart` の
`NativeSecurityScopedBookmarkService` は `MissingPluginException` と
`StateError` だけを捕捉している。

macOS側の `SecurityScopedBookmarkChannel.swift` は失敗時に
`result(FlutterError(...))` を返す（`bookmark_access_denied`、
`bookmark_resolution_failed`、`bookmark_creation_failed`）。
これはDartでは `PlatformException` になるため、上記のcatchをすり抜ける。

伝播経路は2つある。

- 起動時: `restoreBookmark` の例外が `PersistentMusicRepository.load()` を貫通し、
  `LibraryViewModel.initialize()` の `on Object` で汎用エラーに潰れる。
- フォルダ登録時: `LibraryViewModel.chooseAndScanFolder` は
  `_picker.pickDirectory()` と `_bookmarkService.createBookmark()` を
  try/catchの外で呼ぶ。さらに `_Sidebar(onPickFolder:)` へ
  `Future<void> Function()` を `VoidCallback` として渡しているため
  Futureが破棄され、未処理の非同期例外となりユーザーには何も表示されない。

## 3. 再現手順

1. 音楽フォルダを登録し、楽曲が一覧に表示されることを確認する
2. アプリを終了する
3. 登録したフォルダをFinderで別の場所へ移動する
4. アプリを起動する

期待: 楽曲一覧は表示され、フォルダのアクセス権が失われた旨が通知される。
実際: ライブラリ全体がエラー画面になり、何も表示されない。

## 4. 要件

- [x] REQ-001: ブックマークの作成・復元に失敗しても、DBに保存済みの楽曲一覧を表示する。
- [x] REQ-002: フォルダへのアクセス権を復元できない場合、その旨を区別して通知する。
- [x] REQ-003: フォルダ選択・ブックマーク作成の失敗をユーザーに提示し、未処理例外にしない。
- [x] REQ-004: プラットフォーム実装が存在しない環境（Windows、テスト）では従来どおり無効化する。

## 5. 完了条件

- [x] `PlatformException` を捕捉し、ライブラリ読み込みを継続できる。
- [x] アクセス権喪失時の警告を一覧画面に表示する。
- [x] `chooseAndScanFolder` の例外がエラー表示になる。
- [x] ブックマーク失敗時の回帰テストが追加され、成功する。
- [x] `flutter analyze` と `flutter test` が成功する。

## 6. 実装メモ

`SecurityScopedBookmarkService` の失敗は例外ではなく `null` を返す契約に統一する。
アクセス権の喪失は `LibraryViewModel` の警告状態（`readyWithWarnings`）で扱い、
楽曲一覧の表示を妨げない。

既存テストの `_FakeBookmarkService` は常に成功を返すため、
失敗を返すFakeを追加して検証する。

## 7. 関連文書

- [全体要件](../../requirements.md)
- [データベース仕様](../../database.md)
- [macOSブックマーク対応](../2607312311-macos-security-scoped-bookmark/spec.md)
