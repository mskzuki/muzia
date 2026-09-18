import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muzia/app/providers.dart';
import 'dart:io' show exit;

import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';
import 'package:muzia/features/app_shell/presentation/data_error_alert.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/artist_album_browser.dart';
import 'package:muzia/features/library/presentation/bulk_edit_confirm_dialog.dart';
import 'package:muzia/features/library/domain/bulk_edit_plan.dart';
import 'package:muzia/features/library/domain/library_catalog.dart';
import 'package:muzia/features/library/domain/library_search.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track_sort.dart';
import 'package:muzia/features/library/presentation/metadata_edit_dialog.dart';
import 'package:muzia/features/library/presentation/track_actions.dart';
import 'package:muzia/shared/widgets/now_playing_equalizer.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/shared/format/count_format.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

/// サイドバーのライブラリ項目。「アーティスト」「アルバム」はどちらも
/// アーティスト/アルバムブラウザを開く（アルバム単独のグリッド画面はMVP後）。
enum _LibrarySection { library, artists, albums }

class AppShellPage extends ConsumerStatefulWidget {
  const AppShellPage({super.key});

  @override
  ConsumerState<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends ConsumerState<AppShellPage> {
  _LibrarySection _section = _LibrarySection.library;
  final _searchFocusNode = FocusNode(debugLabel: 'library-search');

  /// 検索結果のアルバム/アーティストから開くブラウザの初期選択。
  (String? artist, String? album)? _browserTarget;

  static bool get _isMac => defaultTargetPlatform == TargetPlatform.macOS;

  /// ファイルが見つからない楽曲は再生を試みず、理由を表示する（FR-009）。
  void _play(Track track) {
    if (!track.isAvailable) {
      final name = track.title?.isNotEmpty == true
          ? track.title!
          : track.filePath;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「$name」のファイルが見つかりません。移動または削除された可能性があります。')),
      );
      return;
    }
    unawaited(ref.read(playerViewModelProvider).play(track));
  }

