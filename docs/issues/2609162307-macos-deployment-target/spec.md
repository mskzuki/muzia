# macOSデプロイメントターゲットの引き上げ（10.15 → 12.0）

## 文書情報

- 種別: ビルド設定の是正（環境追随）
- 作成日: 2026-09-16
- 参照: `macos/Runner.xcodeproj/project.pbxproj`、`macos/Podfile`、
  [docs/requirements.md](../../requirements.md) §5

## 事象

`flutter test integration_test -d macos` がビルドで失敗する。

```text
error: The macOS deployment target 'MACOSX_DEPLOYMENT_TARGET' is set to 10.15,
but the range of supported deployment target versions is 12.0 to 27.0.x.
```

## 原因

ビルド環境のXcodeが更新され、デプロイメントターゲット 10.15 がサポート範囲外になった。
プロジェクトは Flutter テンプレート既定の 10.15 のままだった。

## 要件

1. `Runner.xcodeproj` の `MACOSX_DEPLOYMENT_TARGET`（3箇所）と `Podfile` の
   `platform :osx` を 12.0 にする。
2. 要件定義 §5 に最低対応バージョン（macOS 12.0 以降）を明記する。

## 完了条件

- `flutter test integration_test -d macos` がビルドできる（スイート個別実行）。
- 要件定義に最低対応 macOS バージョンが記載されている。
- 2026-09-16 ユーザー合意済み。
