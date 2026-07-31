import 'package:muzia/features/library/domain/track.dart';

class LibraryCatalog {
  const LibraryCatalog(Iterable<Track> tracks) : _tracks = tracks;

  final Iterable<Track> _tracks;

  List<String> get artists => _values((track) => track.artist);

  List<String> albumsFor(String artist) =>
      _values((track) => track.artist == artist ? track.album : null);

  List<Track> tracksFor({String? artist, String? album}) {
    return _activeTracks
        .where(
          (track) =>
              (artist == null || track.artist == artist) &&
              (album == null || track.album == album),
        )
        .toList(growable: false);
  }

  Iterable<Track> get _activeTracks =>
      _tracks.where((track) => !track.isRemoved);

  Iterable<Track> get _artistTracks =>
      _activeTracks.where((track) => track.artist?.trim().isNotEmpty == true);

  List<String> _values(String? Function(Track track) selector) {
    final values = <String>{};
    for (final track in _artistTracks) {
      final value = selector(track);
      if (value != null && value.trim().isNotEmpty) values.add(value);
    }
    return values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }
}
