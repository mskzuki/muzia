import 'package:muzia/features/library/domain/track.dart';

class LibrarySearch {
  const LibrarySearch._();

  static List<Track> filter(Iterable<Track> tracks, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return tracks.where((track) => !track.isRemoved).toList(growable: false);
    }
    return tracks
        .where(
          (track) =>
              !track.isRemoved && _contains(track.title, normalizedQuery) ||
              (!track.isRemoved && _contains(track.artist, normalizedQuery)) ||
              (!track.isRemoved && _contains(track.album, normalizedQuery)),
        )
        .toList(growable: false);
  }

  static bool _contains(String? value, String query) =>
      value?.toLowerCase().contains(query) == true;
}
