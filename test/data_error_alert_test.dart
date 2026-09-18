import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

/// 最初の load() だけ失敗するリポジトリ。「再試行」で復旧する状況を作る。
class _FlakyRepository implements MusicRepository {
  _FlakyRepository(this._inner);
  final InMemoryMusicRepository _inner;
  // ViewModel の初期化に加え、画面の初期化でも load() が呼ばれるため 2 回失敗させる。
  var failuresLeft = 2;

  @override
  Future<void> load() async {
    if (failuresLeft > 0) {
      failuresLeft--;
      throw StateError('database is damaged');
    }
    await _inner.load();
  }

  @override
  String? get registeredFolder => _inner.registeredFolder;
  @override
  List<Track> get tracks => _inner.tracks;
  @override
  bool get folderAccessLost => false;
  @override
  Future<void> registerFolder(
    String path,
    List<Track> tracks, {
    Uint8List? securityScopedBookmark,
  }) => _inner.registerFolder(path, tracks);
  @override
  Future<void> updateMetadata(
    String filePath, {
    required MetadataValues values,
  }) => _inner.updateMetadata(filePath, values: values);
  @override
  Future<void> updateMetadataMany(
    List<String> filePaths,
    MetadataValues values,
  ) => _inner.updateMetadataMany(filePaths, values);
  @override
  Future<void> markRemoved(String filePath, bool removed) =>
      _inner.markRemoved(filePath, removed);
  @override
  Future<void> markRemovedMany(List<String> filePaths, bool removed) =>
      _inner.markRemovedMany(filePaths, removed);
  @override
  Future<void> markUnavailableMany(List<String> filePaths, bool unavailable) =>
      _inner.markUnavailableMany(filePaths, unavailable);
}

void main() {
  Future<LibraryViewModel> failingLibrary() async {
    final inner = InMemoryMusicRepository();
    await inner.registerFolder('/m', const [
      Track(filePath: '/m/a.mp3', fileExtension: '.mp3', title: 'Neon Hours'),
    ]);
    final viewModel = LibraryViewModel(repository: _FlakyRepository(inner));
    await viewModel.initialize();
    expect(viewModel.status, LibraryStatus.error);
    return viewModel;
  }

  testWidgets('ライブラリを開けないときはスクリム付きアラートを表示し、再試行で復旧する', (tester) async {
    final library = await failingLibrary();
    await tester.pumpWidget(MuziaApp(libraryViewModel: library));
    await tester.pumpAndSettle();

    final alert = find.byKey(const ValueKey('data-error-alert'));
    expect(alert, findsOneWidget);
    expect(tester.getSize(alert).width, 296);
    expect(find.text('ライブラリを開けません'), findsOneWidget);
    expect(find.textContaining('音楽ファイルは変更されていません'), findsOneWidget);
    final scrim = tester.widget<Container>(
      find.byKey(const ValueKey('data-error-scrim')),
    );
    expect(scrim.color, MuziaColors.light.overlay);
    // 背後は操作できない
    expect(find.byType(IgnorePointer), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('data-error-retry')));
    await tester.pumpAndSettle();

    expect(alert, findsNothing);
    expect(library.status, LibraryStatus.ready);
    expect(find.text('Neon Hours'), findsOneWidget);
  });

  testWidgets('Enter キーで再試行する', (tester) async {
    final library = await failingLibrary();
    await tester.pumpWidget(MuziaApp(libraryViewModel: library));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('data-error-alert')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('data-error-alert')), findsNothing);
    expect(find.text('Neon Hours'), findsOneWidget);
  });
}
