import 'package:flutter/widgets.dart';
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:media_kit/media_kit.dart';
import 'package:muzia/features/playback/data/playback_settings_store.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/features/playback/data/media_kit_audio_player_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final player = PlayerViewModel(
    service: MediaKitAudioPlayerService(),
    settingsStore: FilePlaybackSettingsStore(),
  );
  // 保存済みの音量を起動時に復元する（読めなければ既定値のまま）。
  await player.initialize();
  runMuziaApp(
    libraryViewModel: LibraryViewModel.persistent(),
    playerViewModel: player,
  );
}
