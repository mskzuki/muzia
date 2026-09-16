# タスク

- [x] `MACOSX_DEPLOYMENT_TARGET` を 12.0 に変更（Runner.xcodeproj 3箇所）
- [x] `Podfile` の `platform :osx` を 12.0 に変更
- [x] requirements.md §5 に最低対応バージョンを追記
- [x] `flutter test integration_test/metadata_editing_test.dart -d macos` でビルド・成功を確認
