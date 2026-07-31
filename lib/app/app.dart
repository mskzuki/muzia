import 'package:flutter/material.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_page.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';

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
    return MaterialApp(
      title: 'Muzia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: AppShellPage(
        viewModel: viewModel ?? AppShellViewModel(),
        libraryViewModel: libraryViewModel ?? LibraryViewModel(),
        playerViewModel:
            playerViewModel ??
            PlayerViewModel(service: FakeAudioPlayerService()),
      ),
    );
  }
}