  void _openInBrowser(String? artist, String? album) {
    setState(() {
      _browserTarget = (artist, album);
      _section = _LibrarySection.artists;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appShellViewModelProvider).initialize();
      ref.read(libraryViewModelProvider).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      libraryViewModelProvider.select((viewModel) => viewModel.failureRevision),
      (previous, next) {
        final message = ref.read(libraryViewModelProvider).errorMessage;
        if (message == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    );
    final viewModel = ref.watch(appShellViewModelProvider);
    final libraryViewModel = ref.watch(libraryViewModelProvider);
    final playerViewModel = ref.watch(playerViewModelProvider);
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final sectionTitle = switch (_section) {
      _LibrarySection.library => '楽曲',
      _LibrarySection.artists => 'アーティスト',
      _LibrarySection.albums => 'アルバム',
    };
    final catalog = LibraryCatalog(libraryViewModel.tracks);
    return CallbackShortcuts(
      bindings: {
        SingleActivator(
          LogicalKeyboardKey.keyF,
          meta: _isMac,
          control: !_isMac,
        ): _searchFocusNode.requestFocus,
      },
      // どこにもフォーカスがない状態でもショートカットが届くよう、ページ全体を
      // フォーカス可能にする。
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 52,
            backgroundColor: colors.sidebarBg,
            elevation: 0,
            scrolledUnderElevation: 0,
            shape: Border(bottom: BorderSide(color: colors.borderSubtle)),
            titleSpacing: 0,
            title: Row(
              children: [
                // タイトルはサイドバー幅の右、コンテンツ列の上に置く（戻る/進むは見送り）。
                const SizedBox(width: 224 + 18),
                Text(
                  sectionTitle,
                  style: MuziaTextStyles.windowTitle.copyWith(
                    color: colors.fgPrimary,
                  ),
                ),
                if (libraryViewModel.canShowTracks) ...[
                  const SizedBox(width: MuziaSpacing.s2),
                  Text(
                    [
                      '${formatCount(libraryViewModel.tracks.length)}曲',
                      if (libraryViewModel.unavailableTracks.isNotEmpty)
                        '${formatCount(libraryViewModel.unavailableTracks.length)}曲が利用不可',
                    ].join(' · '),
                    style: MuziaTextStyles.secondary.copyWith(
                      color: colors.fgTertiary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              _SearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                query: _searchQuery,
                onChanged: (value) => setState(() => _searchQuery = value),
                onClear: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _Sidebar(
                      onPickFolder: libraryViewModel.chooseAndScanFolder,
                      section: _section,
                      trackCount: libraryViewModel.canShowTracks
                          ? libraryViewModel.tracks.length
                          : null,
                      artistCount: libraryViewModel.canShowTracks
                          ? catalog.artists.length
                          : null,
                      albumCount: libraryViewModel.canShowTracks
                          ? catalog.albums.length
                          : null,
                      onSectionChanged: (section) =>
                          setState(() => _section = section),
                    ),
                    Expanded(
                      child: _MainContent(
                        viewModel: viewModel,
                        libraryViewModel: libraryViewModel,
                        section: _section,
                        searchQuery: _searchQuery,
                        onPlay: _play,
                        playingPath: playerViewModel.track?.filePath,
                        playbackActive: playerViewModel.isPlaying,
                        onPickFolder: libraryViewModel.chooseAndScanFolder,
                        browserTarget: _browserTarget,
                        onOpenInBrowser: _openInBrowser,
                        onRetry: () => unawaited(viewModel.initialize()),
                        onQuit: () => exit(0),
                      ),
                    ),
                  ],
                ),
              ),
              _PlayerArea(viewModel: playerViewModel),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.onPickFolder,
    required this.section,
    required this.trackCount,
    required this.artistCount,
    required this.albumCount,
    required this.onSectionChanged,
  });

  /// `VoidCallback` として受け取るとFutureが破棄され、失敗が握りつぶされる。
  /// 非同期であることを型で表し、[LibraryViewModel] 側のエラー状態へ委ねる。
  final Future<void> Function() onPickFolder;
  final _LibrarySection section;
  final int? trackCount;
  final int? artistCount;
  final int? albumCount;
  final ValueChanged<_LibrarySection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return SizedBox(
      key: const ValueKey('sidebar'),
      width: 224,
      child: Material(
        color: colors.sidebarBg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MuziaSpacing.s3,
            vertical: MuziaSpacing.s4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: MuziaSpacing.s2,
                  bottom: MuziaSpacing.s2,
                ),
                child: Text(
                  'ライブラリ',
                  style: MuziaTextStyles.caption.copyWith(
                    color: colors.fgTertiary,
                  ),
                ),
              ),
              _SidebarItem(
                key: const ValueKey('sidebar-item-library'),
                icon: Icons.music_note,
                label: '楽曲',
                count: trackCount,
                selected: section == _LibrarySection.library,
                onTap: () => onSectionChanged(_LibrarySection.library),
              ),
              const SizedBox(height: 2),
              _SidebarItem(
                key: const ValueKey('sidebar-item-artists'),
                icon: Icons.person_outline,
                label: 'アーティスト',
                count: artistCount,
                selected: section == _LibrarySection.artists,
                onTap: () => onSectionChanged(_LibrarySection.artists),
              ),
              const SizedBox(height: 2),
              _SidebarItem(
                key: const ValueKey('sidebar-item-albums'),
                icon: Icons.album_outlined,
                label: 'アルバム',
                count: albumCount,
                selected: section == _LibrarySection.albums,
                onTap: () => onSectionChanged(_LibrarySection.albums),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => unawaited(onPickFolder()),
                icon: const Icon(Icons.folder_open, size: 16),
                label: const Text('フォルダを登録'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.fgSecondary,
                  side: BorderSide(color: colors.borderSubtle),
                  textStyle: MuziaTextStyles.body,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MuziaRadius.r3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final fg = selected ? colors.onAccent : colors.fgPrimary;
    return Material(
      color: selected ? colors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(MuziaRadius.r2),
      child: InkWell(
        onTap: onTap,
        hoverColor: selected ? colors.accentHover : colors.rowHover,
        borderRadius: BorderRadius.circular(MuziaRadius.r2),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: MuziaSpacing.s2),
          child: Row(
            children: [
              Icon(icon, size: 16, color: selected ? fg : colors.accentText),
              const SizedBox(width: MuziaSpacing.s2),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: MuziaTextStyles.rowTitle.copyWith(color: fg),
                ),
              ),
              if (count != null)
                Text(
                  formatCount(count!),
                  style: TextStyle(
                    fontSize: 11,
                    color: selected
                        ? fg.withValues(alpha: 0.75)
                        : colors.fgTertiary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.viewModel,
    required this.libraryViewModel,
    required this.section,
    required this.searchQuery,
    required this.onPlay,
    required this.playingPath,
    required this.playbackActive,
    required this.onPickFolder,
    required this.browserTarget,
    required this.onOpenInBrowser,
    required this.onRetry,
    required this.onQuit,
  });

  final AppShellViewModel viewModel;
  final LibraryViewModel libraryViewModel;
  final _LibrarySection section;
  final String searchQuery;
  final ValueChanged<Track> onPlay;
  final String? playingPath;

  /// 再生中（一時停止ではない）か。再生中行のイコライザを動かす判定に使う。
  final bool playbackActive;
  final Future<void> Function() onPickFolder;
  final (String? artist, String? album)? browserTarget;
  final void Function(String? artist, String? album) onOpenInBrowser;
  final VoidCallback onRetry;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    if (section != _LibrarySection.library && libraryViewModel.canShowTracks) {
      return Padding(
        padding: const EdgeInsets.all(MuziaSpacing.s6),
        child: ArtistAlbumBrowser(
          // 検索結果から開いたときは初期選択を渡し、対象が変わったら作り直す。
          key: ValueKey(browserTarget),
          tracks: libraryViewModel.tracks,
          initialArtist: browserTarget?.$1,
          initialAlbum: browserTarget?.$2,
          actions: TrackActions(
            onPlay: onPlay,
            onEdit: libraryViewModel.updateTrackMetadata,
            onRemove: libraryViewModel.removeTracks,
          ),
          playingPath: playingPath,
          playbackActive: playbackActive,
        ),
      );
    }
    final results = LibrarySearch.search(libraryViewModel.tracks, searchQuery);
    final visibleTracks = results.tracks;
    final searching = searchQuery.trim().isNotEmpty;
    final showsLibrary =
        viewModel.status != AppShellStatus.loading &&
        viewModel.status != AppShellStatus.error;
    // テーブルは全幅で表示し、状態メッセージは中央に寄せる。
    final Widget? status = viewModel.status == AppShellStatus.loading
        ? const _StatusMessage(
            icon: Icons.hourglass_top,
            title: 'ライブラリを読み込んでいます',
            message: '準備が完了するまでお待ちください。',
          )
        : viewModel.status == AppShellStatus.error
        // 致命的エラーはアラート（下記）で表示する。背後には最後の一覧を残す。
        ? null
        : switch (libraryViewModel.status) {
            LibraryStatus.loading => const _StatusMessage(
              icon: Icons.hourglass_top,
              title: 'ライブラリを読み込んでいます',
              message: '準備が完了するまでお待ちください。',
            ),
            LibraryStatus.empty => _EmptyLibrary(onPickFolder: onPickFolder),
            LibraryStatus.error => null,
            // 一覧を表示できる2つの状態は、検索0件の扱いも同じ。
            LibraryStatus.ready || LibraryStatus.readyWithWarnings =>
              searching && results.isEmpty
                  ? const _StatusMessage(
                      icon: Icons.search_off,
                      title: '該当する楽曲がありません',
                      message: 'タイトル、アーティスト、アルバムを確認してください。',
                    )
                  : null,
          };
    final table = _TrackTable(
      tracks: visibleTracks,
      catalog: LibraryCatalog(libraryViewModel.tracks),
      highlightQuery: searching ? searchQuery : '',
      onRemove: libraryViewModel.removeTracks,
      onEdit: (track, values) =>
          libraryViewModel.updateTrackMetadata(track, values),
      onBulkEdit: libraryViewModel.updateTracksMetadata,
      onPlay: onPlay,
      playingPath: playingPath,
      playbackActive: playbackActive,
    );
    final fatalError = viewModel.status == AppShellStatus.error
        ? viewModel.errorMessage ?? 'ライブラリを読み込めませんでした。'
        : libraryViewModel.status == LibraryStatus.error
        ? libraryViewModel.errorMessage ?? 'ライブラリを読み込めませんでした。'
        : null;
    final body = status != null
        ? Padding(
            padding: const EdgeInsets.all(MuziaSpacing.s6),
            child: Center(child: status),
          )
        : searching
        ? _SearchResultsView(
            results: results,
            table: table,
            onOpenInBrowser: onOpenInBrowser,
          )
        : table;
    final content = fatalError == null
        ? body
        : Stack(
            fit: StackFit.expand,
            children: [
              // 最後に読み込めた一覧を淡く残し、操作は受け付けない（12-error）。
              IgnorePointer(
                child: Opacity(
                  opacity: 0.6,
                  child: libraryViewModel.tracks.isEmpty
                      ? const SizedBox.expand()
                      : body,
                ),
              ),
              DataErrorAlert(
                message:
                    '$fatalError 音楽ファイルは変更されていません。'
                    '解決しない場合は、フォルダを登録し直してください。',
                onRetry: onRetry,
                onQuit: onQuit,
              ),
            ],
          );

    // 警告は一覧の外に出す。検索0件の空状態でも通知が消えないようにする。
    final warningMessage = libraryViewModel.warningMessage;
    final showsWarning =
        showsLibrary &&
        libraryViewModel.canShowTracks &&
        warningMessage != null;
    final unavailable = libraryViewModel.unavailableTracks;
    // 欠損ファイルのバナーは対処（削除）できるため、スキャン警告より上に置く。
    // 両方ある場合は縦に並べて双方を表示する（要件4）。
    return Column(
      children: [
        if (showsLibrary &&
            libraryViewModel.canShowTracks &&
            libraryViewModel.showsUnavailableBanner)
          _WarningNotice(
            key: const ValueKey('unavailable-banner'),
            title: '${formatCount(unavailable.length)}曲が利用できません。',
            message: 'ファイルが前回のスキャン以降に移動または削除されました。',
            actions: [
              Builder(
                builder: (context) => TextButton(
                  key: const ValueKey('unavailable-remove'),
                  onPressed: () => unawaited(
                    TrackActions(
                      onPlay: onPlay,
                      onEdit: libraryViewModel.updateTrackMetadata,
                      onRemove: libraryViewModel.removeTracks,
                    ).confirmRemove(context, unavailable),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).extension<MuziaColors>()!.warnText,
                    textStyle: MuziaTextStyles.rowTitle,
                    minimumSize: const Size(0, 28),
                    padding: const EdgeInsets.symmetric(
                      horizontal: MuziaSpacing.s2,
                    ),
                  ),
                  child: const Text('削除…'),
                ),
              ),
              IconButton(
                key: const ValueKey('unavailable-dismiss'),
                tooltip: '閉じる',
                icon: const Icon(Icons.close, size: 14),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
                onPressed: libraryViewModel.dismissUnavailableBanner,
              ),
            ],
          ),
        if (showsWarning)
          _WarningNotice(
            key: const ValueKey('warning-banner'),
            title: libraryViewModel.warningTitle ?? '警告',
            message: warningMessage,
          ),
        Expanded(child: content),
      ],
    );
  }
}

/// ツールバー直下の amber バナー（`.banner`）。[actions] は右端に置く。
class _WarningNotice extends StatelessWidget {
  const _WarningNotice({
    super.key,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return IconTheme(
      data: IconThemeData(color: colors.warnText),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.warnSurface,
          border: Border(
            bottom: BorderSide(color: colors.warnBorder, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MuziaSpacing.s4,
          vertical: MuziaSpacing.s2,
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 16,
              color: colors.warnText,
            ),
            const SizedBox(width: MuziaSpacing.s2),
            Text(
              title,
              style: MuziaTextStyles.body.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: colors.warnTextStrong,
              ),
            ),
            const SizedBox(width: MuziaSpacing.s2),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                style: MuziaTextStyles.body.copyWith(
                  fontSize: 12.5,
                  color: colors.warnTextStrong,
                ),
              ),
            ),
            for (final action in actions) ...[
              const SizedBox(width: MuziaSpacing.s2),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
      ],
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onPickFolder});

  final Future<void> Function() onPickFolder;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Column(
      key: const ValueKey('empty-state'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: colors.accentSoft,
            borderRadius: BorderRadius.circular(MuziaRadius.r5),
          ),
          child: Icon(Icons.music_note, size: 40, color: colors.accent),
        ),
        const SizedBox(height: MuziaSpacing.s5),
        Text(
          'ライブラリは空です',
          style: MuziaTextStyles.screenTitle.copyWith(color: colors.fgPrimary),
        ),
        const SizedBox(height: MuziaSpacing.s2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            '音楽フォルダを登録すると、ここに楽曲が表示されます。',
            textAlign: TextAlign.center,
            style: MuziaTextStyles.body.copyWith(color: colors.fgSecondary),
          ),
        ),
        const SizedBox(height: MuziaSpacing.s5),
        FilledButton.icon(
          onPressed: () => unawaited(onPickFolder()),
          icon: const Icon(Icons.folder_open, size: 16),
          label: const Text('フォルダを登録'),
        ),
      ],
    );
  }
}

