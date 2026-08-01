import 'package:flutter/services.dart';

class RestoredSecurityScopedBookmark {
  const RestoredSecurityScopedBookmark({
    required this.path,
    required this.bookmark,
  });

  final String path;
  final Uint8List bookmark;
}

/// ブックマークを扱えない環境や、復元できない場合は `null` で表す。
/// 作成時のネイティブ失敗は、登録処理でユーザーへ通知できるよう例外を伝播する。
abstract interface class SecurityScopedBookmarkService {
  Future<Uint8List?> createBookmark(String path);

  Future<RestoredSecurityScopedBookmark?> restoreBookmark(Uint8List bookmark);
}

class NoopSecurityScopedBookmarkService
    implements SecurityScopedBookmarkService {
  const NoopSecurityScopedBookmarkService();

  @override
  Future<Uint8List?> createBookmark(String path) async => null;

  @override
  Future<RestoredSecurityScopedBookmark?> restoreBookmark(
    Uint8List bookmark,
  ) async => null;
}

class NativeSecurityScopedBookmarkService
    implements SecurityScopedBookmarkService {
  NativeSecurityScopedBookmarkService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'muzia/security_scoped_bookmarks';
  final MethodChannel _channel;

  @override
  Future<Uint8List?> createBookmark(String path) async {
    try {
      return await _channel.invokeMethod<Uint8List>('createBookmark', {
        'path': path,
      });
    } on MissingPluginException {
      // macOS以外や、テスト環境ではネイティブ実装が存在しない。
      return null;
    } on StateError {
      // Flutter bindingがない単体テストではMethodChannelを利用できない。
      return null;
    }
  }

  @override
  Future<RestoredSecurityScopedBookmark?> restoreBookmark(
    Uint8List bookmark,
  ) async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'restoreBookmark',
        {'bookmark': bookmark},
      );
      if (result == null) return null;
      final path = result['path'];
      final restoredBookmark = result['bookmark'];
      if (path is! String || restoredBookmark is! Uint8List) return null;
      return RestoredSecurityScopedBookmark(
        path: path,
        bookmark: restoredBookmark,
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      // ネイティブ側の `FlutterError`（bookmark_access_denied など）。
      // フォルダを移動・削除された場合もここへ来る。
      return null;
    } on StateError {
      return null;
    }
  }
}
