import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';
import 'package:muzia/features/library/data/file_picker_service.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/data/security_scoped_bookmark_service.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';

void main() {
  testWidgets('アプリシェルの基本レイアウトと空状態を表示する', (tester) async {
    await tester.pumpWidget(const MuziaApp());
    await tester.pumpAndSettle();

    expect(find.text('Muzia'), findsOneWidget);
    expect(find.text('ライブラリ'), findsOneWidget);
    expect(find.text('ライブラリは空です'), findsOneWidget);
    expect(find.text('再生する楽曲が選択されていません'), findsOneWidget);
  });

  testWidgets('ライブラリ読み込み中の状態を表示する', (tester) async {
    final completer = Completer<void>();
    final viewModel = AppShellViewModel(
      initializeLibrary: () => completer.future,
    );

    await tester.pumpWidget(MuziaApp(viewModel: viewModel));
    expect(find.text('ライブラリを読み込んでいます'), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();
    expect(find.text('ライブラリは空です'), findsOneWidget);
  });

  testWidgets('ライブラリ読み込みエラーを表示する', (tester) async {
    final viewModel = AppShellViewModel(
      initializeLibrary: () async => throw StateError('test error'),
    );

    await tester.pumpWidget(MuziaApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    expect(find.text('読み込みエラー'), findsOneWidget);
    expect(find.text('ライブラリの読み込みに失敗しました。'), findsOneWidget);
  });

  testWidgets('検索語を入力してクリアできる', (tester) async {
    await tester.pumpWidget(const MuziaApp());
    await tester.pumpAndSettle();
    final searchField = find.byKey(const ValueKey('library-search'));

    await tester.enterText(searchField, 'artist');
    await tester.pump();
    expect(find.text('artist'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(find.text('artist'), findsNothing);
  });

  testWidgets('一覧表示中のフォルダ登録失敗をSnackBarで通知し一覧を維持する', (tester) async {
    const track = Track(
      filePath: '/tmp/saved.mp3',
      fileExtension: '.mp3',
      title: 'Saved song',
    );
    final repository = InMemoryMusicRepository();
    await repository.registerFolder('/tmp/existing', const [track]);
    final libraryViewModel = LibraryViewModel(
      picker: const _FixedPicker('/tmp/new'),
      repository: repository,
      bookmarkService: const _FailingBookmarkService(),
    );
    await libraryViewModel.initialize();

    await tester.pumpWidget(MuziaApp(libraryViewModel: libraryViewModel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('フォルダを登録'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Saved song'), findsOneWidget);
    expect(find.text('フォルダを登録できませんでした。'), findsOneWidget);
    expect(libraryViewModel.status, LibraryStatus.ready);
  });
}

class _FixedPicker implements FilePickerService {
  const _FixedPicker(this.path);
  final String path;

  @override
  Future<String?> pickDirectory() async => path;
}

class _FailingBookmarkService implements SecurityScopedBookmarkService {
  const _FailingBookmarkService();

  @override
  Future<Uint8List?> createBookmark(String path) async =>
      throw StateError('bookmark creation failed');

  @override
  Future<RestoredSecurityScopedBookmark?> restoreBookmark(
    Uint8List bookmark,
  ) async => null;
}