class _TrackTable extends StatefulWidget {
  const _TrackTable({
    required this.tracks,
    required this.catalog,
    this.highlightQuery = '',
    required this.onRemove,
    required this.onEdit,
    required this.onBulkEdit,
    required this.onPlay,
    required this.playingPath,
    required this.playbackActive,
  });

  final List<Track> tracks;

  /// ライブラリ全体。編集ダイアログのジャンル候補やアルバム収録曲の参照に使う。
  final LibraryCatalog catalog;

  /// 検索中の語。行のタイトル/アーティスト/アルバムの一致箇所をハイライトする。
  final String highlightQuery;
  final Future<bool> Function(List<Track> tracks) onRemove;
  final Future<bool> Function(Track track, MetadataValues values) onEdit;
  final Future<bool> Function(List<Track> tracks, MetadataValues values)
  onBulkEdit;
  final ValueChanged<Track> onPlay;
  final String? playingPath;
  final bool playbackActive;

  @override
  State<_TrackTable> createState() => _TrackTableState();
}

class _TrackTableState extends State<_TrackTable> {
  final Set<String> _selectedPaths = {};
  final _focusNode = FocusNode(debugLabel: 'track-table');
  int? _anchorIndex;
  int? _lastTapIndex;
  DateTime? _lastTapTime;

