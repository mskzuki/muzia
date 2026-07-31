import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';
import 'package:media_kit/media_kit.dart';
import 'package:muzia/features/playback/presentation/player_view_model.dart';
import 'package:muzia/features/playback/data/media_kit_audio_player_service.dart';

void main() {
  MediaKit.ensureInitialized();
  runMuziaApp(
    libraryViewModel: LibraryViewModel.persistent(),
    playerViewModel: PlayerViewModel(service: MediaKitAudioPlayerService()),
  );
}
