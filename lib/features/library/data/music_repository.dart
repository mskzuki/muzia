import 'package:muzia/features/library/domain/track.dart';

abstract interface class MusicRepository {
  String? get registeredFolder;
  List<Track> get tracks;
  Future<void> registerFolder(String path, List<Track> tracks);
}

class InMemoryMusicRepository implements MusicRepository {
  String? _registeredFolder;
  List<Track> _tracks = const [];

  @override
  String? get registeredFolder => _registeredFolder;

  @override
  List<Track> get tracks => List.unmodifiable(_tracks);

  @override
  Future<void> registerFolder(String path, List<Track> tracks) async {
    _registeredFolder = path;
    _tracks = List.unmodifiable(tracks);
  }
}