  /// ヘッダクリックのソート状態。永続化しない（起動時は登録順）。
  TrackSort? _sort;

  /// 表示順（ソート適用後）。build で更新し、クリック位置の解決に使う。
  List<Track> _visible = const [];

  static bool get _isMac => defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  List<Track> get _selectedTracks => _visible
      .where((track) => _selectedPaths.contains(track.filePath))
      .toList(growable: false);

  /// ⌘I（Windows は Ctrl+I）: 1曲選択なら曲編集、2曲以上なら一括編集を開く。
  void _editSelected() {
    final selected = _selectedTracks;
    if (selected.length == 1) {
      unawaited(_editTrack(selected.single));
    } else if (selected.length >= 2) {
      unawaited(_bulkEdit());
    }
  }

  void _toggleSort(TrackSortField field) {
    setState(() => _sort = _sort?.toggled(field) ?? TrackSort(field));
  }

  TrackActions get _actions => TrackActions(
    onPlay: widget.onPlay,
    onEdit: widget.onEdit,
    onRemove: widget.onRemove,
  );

  Future<void> _confirmRemove(List<Track> targets) async {
    if (await _actions.confirmRemove(context, targets) && mounted) {
      setState(_selectedPaths.clear);
    }
  }

  Future<void> _editTrack(Track track) =>
      _actions.editTrack(context, track, widget.catalog);

