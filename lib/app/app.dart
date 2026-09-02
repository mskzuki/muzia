import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_page.dart';
import 'package:muzia/app/providers.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/shared/theme/muzia_theme.dart';

void runMuziaApp({
  AppShellViewModel? viewModel,
  LibraryViewModel? libraryViewModel,
  PlayerViewModel? playerViewModel,
}) {
  runApp(
    MuziaApp(
      viewModel: viewModel,
      libraryViewModel: libraryViewModel,
      playerViewModel: playerViewModel,
    ),
  );
}

class MuziaApp extends StatelessWidget {
  const MuziaApp({
    super.key,
    this.viewModel,
    this.libraryViewModel,
    this.playerViewModel,
  });

  final AppShellViewModel? viewModel;
  final LibraryViewModel? libraryViewModel;
  final PlayerViewModel? playerViewModel;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        if (viewModel != null)
          appShellViewModelProvider.overrideWith((ref) => viewModel!),
        if (libraryViewModel != null)
          libraryViewModelProvider.overrideWith((ref) => libraryViewModel!),
        if (playerViewModel != null)
          playerViewModelProvider.overrideWith((ref) => playerViewModel!),
      ],
      child: MaterialApp(
        title: 'Muzia',
        theme: MuziaTheme.light(),
        darkTheme: MuziaTheme.dark(),
        home: const AppShellPage(),
      ),
    );
  }
}
