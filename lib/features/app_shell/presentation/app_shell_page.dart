import 'dart:async';

import 'package:flutter/material.dart';
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
    final viewModel = ref.watch(appShellViewModelProvider);
    final libraryViewModel = ref.watch(libraryViewModelProvider);
    final playerViewModel = ref.watch(playerViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muzia'),
        toolbarHeight: 56,
        actions: [
          SizedBox(
            width: 240,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextField(
                key: const ValueKey('library-search'),
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: '検索',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
    required this.onSectionChanged,
  });

  /// `VoidCallback` として受け取るとFutureが破棄され、失敗が握りつぶされる。
  /// 非同期であることを型で表し、[LibraryViewModel] 側のエラー状態へ委ねる。
  final Future<void> Function() onPickFolder;
  final _LibrarySection section;
  final ValueChanged<_LibrarySection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ライブラリ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('楽曲'),
                selected: section == _LibrarySection.library,
                onTap: () => onSectionChanged(_LibrarySection.library),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('アーティスト / アルバム'),
                selected: section == _LibrarySection.artistAlbum,
                onTap: () => onSectionChanged(_LibrarySection.artistAlbum),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => unawaited(onPickFolder()),
                icon: const Icon(Icons.folder_open),
                label: const Text('フォルダを登録'),
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
  });

  final AppShellViewModel viewModel;
  final LibraryViewModel libraryViewModel;
  final _LibrarySection section;
  final String searchQuery;
  final ValueChanged<Track> onPlay;

  @override
  Widget build(BuildContext context) {
    if (section == _LibrarySection.artistAlbum &&
        libraryViewModel.canShowTracks) {
      return Padding(
        padding: const EdgeInsets.all(32),
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
    final content = viewModel.status == AppShellStatus.loading
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
            LibraryStatus.empty => const _EmptyLibrary(),
            LibraryStatus.error => _StatusMessage(
              icon: Icons.error_outline,
              title: '読み込みエラー',
              message: libraryViewModel.errorMessage ?? 'ライブラリを読み込めませんでした。',
            ),
            // 一覧を表示できる2つの状態は、検索0件の扱いも同じ。
            LibraryStatus.ready ||
            LibraryStatus.readyWithWarnings =>
              searchQuery.trim().isNotEmpty && visibleTracks.isEmpty
                  ? const _StatusMessage(
                      icon: Icons.search_off,
                      title: '該当する楽曲がありません',
                      message: 'タイトル、アーティスト、アルバムを確認してください。',
                    )
                  : _TrackList(
                      tracks: visibleTracks,
                      onRemove: libraryViewModel.removeTracks,
                      onEdit: (track, values) =>
                          libraryViewModel.updateTrackMetadata(track, values),
                      onBulkEdit: libraryViewModel.updateTracksMetadata,
                      onPlay: onPlay,
                    ),
          };

    // 警告は一覧の外に出す。検索0件の空状態でも通知が消えないようにする。
    final warningMessage = libraryViewModel.warningMessage;
    final showsWarning =
        showsLibrary && libraryViewModel.canShowTracks && warningMessage != null;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          if (showsWarning)
            _WarningNotice(
              title: libraryViewModel.warningTitle ?? '警告',
              message: warningMessage,
            ),
          Expanded(child: Center(child: content)),
        ],
      ),
    );
  }
}

class _WarningNotice extends StatelessWidget {
  const _WarningNotice({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.warning_amber_outlined),
      title: Text(title),
      subtitle: Text(message),
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

class _EmptyLibrary extends _StatusMessage {
  const _EmptyLibrary()
    : super(
        icon: Icons.library_music_outlined,
        title: 'ライブラリは空です',
        message: '音楽フォルダを登録すると、ここに楽曲が表示されます。',
      );
}

class _TrackList extends StatefulWidget {
  const _TrackList({
    required this.tracks,
    required this.onRemove,
    required this.onEdit,
    required this.onBulkEdit,
    required this.onPlay,
  });

  final List<Track> tracks;
  final Future<bool> Function(List<Track> tracks) onRemove;
  final Future<bool> Function(Track track, MetadataValues values) onEdit;
  final Future<bool> Function(List<Track> tracks, MetadataValues values)
  onBulkEdit;
  final ValueChanged<Track> onPlay;

  @override
  State<_TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<_TrackList> {
  final Set<String> _selectedPaths = {};

  Future<void> _confirmRemove() async {
    final selected = widget.tracks
        .where((track) => _selectedPaths.contains(track.filePath))
        .toList(growable: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => LibraryRemovalDialog(count: selected.length),
    );
    if (confirmed != true || !mounted) return;
    if (await widget.onRemove(selected) && mounted) {
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
    final selected = widget.tracks
        .where((track) => _selectedPaths.contains(track.filePath))
        .toList(growable: false);
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

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedPaths.isNotEmpty;
    return ListView.separated(
      itemCount: widget.tracks.length + (hasSelection ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (hasSelection && index == 0) {
          return Material(
            color: const Color(0x1FEDF2FE),
            child: ListTile(
              title: Text('${_selectedPaths.length}曲を選択中'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedPaths.length >= 2)
                    FilledButton.icon(
                      onPressed: _bulkEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('一括編集'),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _confirmRemove,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('削除'),
                  ),
                ],
              ),
            ),
          );
        }
        final track = widget.tracks[hasSelection ? index - 1 : index];
        return ListTile(
          leading: Checkbox(
            value: _selectedPaths.contains(track.filePath),
            onChanged: (selected) => setState(() {
              if (selected == true) {
                _selectedPaths.add(track.filePath);
              } else {
                _selectedPaths.remove(track.filePath);
              }
            }),
          ),
          title: Text(
            track.title?.isNotEmpty == true ? track.title! : 'タイトル不明',
          ),
          subtitle: Text(
            '${track.artist ?? 'アーティスト不明'} · ${track.album ?? 'アルバム不明'}',
          ),
          trailing: IconButton(
            tooltip: '曲を編集',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editTrack(track),
          ),
          onTap: () => widget.onPlay(track),
        );
      },
    );
  }
}

class _PlayerArea extends StatelessWidget {
  const _PlayerArea({required this.viewModel});

  final PlayerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: viewModel.track == null
          ? const Align(
              alignment: Alignment.centerLeft,
              child: Text('再生する楽曲が選択されていません'),
            )
          : Row(
              children: [
                const Icon(Icons.music_note, color: Color(0xFF3E63DD)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(viewModel.track!.title ?? 'タイトル不明'),
                      Text(viewModel.track!.artist ?? 'アーティスト不明'),
                    ],
                  ),
                ),
                if (viewModel.status == PlaybackStatus.error)
                  Expanded(
                    child: Text(
                      viewModel.errorMessage ?? '再生に失敗しました。',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (viewModel.status == PlaybackStatus.loading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    key: const ValueKey('playback-toggle'),
                    tooltip: viewModel.isPlaying ? '一時停止' : '再生',
                    onPressed: viewModel.togglePause,
                    icon: Icon(
                      viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
              ],
            ),
    );
  }
}
