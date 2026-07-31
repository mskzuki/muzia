import 'package:flutter/material.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/library/domain/track.dart';

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
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    widget.libraryViewModel.addListener(_onViewModelChanged);
    widget.viewModel.initialize();
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
                ),
                Expanded(
                  child: _MainContent(
                    viewModel: widget.viewModel,
                    libraryViewModel: widget.libraryViewModel,
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
  const _Sidebar({required this.onPickFolder});

  final VoidCallback onPickFolder;

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
  const _MainContent({required this.viewModel, required this.libraryViewModel});

  final AppShellViewModel viewModel;
  final LibraryViewModel libraryViewModel;

  @override
  Widget build(BuildContext context) {
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
            LibraryStatus.ready => _TrackList(tracks: libraryViewModel.tracks),
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

class _TrackList extends StatelessWidget {
  const _TrackList({required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: tracks.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ListTile(
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
