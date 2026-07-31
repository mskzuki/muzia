import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/features/playback/domain/audio_player_service.dart';

final appShellViewModelProvider = ChangeNotifierProvider<AppShellViewModel>(
  (ref) => AppShellViewModel(
    initializeLibrary: ref.read(libraryViewModelProvider).initialize,
  ),
);

final libraryViewModelProvider = ChangeNotifierProvider<LibraryViewModel>((
  ref,
) {
  return LibraryViewModel();
});

final playerViewModelProvider = ChangeNotifierProvider<PlayerViewModel>((ref) {
  final viewModel = PlayerViewModel(service: FakeAudioPlayerService());
  return viewModel;
});
