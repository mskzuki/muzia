import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muzia/app/providers.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/artist_album_browser.dart';
import 'package:muzia/features/library/presentation/bulk_edit_confirm_dialog.dart';
import 'package:muzia/features/library/presentation/library_removal_dialog.dart';
import 'package:muzia/features/library/domain/bulk_edit_plan.dart';
import 'package:muzia/features/library/domain/library_catalog.dart';
import 'package:muzia/features/library/domain/library_search.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/domain/track_sort.dart';
import 'package:muzia/features/library/presentation/metadata_edit_dialog.dart';
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        backgroundColor: colors.sidebarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: colors.borderSubtle)),
        titleSpacing: MuziaSpacing.s4,
        title: Row(
          children: [
            Text(
              sectionTitle,
              style: MuziaTextStyles.windowTitle.copyWith(
                color: colors.fgPrimary,
              ),
            ),
            if (libraryViewModel.canShowTracks) ...[
              const SizedBox(width: MuziaSpacing.s2),
              Text(
                '${libraryViewModel.tracks.length}曲',
                style: MuziaTextStyles.secondary.copyWith(
                  color: colors.fgSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: 240,
            height: 30,
            child: TextField(
              key: const ValueKey('library-search'),
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: MuziaTextStyles.body.copyWith(color: colors.fgPrimary),
              decoration: InputDecoration(
                hintText: '検索',
                hintStyle: MuziaTextStyles.body.copyWith(
                  color: colors.fgTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 16,
                  color: colors.fgTertiary,
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        color: colors.fgTertiary,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                filled: true,
                fillColor: colors.windowBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MuziaRadius.r3),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MuziaRadius.r3),
                  borderSide: BorderSide(color: colors.accent, width: 2),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: MuziaSpacing.s4),
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
                    onPlay: playerViewModel.play,
                    playingPath: playerViewModel.track?.filePath,
                    playbackActive: playerViewModel.isPlaying,
                    onPickFolder: libraryViewModel.chooseAndScanFolder,
                  ),
                ),
              ],
            ),
          ),
          _PlayerArea(viewModel: playerViewModel),
        ],
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

  @override
  Widget build(BuildContext context) {
    if (section != _LibrarySection.library && libraryViewModel.canShowTracks) {
      return Padding(
        padding: const EdgeInsets.all(MuziaSpacing.s6),
        child: ArtistAlbumBrowser(tracks: libraryViewModel.tracks),
      );
    }
    final visibleTracks = LibrarySearch.filter(
      libraryViewModel.tracks,
      searchQuery,
    );
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
        ? _StatusMessage(
            icon: Icons.error_outline,
            title: '読み込みエラー',
            message: viewModel.errorMessage ?? 'ライブラリを読み込めませんでした。',
          )
        : switch (libraryViewModel.status) {
            LibraryStatus.loading => const _StatusMessage(
              icon: Icons.hourglass_top,
              title: 'ライブラリを読み込んでいます',
              message: '準備が完了するまでお待ちください。',
            ),
            LibraryStatus.empty => _EmptyLibrary(onPickFolder: onPickFolder),
            LibraryStatus.error => _StatusMessage(
              icon: Icons.error_outline,
              title: '読み込みエラー',
              message: libraryViewModel.errorMessage ?? 'ライブラリを読み込めませんでした。',
            ),
            // 一覧を表示できる2つの状態は、検索0件の扱いも同じ。
            LibraryStatus.ready || LibraryStatus.readyWithWarnings =>
              searchQuery.trim().isNotEmpty && visibleTracks.isEmpty
                  ? const _StatusMessage(
                      icon: Icons.search_off,
                      title: '該当する楽曲がありません',
                      message: 'タイトル、アーティスト、アルバムを確認してください。',
                    )
                  : null,
          };
    final content = status != null
        ? Padding(
            padding: const EdgeInsets.all(MuziaSpacing.s6),
            child: Center(child: status),
          )
        : _TrackTable(
            tracks: visibleTracks,
            catalog: LibraryCatalog(libraryViewModel.tracks),
            onRemove: libraryViewModel.removeTracks,
            onEdit: (track, values) =>
                libraryViewModel.updateTrackMetadata(track, values),
            onBulkEdit: libraryViewModel.updateTracksMetadata,
            onPlay: onPlay,
            playingPath: playingPath,
            playbackActive: playbackActive,
          );

    // 警告は一覧の外に出す。検索0件の空状態でも通知が消えないようにする。
    final warningMessage = libraryViewModel.warningMessage;
    final showsWarning =
        showsLibrary &&
        libraryViewModel.canShowTracks &&
        warningMessage != null;
    return Column(
      children: [
        if (showsWarning)
          _WarningNotice(
            title: libraryViewModel.warningTitle ?? '警告',
            message: warningMessage,
          ),
        Expanded(child: content),
      ],
    );
  }
}

class _WarningNotice extends StatelessWidget {
  const _WarningNotice({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return KeyedSubtree(
      key: const ValueKey('warning-banner'),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.warnSurface,
          border: Border(bottom: BorderSide(color: colors.borderSubtle)),
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
              style: MuziaTextStyles.rowTitle.copyWith(color: colors.warnText),
            ),
            const SizedBox(width: MuziaSpacing.s2),
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                style: MuziaTextStyles.body.copyWith(color: colors.warnText),
              ),
            ),
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
            borderRadius: BorderRadius.circular(MuziaRadius.r6),
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

