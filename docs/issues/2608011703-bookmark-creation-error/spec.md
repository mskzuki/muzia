# フォルダ登録失敗で楽曲一覧が消える 課題仕様書

## 文書情報

- 課題ID: 2608011703
- 種別: 不具合（エラー処理の是正）
- 対応する全体要件: FR-002、FR-005、FR-010
- ステータス: Completed
- 作成日: 2026-08-01
- 改訂日: 2026-08-01（対象を「ネイティブ失敗の通知」から「失敗時の一覧保持」へ変更）

## 1. 事象

楽曲一覧が表示されている状態でフォルダ登録に失敗すると、
一覧が「読み込みエラー」画面へ置き換わり、登録済みの楽曲が閲覧できなくなる。

macOSのsecurity-scoped bookmark作成が失敗した場合（`bookmark_creation_failed`）が代表例だが、
フォルダ選択の失敗、重複登録、スキャン失敗でも同じ結果になる。

DBの内容は無傷であり、アプリを再起動すれば楽曲一覧は元どおり表示される。
つまり失敗したのは「今回の登録操作」だけなのに、既存ライブラリの表示まで巻き添えになっている。

サイドバーの「フォルダを登録」ボタンは画面に残るが、
一覧・検索・編集・削除は行えず、ユーザーは失敗前の状態へ自力で戻せない。

## 2. 原因

`lib/features/library/presentation/library_view_model.dart` の `_setError()` は
`_status = LibraryStatus.error` と `_errorMessage` を必ず同時に設定する。
失敗の表現が1種類しかなく、

- 一覧を表示できない状態での致命的な失敗（初期化失敗など）
- 一覧を表示できている状態での操作の失敗（今回の登録失敗）

を区別していない。

`lib/features/app_shell/presentation/app_shell_page.dart` の `_MainContent` は
`LibraryStatus.error` を全画面のエラー表示へマップするため、後者でも一覧が破棄される。

課題 `2607312326-bookmark-platform-exception` は
`chooseAndScanFolder` の未処理非同期例外を解消したが、その受け皿を既存の `_setError` にしたため、
ネイティブのブックマーク作成失敗が新たにこの経路へ流れ込むようになった。

## 3. 再現手順

1. 音楽フォルダを登録し、楽曲が一覧に表示されることを確認する
2. サイドバーの「フォルダを登録」から、ブックマークを作成できないフォルダを選択する
   （App Sandbox でアクセス権を得られない場所。テストでは `createBookmark` が
   `PlatformException` を投げる `SecurityScopedBookmarkService` で代替する）
3. 画面を確認する

期待: 楽曲一覧は表示されたまま、登録に失敗した旨が通知される。
実際: 一覧が「読み込みエラー」画面へ置き換わり、登録済みの楽曲が見えなくなる。

## 4. 要件

### 4.1 継続要件（改訂前の本課題で定義。実装済み、退行させない）

- [x] REQ-001: `createBookmark` のネイティブ失敗（`PlatformException`）を呼び出し元へ伝播する。
      `null` へ潰さない。
- [x] REQ-002: `restoreBookmark` の失敗は例外にせず、保存済みライブラリを表示したうえでの
      警告（`readyWithWarnings`）として扱う。
- [x] REQ-003: macOS以外やテスト環境でネイティブ実装がない場合の無効化動作
      （`MissingPluginException` / `StateError` を `null` として扱う）を維持する。

改訂前の REQ「`LibraryViewModel` は既存の『フォルダを登録できませんでした。』を表示する」は、
表示方法を SnackBar へ変更するため REQ-005 が置き換える。文言は変更しない。

### 4.2 新規要件（本改訂で追加）

- [x] REQ-004: 楽曲一覧を表示できている状態（`ready` / `readyWithWarnings`）でフォルダ登録に
      失敗した場合、`status` と `tracks` を変更せず、一覧の表示を維持する。
- [x] REQ-005: 失敗は SnackBar で通知する。文言は既存のものをそのまま使う。
      対象は `chooseAndScanFolder` と `registerAndScan` の全失敗経路。
      - 「フォルダを登録できませんでした。」（フォルダ選択・ブックマーク作成の失敗）
      - 「フォルダが見つかりません。」（存在しないパス）
      - 「このフォルダはすでに登録されています。」（重複登録）
      - 「音楽ファイルのメタデータを解析できませんでした。」（候補はあったが全件解析失敗）
      - 「フォルダにアクセスできません。権限を確認してください。」（`FolderAccessException`）
      - 「フォルダのスキャンに失敗しました。」（その他のスキャン失敗）