  Future<void> _bulkEdit() async {
    final selected = _selectedTracks;
    BulkEditRequest? request;
    while (mounted) {
      final plan = await showDialog<BulkEditPlan>(
        context: context,
        builder: (context) => BulkMetadataEditDialog(
          tracks: selected,
          catalog: widget.catalog,
          initialRequest: request,
        ),
      );
      if (plan == null || !mounted) return;
      // REQ-004: 分割/リネームを含む適用内容と対象曲数を確認してから書き込む。
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => BulkEditConfirmDialog(plan: plan),
      );
      if (!mounted) return;
      if (confirmed == false) {
        // 「戻る」: 入力内容を保ったまま編集ダイアログへ戻る。
        request = plan.request;
        continue;
      }
      if (confirmed == true &&
          await widget.onBulkEdit(plan.targets, plan.values) &&
          mounted) {
        setState(_selectedPaths.clear);
      }
      return;
    }
  }

  void _handlePrimaryDown(int index) {
    _focusNode.requestFocus();
    final track = _visible[index];
    final now = DateTime.now();
    final isDoubleClick =
        _lastTapIndex == index &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 400);
    _lastTapIndex = index;
    _lastTapTime = now;
    if (isDoubleClick) {
      widget.onPlay(track);
      return;
    }
    final keyboard = HardwareKeyboard.instance;
    final toggles = keyboard.isMetaPressed || keyboard.isControlPressed;
    final extends_ = keyboard.isShiftPressed && _anchorIndex != null;
    setState(() {
      if (toggles) {
        if (!_selectedPaths.remove(track.filePath)) {
          _selectedPaths.add(track.filePath);
          _anchorIndex = index;
        }
      } else if (extends_) {
        final start = _anchorIndex! < index ? _anchorIndex! : index;
        final end = _anchorIndex! < index ? index : _anchorIndex!;
        _selectedPaths
          ..clear()
          ..addAll(
            _visible.sublist(start, end + 1).map((track) => track.filePath),
          );
      } else {
        _selectedPaths
          ..clear()
          ..add(track.filePath);
        _anchorIndex = index;
      }
    });
  }

  Future<void> _showContextMenu(int index, Offset globalPosition) async {
    final track = _visible[index];
    if (!_selectedPaths.contains(track.filePath)) {
      setState(() {
        _selectedPaths
          ..clear()
          ..add(track.filePath);
        _anchorIndex = index;
      });
    }
    final action = await showTrackContextMenu(context, globalPosition);
    if (!mounted) return;
    switch (action) {
      case TrackMenuAction.play:
        widget.onPlay(track);
      case TrackMenuAction.edit:
        await _editTrack(track);
      case TrackMenuAction.remove:
        final selected = _selectedTracks;
        await _confirmRemove(selected.contains(track) ? selected : [track]);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    _visible = sortTracks(widget.tracks, _sort);
    final headerStyle = MuziaTextStyles.caption.copyWith(
      color: colors.fgTertiary,
    );
    return CallbackShortcuts(
      bindings: {
        SingleActivator(
          LogicalKeyboardKey.keyI,
          meta: _isMac,
          control: !_isMac,
        ): _editSelected,
      },
      child: Focus(
        focusNode: _focusNode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedPaths.length >= 2)
              Container(
                key: const ValueKey('selection-bar'),
                height: 44,
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  border: Border(
                    bottom: BorderSide(color: colors.accentBorder, width: 0.5),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(18, 0, 14, 0),
                child: Row(
                  children: [
                    Text(
                      '${_selectedPaths.length} 曲を選択中',
                      style: MuziaTextStyles.rowTitle.copyWith(
                        color: colors.fgPrimary,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _bulkEdit,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('一括編集'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 28),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: MuziaTextStyles.rowTitle,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: MuziaSpacing.s4),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.borderSubtle)),
              ),
              child: _TrackCells(
                number: Text(
                  '#',
                  textAlign: TextAlign.right,
                  style: headerStyle,
                ),
                title: _SortableHeader(
                  label: 'タイトル',
                  field: TrackSortField.title,
                  sort: _sort,
                  onTap: _toggleSort,
                ),
                artist: _SortableHeader(
                  label: 'アーティスト',
                  field: TrackSortField.artist,
                  sort: _sort,
                  onTap: _toggleSort,
                ),
                album: _SortableHeader(
                  label: 'アルバム',
                  field: TrackSortField.album,
                  sort: _sort,
                  onTap: _toggleSort,
                ),
                time: _SortableHeader(
                  label: '時間',
                  field: TrackSortField.duration,
                  sort: _sort,
                  onTap: _toggleSort,
                  alignEnd: true,
                ),
                trailing: const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _visible.length,
                itemExtent: 30,
                itemBuilder: (context, index) {
                  final track = _visible[index];
                  return _TrackRow(
                    key: ValueKey('track-row-$index'),
                    index: index,
                    track: track,
                    selected: _selectedPaths.contains(track.filePath),
                    playing: widget.playingPath == track.filePath,
                    playbackActive: widget.playbackActive,
                    highlightQuery: widget.highlightQuery,
                    onPrimaryDown: () => _handlePrimaryDown(index),
                    onSecondaryDown: (position) =>
                        unawaited(_showContextMenu(index, position)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// クリックでソートを切り替えるヘッダセル。ソート中の列は色を上げて方向を示す。
class _SortableHeader extends StatelessWidget {
  const _SortableHeader({
    required this.label,
    required this.field,
    required this.sort,
    required this.onTap,
    this.alignEnd = false,
  });

  final String label;
  final TrackSortField field;
  final TrackSort? sort;
  final ValueChanged<TrackSortField> onTap;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final active = sort?.field == field;
    final color = active ? colors.fgSecondary : colors.fgTertiary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: ValueKey('sort-${field.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(field),
        child: Row(
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Text(label, style: MuziaTextStyles.caption.copyWith(color: color)),
            if (active) ...[
              const SizedBox(width: 3),
              Icon(
                sort!.ascending ? Icons.arrow_downward : Icons.arrow_upward,
                size: 11,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// テーブルの列構成（ヘッダと行で共有する）。
class _TrackCells extends StatelessWidget {
  const _TrackCells({
    required this.number,
    required this.title,
    required this.artist,
    required this.album,
    required this.time,
    required this.trailing,
  });

  final Widget number;
  final Widget title;
  final Widget artist;
  final Widget album;
  final Widget time;

  /// 最右列（36px）。行ではケバブ（⋮）、ヘッダでは空。
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 40, child: number),
        const SizedBox(width: MuziaSpacing.s4),
        Expanded(flex: 3, child: title),
        const SizedBox(width: MuziaSpacing.s4),
        Expanded(flex: 2, child: artist),
        const SizedBox(width: MuziaSpacing.s4),
        Expanded(flex: 2, child: album),
        const SizedBox(width: MuziaSpacing.s4),
        SizedBox(width: 56, child: time),
        const SizedBox(width: MuziaSpacing.s2),
        SizedBox(width: 36, child: trailing),
      ],
    );
  }
}

class _TrackRow extends StatefulWidget {
  const _TrackRow({
    super.key,
    required this.index,
    required this.track,
    required this.selected,
    required this.playing,
    required this.playbackActive,
    required this.highlightQuery,
    required this.onPrimaryDown,
    required this.onSecondaryDown,
  });

  final int index;
  final Track track;
  final bool selected;
  final bool playing;
  final bool playbackActive;
  final String highlightQuery;
  final VoidCallback onPrimaryDown;
  final ValueChanged<Offset> onSecondaryDown;

  @override
  State<_TrackRow> createState() => _TrackRowState();
}

class _TrackRowState extends State<_TrackRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final selected = widget.selected;
    final background = selected
        ? colors.accent
        : _hovered
        ? colors.rowHover
        : widget.index.isOdd
        ? colors.rowStripe
        : Colors.transparent;
    final unavailable = !widget.track.isAvailable;
    // 利用不可の行は淡色化する（タイトルは secondary、それ以外は tertiary）。
    final titleColor = selected
        ? colors.onAccent
        : unavailable
        ? colors.fgSecondary
        : widget.playing
        ? colors.accentText
        : colors.fgPrimary;
    final secondaryColor = selected
        ? colors.onAccent
        : unavailable
        ? colors.fgTertiary
        : colors.fgSecondary;
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == kSecondaryMouseButton) {
          widget.onSecondaryDown(event.position);
        } else {
          widget.onPrimaryDown();
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            border: Border(
              bottom: BorderSide(
                color: selected ? Colors.transparent : colors.rowDivider,
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: MuziaSpacing.s4),
          child: _TrackCells(
            number: widget.playing
                ? NowPlayingEqualizer(
                    color: selected ? colors.onAccent : colors.accent,
                    animating: widget.playbackActive,
                  )
                : Text(
                    '${widget.index + 1}',
                    textAlign: TextAlign.right,
                    style: MuziaTextStyles.body.copyWith(
                      color: selected ? colors.onAccent : colors.fgTertiary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
            title: Row(
              children: [
                Flexible(
                  child: _HighlightedText(
                    widget.track.title?.isNotEmpty == true
                        ? widget.track.title!
                        : 'タイトル不明',
                    query: widget.highlightQuery,
                    style: MuziaTextStyles.rowTitle.copyWith(color: titleColor),
                  ),
                ),
                if (unavailable) ...[
                  const SizedBox(width: MuziaSpacing.s2),
                  _UnavailableFlag(selected: selected),
                ],
              ],
            ),
            artist: _HighlightedText(
              widget.track.artist ?? 'アーティスト不明',
              query: widget.highlightQuery,
              style: MuziaTextStyles.body.copyWith(color: secondaryColor),
            ),
            album: _HighlightedText(
              widget.track.album ?? 'アルバム不明',
              query: widget.highlightQuery,
              style: MuziaTextStyles.body.copyWith(color: secondaryColor),
            ),
            time: Text(
              formatTrackDuration(unavailable ? null : widget.track.durationMs),
              textAlign: TextAlign.right,
              style: MuziaTextStyles.body.copyWith(
                color: secondaryColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            trailing: _KebabButton(
              key: ValueKey('track-kebab-${widget.index}'),
              selected: selected,
              onPressed: widget.onSecondaryDown,
            ),
          ),
        ),
      ),
    );
  }
}

/// ツールバー右端の検索フィールド（`.search` / `.search.on`）。
///
/// 196×26・角丸4。非フォーカス時は gray-a3 の塗りで枠なし、フォーカス時は
/// 白背景＋ヘアライン枠＋アクセントの柔らかいリング。
class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final focused = widget.focusNode.hasFocus;
    return Padding(
      padding: const EdgeInsets.only(right: MuziaSpacing.s4),
      child: Container(
        key: const ValueKey('search-field'),
        width: 196,
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: MuziaSpacing.s2),
        decoration: BoxDecoration(
          color: focused ? colors.windowBg : colors.rowHover,
          borderRadius: BorderRadius.circular(MuziaRadius.r2),
          border: focused ? Border.all(color: colors.borderSubtle) : null,
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.2),
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 14, color: colors.fgTertiary),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                key: const ValueKey('library-search'),
                controller: widget.controller,
                focusNode: widget.focusNode,
                onChanged: widget.onChanged,
                style: MuziaTextStyles.body.copyWith(color: colors.fgPrimary),
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: '検索',
                  hintStyle: MuziaTextStyles.body.copyWith(
                    color: colors.fgTertiary,
                  ),
                ),
              ),
            ),
            if (widget.query.isNotEmpty)
              GestureDetector(
                onTap: widget.onClear,
                child: Icon(Icons.clear, size: 14, color: colors.fgTertiary),
              ),
          ],
        ),
      ),
    );
  }
}

/// 利用不可の楽曲に付ける amber のフラグ（`.miss-flag`）。
class _UnavailableFlag extends StatelessWidget {
  const _UnavailableFlag({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final color = selected ? colors.onAccent : colors.warnText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: selected ? colors.onAccent : colors.warn,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '利用不可',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// 行右端のケバブ（⋮）。クリックでコンテキストメニューをボタン位置に開く。
class _KebabButton extends StatefulWidget {
  const _KebabButton({
    super.key,
    required this.selected,
    required this.onPressed,
  });

  final bool selected;
  final ValueChanged<Offset> onPressed;

  @override
  State<_KebabButton> createState() => _KebabButtonState();
}

class _KebabButtonState extends State<_KebabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final color = widget.selected
        ? colors.onAccent.withValues(alpha: 0.82)
        : _hovered
        ? colors.fgSecondary
        : colors.fgTertiary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final box = context.findRenderObject()! as RenderBox;
          widget.onPressed(box.localToGlobal(Offset(0, box.size.height)));
        },
        child: Center(child: Icon(Icons.more_vert, size: 16, color: color)),
      ),
    );
  }
}