  /// コンテキストメニューに表記する「曲を編集…」のショートカット。
  static String get editShortcutLabel => _isMac ? '⌘I' : 'Ctrl+I';

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

  Future<void> _confirmRemove(List<Track> targets) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => LibraryRemovalDialog(count: targets.length),
    );
    if (confirmed != true || !mounted) return;
    if (await widget.onRemove(targets) && mounted) {
      setState(_selectedPaths.clear);
    }
  }

  Future<void> _editTrack(Track track) async {
    final values = await showDialog<MetadataValues>(
      context: context,
      builder: (context) => MetadataEditDialog(
        track: track,
        genreSuggestions: widget.catalog.genres,
      ),
    );
    if (values != null) await widget.onEdit(track, values);
  }

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
    final colors = Theme.of(context).extension<MuziaColors>()!;
    final track = _visible[index];
    if (!_selectedPaths.contains(track.filePath)) {
      setState(() {
        _selectedPaths
          ..clear()
          ..add(track.filePath);
        _anchorIndex = index;
      });
    }
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MuziaRadius.r3),
      ),
      items: [
        PopupMenuItem(
          value: 'play',
          height: 32,
          child: Text('曲を再生', style: MuziaTextStyles.body),
        ),
        PopupMenuItem(
          value: 'edit',
          height: 32,
          child: Row(
            children: [
              const Expanded(child: Text('曲を編集…', style: MuziaTextStyles.body)),
              const SizedBox(width: MuziaSpacing.s4),
              Text(
                editShortcutLabel,
                style: MuziaTextStyles.caption.copyWith(
                  color: colors.fgTertiary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          height: 32,
          child: Text(
            'ライブラリから削除…',
            style: MuziaTextStyles.body.copyWith(color: colors.destructive),
          ),
        ),
      ],
    );
    if (!mounted) return;
    switch (action) {
      case 'play':
        widget.onPlay(track);
      case 'edit':
        await _editTrack(track);
      case 'remove':
        final selected = _selectedTracks;
        await _confirmRemove(selected.contains(track) ? selected : [track]);
      case _:
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
                color: colors.accentSoft,
                padding: const EdgeInsets.symmetric(
                  horizontal: MuziaSpacing.s4,
                  vertical: MuziaSpacing.s1,
                ),
                child: Row(
                  children: [
                    Text(
                      '${_selectedPaths.length}曲を選択中',
                      style: MuziaTextStyles.rowTitle.copyWith(
                        color: colors.accentText,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _bulkEdit,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('一括編集'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
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

/// 再生中行の #セルに出す3本バーのイコライザ（`.eq`）。
///
/// 再生中だけ 0.9 秒周期で動き、一時停止中と Reduce Motion 時は静止する。
class _Equalizer extends StatefulWidget {
  const _Equalizer({required this.color, required this.animating});

  final Color color;
  final bool animating;

  @override
  State<_Equalizer> createState() => _EqualizerState();
}

class _EqualizerState extends State<_Equalizer>
    with SingleTickerProviderStateMixin {
  static const _heights = [0.6, 1.0, 0.4];
  static const _phases = [-0.2 / 0.9, -0.5 / 0.9, 0.0];
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MuziaMotion.equalizerLoop,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate =
        widget.animating && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate && _controller.isAnimating) {
      _controller.stop();
    }
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        key: const ValueKey('now-playing-equalizer'),
        height: 11,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 1.5),
                _bar(i, animate),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(int index, bool animate) {
    // 0% と 100% で scaleY(0.35)、50% で scaleY(1) の ease-in-out。静止時は 0.7。
    final t = (_controller.value + _phases[index]) % 1;
    final scale = animate
        ? 0.35 + 0.65 * (0.5 - 0.5 * math.cos(2 * math.pi * t))
        : 0.7;
    return Container(
      width: 2,
      height: 11 * _heights[index] * scale,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(1),
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
  });

  final Widget number;
  final Widget title;
  final Widget artist;
  final Widget album;
  final Widget time;

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
    required this.onPrimaryDown,
    required this.onSecondaryDown,
  });

  final int index;
  final Track track;
  final bool selected;
  final bool playing;
  final bool playbackActive;
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
    final titleColor = selected
        ? colors.onAccent
        : widget.playing
        ? colors.accentText
        : colors.fgPrimary;
    final secondaryColor = selected ? colors.onAccent : colors.fgSecondary;
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
          color: background,
          padding: const EdgeInsets.symmetric(horizontal: MuziaSpacing.s4),
          child: _TrackCells(
            number: widget.playing
                ? _Equalizer(
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
            title: Text(
              widget.track.title?.isNotEmpty == true
                  ? widget.track.title!
                  : 'タイトル不明',
              overflow: TextOverflow.ellipsis,
              style: MuziaTextStyles.rowTitle.copyWith(color: titleColor),
            ),
            artist: Text(
              widget.track.artist ?? 'アーティスト不明',
              overflow: TextOverflow.ellipsis,
              style: MuziaTextStyles.body.copyWith(color: secondaryColor),
            ),
            album: Text(
              widget.track.album ?? 'アルバム不明',
              overflow: TextOverflow.ellipsis,
              style: MuziaTextStyles.body.copyWith(color: secondaryColor),
            ),
            time: Text(
              formatTrackDuration(widget.track.durationMs),
              textAlign: TextAlign.right,
              style: MuziaTextStyles.body.copyWith(
                color: secondaryColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
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
                              track.artist ?? 'アーティスト不明',
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