- [x] REQ-006: 通知後もユーザーは「フォルダを登録」を再実行でき、
      一覧の検索・編集・削除も継続して行える。
- [x] REQ-007: 同じ失敗が連続しても、その都度 SnackBar を表示する
      （同一メッセージでも通知が発火すること）。
- [x] REQ-008: 楽曲一覧が無い状態（`empty` / `loading` / `error`）での失敗は、
      従来どおり全画面のエラー表示を維持する。
- [x] REQ-009: 成功した操作は既存どおりエラー表示・エラーメッセージを解除する。

### 4.3 対象範囲外

- メタデータ保存失敗（`updateTracksMetadata`）にも同じ問題があるが、
  課題 `2607312305-metadata-save-state-recovery` の範囲であり、本課題では扱わない。
  ただし本課題で追加する通知の仕組みは、後から同経路へ適用できる形にする。
- 空フォルダを登録すると `registerFolder` が既存の `tracks` / `track_metadata` /
  `track_source_metadata` を全削除し、ユーザーが編集したメタデータと削除状態が
  無確認で失われる問題。破壊的操作の確認ダイアログが論点であり、別課題として起票する。
- ブックマーク作成が失敗したフォルダを、ブックマーク無しで登録する挙動の是非。
  現状どおり登録せずに終了する。
- `removeTracks` がアクセス権喪失の警告を無条件に消す問題。別課題として起票する。

## 5. 完了条件

- [x] 一覧表示中のフォルダ登録失敗で `status` が `error` にならず、`tracks` が保持される。
- [x] 失敗時に SnackBar が表示され、一覧が画面に残っていることを Widget テストで検証する。
- [x] 一覧が無い状態での失敗が全画面エラーのままであることを検証する。
- [x] 継続要件 REQ-001〜003 の既存テスト
      （`test/security_scoped_bookmark_service_test.dart`、
      `test/library_repository_test.dart` のブックマーク関連4件）が成功したままである。
- [x] `flutter analyze` と `flutter test` が成功する。
- [x] macOS の Integration Test を実行し、結果を記録する（アプリのデバッグ接続失敗により6件失敗）。

## 6. 実装メモ

`LibraryViewModel` に、状態を変えずに失敗を伝える経路を追加する。

- `_setError(message)` は「一覧を表示できない状態の致命的エラー」専用に限定する。
- `_reportFailure(message)` を新設する。`canShowTracks` が `true` なら
  `_status` と `_tracks` を維持したまま `_errorMessage` を設定して通知し、
  `false` なら `_setError` へ委譲する。
- `chooseAndScanFolder` と `registerAndScan` の失敗は `_reportFailure` を使う。

SnackBar の発火には、同一メッセージの再発生を検出できる単調増加の値が要る。
`_errorMessage` の変化だけでは REQ-007 を満たせないため、
`int get failureRevision` を公開し、`_reportFailure` のたびにインクリメントする。

画面側は `AppShellPage.build` で
`ref.listen(libraryViewModelProvider.select((vm) => vm.failureRevision), ...)` を張り、
値が変化したら `ScaffoldMessenger.of(context)` で `errorMessage` を表示する。
`AppShellPage` は `Scaffold` より上位の `BuildContext` を持つため `ScaffoldMessenger` を利用できる。

既存テスト `test/library_test.dart:212-246` の3件は、
`initialize()` 前・楽曲0件の状態から登録するため `canShowTracks` は `false` であり、
`LibraryStatus.error` を期待する現在の内容のまま通る想定。実装時に確認する。

前回のレビューで「修正がUIから到達できない」と指摘されたため、
本課題の回帰テストは ViewModel を直接呼ばず、
`tester.tap` でサイドバーの「フォルダを登録」を押す経路で検証する。

## 7. 関連文書

- [全体要件](../../requirements.md) FR-002、FR-005、FR-010
- [UI/UX方針](../../ui-ux.md) 「エラー」節（何が失敗したか / 取れる対処 / 再試行できる操作）
- [ブックマーク失敗時にライブラリ全体が開けなくなる](../2607312326-bookmark-platform-exception/spec.md)
- [メタデータ保存失敗後の一覧状態復帰](../2607312305-metadata-save-state-recovery/spec.md)
