import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muzia/app/providers.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/artist_album_browser.dart';
import 'package:muzia/features/library/presentation/library_removal_dialog.dart';
import 'package:muzia/features/library/domain/library_search.dart';
import 'package:muzia/features/library/domain/metadata_values.dart';
import 'package:muzia/features/library/presentation/metadata_edit_dialog.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

enum _LibrarySection { library, artistAlbum }

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
    final sectionTitle = _section == _LibrarySection.library
        ? '楽曲'
        : 'アーティスト / アルバム';
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
    required this.onSectionChanged,
  });

  /// `VoidCallback` として受け取るとFutureが破棄され、失敗が握りつぶされる。
  /// 非同期であることを型で表し、[LibraryViewModel] 側のエラー状態へ委ねる。
  final Future<void> Function() onPickFolder;
  final _LibrarySection section;
  final int? trackCount;
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
                icon: Icons.music_note,
                label: '楽曲',
                count: trackCount,
                selected: section == _LibrarySection.library,
                onTap: () => onSectionChanged(_LibrarySection.library),
              ),
              const SizedBox(height: 2),
              _SidebarItem(
                icon: Icons.person_outline,
                label: 'アーティスト / アルバム',
                count: null,
                selected: section == _LibrarySection.artistAlbum,
                onTap: () => onSectionChanged(_LibrarySection.artistAlbum),
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
                  '$count',
                  style: MuziaTextStyles.secondary.copyWith(
                    color: selected ? fg : colors.fgTertiary,
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
    required this.onPickFolder,
  });

  final AppShellViewModel viewModel;
  final LibraryViewModel libraryViewModel;
  final _LibrarySection section;
  final String searchQuery;
  final ValueChanged<Track> onPlay;
  final String? playingPath;
  final Future<void> Function() onPickFolder;

  @override
  Widget build(BuildContext context) {
    if (section == _LibrarySection.artistAlbum &&
        libraryViewModel.canShowTracks) {
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
            onRemove: libraryViewModel.removeTracks,
            onEdit: (track, values) =>
                libraryViewModel.updateTrackMetadata(track, values),
            onBulkEdit: libraryViewModel.updateTracksMetadata,
            onPlay: onPlay,
            playingPath: playingPath,
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
    required this.onRemove,
    required this.onEdit,
    required this.onBulkEdit,
    required this.onPlay,
    required this.playingPath,
  });

  final List<Track> tracks;
  final Future<bool> Function(List<Track> tracks) onRemove;
  final Future<bool> Function(Track track, MetadataValues values) onEdit;
  final Future<bool> Function(List<Track> tracks, MetadataValues values)
  onBulkEdit;
  final ValueChanged<Track> onPlay;
  final String? playingPath;

  @override
  State<_TrackTable> createState() => _TrackTableState();
}

class _TrackTableState extends State<_TrackTable> {
  final Set<String> _selectedPaths = {};
  int? _anchorIndex;
  int? _lastTapIndex;
  DateTime? _lastTapTime;

  List<Track> get _selectedTracks => widget.tracks
      .where((track) => _selectedPaths.contains(track.filePath))
      .toList(growable: false);

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
      builder: (context) => MetadataEditDialog(track: track),
    );
    if (values != null) await widget.onEdit(track, values);
  }

  Future<void> _bulkEdit() async {
    final selected = _selectedTracks;
    final values = await showDialog<MetadataValues>(
      context: context,
      builder: (context) => BulkMetadataEditDialog(tracks: selected),
    );
    if (values == null || !mounted) return;
    // REQ-004: 件数だけでなく、実際に書き込む項目と値を確認できるようにする。
    final changes = bulkEditableFields
        .where(values.changes)
        .map(
          (field) =>
              '・${bulkFieldLabel(field)}: ${values.valueOf(field) ?? '（空欄にする）'}',
        )
        .join('\n');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('次の変更を適用します'),
        content: Text(
          '${selected.length}曲に以下を適用します。\n\n'
          '$changes\n\n'
          '変更しない項目と元の音楽ファイルには書き込みません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('戻る'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('適用'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        await widget.onBulkEdit(selected, values) &&
        mounted) {
      setState(_selectedPaths.clear);
    }
  }

  void _handlePrimaryDown(int index) {
    final track = widget.tracks[index];
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
            widget.tracks
                .sublist(start, end + 1)
                .map((track) => track.filePath),
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
    final track = widget.tracks[index];
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
          child: Text('曲を編集…', style: MuziaTextStyles.body),
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
        await _confirmRemove(
          selected.contains(track) ? selected : [track],
        );
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MuziaColors>()!;
    return Column(
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
              style: MuziaTextStyles.caption.copyWith(
                color: colors.fgTertiary,
              ),
            ),
            title: Text(
              'タイトル',
              style: MuziaTextStyles.caption.copyWith(
                color: colors.fgTertiary,
              ),
            ),
            artist: Text(
              'アーティスト',
              style: MuziaTextStyles.caption.copyWith(
                color: colors.fgTertiary,
              ),
            ),
            album: Text(
              'アルバム',
              style: MuziaTextStyles.caption.copyWith(
                color: colors.fgTertiary,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.tracks.length,
            itemExtent: 30,
            itemBuilder: (context, index) {
              final track = widget.tracks[index];
              return _TrackRow(
                key: ValueKey('track-row-$index'),
                index: index,
                track: track,
                selected: _selectedPaths.contains(track.filePath),
                playing: widget.playingPath == track.filePath,
                onPrimaryDown: () => _handlePrimaryDown(index),
                onSecondaryDown: (position) =>
                    unawaited(_showContextMenu(index, position)),
              );
            },
          ),
        ),
      ],
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
  });

  final Widget number;
  final Widget title;
  final Widget artist;
  final Widget album;

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
    required this.onPrimaryDown,
    required this.onSecondaryDown,
  });

  final int index;
  final Track track;
  final bool selected;
  final bool playing;
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
            number: Text(
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
