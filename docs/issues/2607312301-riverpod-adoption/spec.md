# Riverpod採用 課題仕様書

## 文書情報

- 課題ID: 2607312301
- 種別: 設計是正（文書と実装の乖離）
- 対応する全体要件: NFR-004、NFR-005
- ステータス: Completed
- 作成日: 2026-07-31

## 目的

アプリケーションのViewModelをRiverpodでComposition Rootから注入し、Widgetの状態購読とライフサイクル管理を一元化する。

## 対象範囲

- `flutter_riverpod`の導入
- App/ViewModelのProvider定義
- `ProviderScope`をアプリのルートへ追加
- `AppShellPage`の手動`addListener`購読をRiverpod購読へ置き換え
- 既存のViewModelコンストラクタと単体テスト用の依存性注入を維持

## 対象外

- ViewModelの状態モデルを`Notifier`/`AsyncNotifier`へ全面変更すること
- Repository、Service、Domainモデルの責務変更
- UIデザインの変更

## 要件

- Riverpod ProviderからAppShell、Library、PlayerのViewModelを取得できる
- テストでProviderを差し替えられる
- ViewModelの変更が画面へ反映される
- Providerが生成したViewModelを適切に破棄する
- 既存のMVP挙動とテストを維持する

## 完了条件

- Riverpodが依存関係に追加されている
- アプリが`ProviderScope`配下で起動する
- AppShellPageがProvider経由でViewModelを購読する
- `flutter analyze`と`flutter test`が成功する

## 設計メモ

初回導入では既存の`ChangeNotifier` ViewModelをRiverpodの互換Providerで包む。状態遷移が増えた機能から、後続の仕様で`Notifier`または`AsyncNotifier`へ段階的に移行する。
