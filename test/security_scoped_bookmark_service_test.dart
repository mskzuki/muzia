import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/data/security_scoped_bookmark_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('muzia/security_scoped_bookmarks');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void respondWithError(String code) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: code, message: 'native failure');
    });
  }

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('ブックマーク作成のネイティブエラーをnullとして返す', () async {
    respondWithError('bookmark_creation_failed');
    final service = NativeSecurityScopedBookmarkService(channel: channel);

    expect(await service.createBookmark('/tmp/music'), isNull);
  });

  test('ブックマーク復元のネイティブエラーをnullとして返す', () async {
    respondWithError('bookmark_access_denied');
    final service = NativeSecurityScopedBookmarkService(channel: channel);

    expect(await service.restoreBookmark(Uint8List.fromList([1, 2, 3])), isNull);
  });
}
