import 'package:flutter/material.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/artist_album_browser.dart';
import 'package:muzia/features/library/presentation/library_removal_dialog.dart';

enum _LibrarySection { library, artistAlbum }

class AppShellPage extends StatefulWidget {
  const AppShellPage({
    super.key,
    required this.viewModel,
    required this.libraryViewModel,
  });

  final AppShellViewModel viewModel;
  final LibraryViewModel libraryViewModel;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  _LibrarySection _section = _LibrarySection.library;
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    widget.libraryViewModel.addListener(_onViewModelChanged);
    widget.viewModel.initialize();
    widget.libraryViewModel.initialize();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    widget.libraryViewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Muzia'), toolbarHeight: 56),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _Sidebar(
                  onPickFolder: widget.libraryViewModel.chooseAndScanFolder,
                  section: _section,
                  onSectionChanged: (section) =>
                      setState(() => _section = section),
                ),
                Expanded(
                  child: _MainContent(
                    viewModel: widget.viewModel,
                    libraryViewModel: widget.libraryViewModel,
                    section: _section,
                  ),
                ),
              ],
            ),
          ),
          const _PlayerArea(),
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

  final VoidCallback onPickFolder;
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
                onPressed: onPickFolder,
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
  });

  final AppShellViewModel viewModel;
  final LibraryViewModel libraryViewModel;
  final _LibrarySection section;

  @override
  Widget build(BuildContext context) {
    if (section == _LibrarySection.artistAlbum &&
        libraryViewModel.status == LibraryStatus.ready) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: ArtistAlbumBrowser(tracks: libraryViewModel.tracks),
      );
    }
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
            LibraryStatus.ready => _TrackList(
              tracks: libraryViewModel.tracks,
              onRemove: libraryViewModel.removeTracks,
            ),
            LibraryStatus.error => _StatusMessage(
              icon: Icons.error_outline,
              title: '読み込みエラー',
              message: libraryViewModel.errorMessage ?? 'ライブラリを読み込めませんでした。',
            ),
          };

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(child: content),
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
  const _TrackList({required this.tracks, required this.onRemove});

  final List<Track> tracks;
  final Future<bool> Function(List<Track> tracks) onRemove;

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
              trailing: FilledButton.icon(
                onPressed: _confirmRemove,
                icon: const Icon(Icons.delete_outline),
                label: const Text('ライブラリから削除'),
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
        );
      },
    );
  }
}

class _PlayerArea extends StatelessWidget {
  const _PlayerArea();

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
      alignment: Alignment.centerLeft,
      child: const Text('再生する楽曲が選択されていません'),
    );
  }
}