/// 検索中の一覧（`14-search`）: 件数行 + アルバム / アーティスト / 楽曲のグループ。
class _SearchResultsView extends StatelessWidget {
  const _SearchResultsView({
    required this.results,
    required this.table,
    required this.onOpenInBrowser,
  });

  final SearchResults results;
  final Widget table;
  final void Function(String? artist, String? album) onOpenInBrowser;

  /// 見出し付きグループに出す最大件数。楽曲はテーブル側でスクロールする。
  static const _maxGroupRows = 5;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const ValueKey('search-result-bar'),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.borderSubtle, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 13, color: colors.fgTertiary),
              const SizedBox(width: 6),
              Text(
                '${formatCount(results.total)} 件の結果: “${results.query}”',
                style: MuziaTextStyles.secondary.copyWith(
                  color: colors.fgTertiary,
                ),
              ),
            ],
          ),
        ),
        if (results.albums.isNotEmpty) ...[
          const _GroupHeader('アルバム'),
          for (final album in results.albums.take(_maxGroupRows))
            _ResultRow(
              key: ValueKey('search-album-${album.name}'),
              name: album.name,
              query: results.query,
              meta: [
                ?album.artist,
                '${formatCount(album.trackCount)}曲',
              ].join(' · '),
              icon: Icons.album_outlined,
              circular: false,
              onTap: () => onOpenInBrowser(album.artist, album.name),
            ),
        ],
        if (results.artists.isNotEmpty) ...[
          const _GroupHeader('アーティスト'),
          for (final artist in results.artists.take(_maxGroupRows))
            _ResultRow(
              key: ValueKey('search-artist-${artist.name}'),
              name: artist.name,
              query: results.query,
              meta:
                  '${formatCount(artist.albumCount)}アルバム · '
                  '${formatCount(artist.trackCount)}曲',
              icon: Icons.person_outline,
              circular: true,
              onTap: () => onOpenInBrowser(artist.name, null),
            ),
        ],
        if (results.tracks.isNotEmpty) ...[
          const _GroupHeader('楽曲'),
          Expanded(child: table),
        ] else
          const Spacer(),
      ],
    );
  }
}

/// グループ見出し（`.group-head`）: 11px bold、fgTertiary。
class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 5),
      child: Text(
        label,
        style: MuziaTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.fgTertiary,
        ),
      ),
    );
  }
}

/// アルバム / アーティストの結果行（`.res-album`）。クリックでブラウザの該当箇所を開く。
class _ResultRow extends StatelessWidget {
  const _ResultRow({
    super.key,
    required this.name,
    required this.query,
    required this.meta,
    required this.icon,
    required this.circular,
    required this.onTap,
  });

  final String name;
  final String query;
  final String meta;
  final IconData icon;
  final bool circular;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return InkWell(
      onTap: onTap,
      hoverColor: colors.rowStripe,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.rowHover,
                shape: circular ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: circular
                    ? null
                    : BorderRadius.circular(MuziaRadius.r2),
                boxShadow: MuziaShadows.card,
              ),
              child: Icon(icon, size: 18, color: colors.fgTertiary),
            ),
            const SizedBox(width: MuziaSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(
                    name,
                    query: query,
                    style: MuziaTextStyles.rowTitle.copyWith(
                      color: colors.fgPrimary,
                    ),
                  ),
                  Text(
                    meta,
                    overflow: TextOverflow.ellipsis,
                    style: MuziaTextStyles.secondary.copyWith(
                      color: colors.fgSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 検索語に一致した部分を gold-a4 の背景で強調するテキスト（`mark`）。
class _HighlightedText extends StatelessWidget {
  const _HighlightedText(this.text, {required this.query, required this.style});

  final String text;
  final String query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final range = LibrarySearch.matchRange(text, query);
    if (range == null) {
      return Text(text, overflow: TextOverflow.ellipsis, style: style);
    }
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, range.start)),
          TextSpan(
            text: text.substring(range.start, range.end),
            style: TextStyle(
              backgroundColor: colors.highlight,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(text: text.substring(range.end)),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _PlayerArea extends StatelessWidget {
  const _PlayerArea({required this.viewModel});

  final PlayerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final track = viewModel.track;
    return Container(
      key: const ValueKey('player-bar'),
      height: 74,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: MuziaSpacing.s4),
      decoration: BoxDecoration(
        color: colors.sidebarBg,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: [
          // 左: 現在の曲情報
          SizedBox(
            width: 240,
            child: track == null
                ? Text(
                    '再生する楽曲が選択されていません',
                    style: MuziaTextStyles.secondary.copyWith(
                      color: colors.fgTertiary,
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colors.rowHover,
                          borderRadius: BorderRadius.circular(MuziaRadius.r2),
                          border: Border.all(color: colors.borderSubtle),
                        ),
                        child: Icon(
                          Icons.music_note,
                          size: 18,
                          color: colors.fgTertiary,
                        ),
                      ),
                      const SizedBox(width: MuziaSpacing.s3),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title ?? 'タイトル不明',
                              overflow: TextOverflow.ellipsis,
                              style: MuziaTextStyles.rowTitle.copyWith(
                                color: colors.fgPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                track.artist ?? 'アーティスト不明',
                                ?track.album,
                              ].join(' — '),
                              overflow: TextOverflow.ellipsis,
                              style: MuziaTextStyles.secondary.copyWith(
                                color: colors.fgSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          // 中央: transportとシークバー
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TODO(playback): 前後スキップ・シークは再生キュー未実装のため
                    // 無効化している。対応時に別課題で有効化する。
                    IconButton(
                      key: const ValueKey('playback-previous'),
                      tooltip: '前の曲（未対応）',
                      onPressed: null,
                      iconSize: 18,
                      disabledColor: colors.fgTertiary,
                      icon: const Icon(Icons.skip_previous),
                    ),
                    const SizedBox(width: MuziaSpacing.s1),
                    if (viewModel.status == PlaybackStatus.loading)
                      const SizedBox(
                        width: 34,
                        height: 34,
                        child: Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: IconButton.filled(
                          key: const ValueKey('playback-toggle'),
                          tooltip: viewModel.isPlaying ? '一時停止' : '再生',
                          onPressed: track == null
                              ? null
                              : viewModel.togglePause,
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: colors.fgPrimary,
                            foregroundColor: colors.windowBg,
                            disabledBackgroundColor: colors.rowHover,
                          ),
                          icon: Icon(
                            viewModel.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ),
                    const SizedBox(width: MuziaSpacing.s1),
                    IconButton(
                      key: const ValueKey('playback-next'),
                      tooltip: '次の曲（未対応）',
                      onPressed: null,
                      iconSize: 18,
                      disabledColor: colors.fgTertiary,
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
                SizedBox(
                  width: 420,
                  height: 14,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                        disabledThumbRadius: 5,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                      disabledActiveTrackColor: colors.accent,
                      disabledInactiveTrackColor: colors.borderSubtle,
                      disabledThumbColor: colors.windowBg,
                    ),
                    child: const Slider(
                      key: ValueKey('playback-seek'),
                      // TODO(playback): 再生位置の取得・シーク未対応のため無効。
                      value: 0,
                      onChanged: null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 右: エラー表示と音量（音量は未対応のため無効）
          SizedBox(
            width: 240,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (viewModel.status == PlaybackStatus.error)
                  Expanded(
                    child: Text(
                      viewModel.errorMessage ?? '再生に失敗しました。',
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: MuziaTextStyles.secondary.copyWith(
                        color: colors.destructive,
                      ),
                    ),
                  ),
                const SizedBox(width: MuziaSpacing.s2),
                IconButton(
                  tooltip: '音量（未対応）',
                  onPressed: null,
                  iconSize: 18,
                  disabledColor: colors.fgTertiary,
                  icon: const Icon(Icons.volume_up),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
