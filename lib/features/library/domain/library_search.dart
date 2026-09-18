import 'package:muzia/features/library/domain/track.dart';

/// 検索結果。ハンドオフ「Search」に合わせてアルバム / アーティスト / 楽曲に分ける。
class SearchResults {
  const SearchResults({
    required this.query,
    required this.albums,
    required this.artists,
    required this.tracks,
  });

  final String query;
  final List<AlbumHit> albums;
  final List<ArtistHit> artists;
  final List<Track> tracks;

  bool get isEmpty => albums.isEmpty && artists.isEmpty && tracks.isEmpty;
  int get total => albums.length + artists.length + tracks.length;
}

class AlbumHit {
  const AlbumHit({
    required this.name,
    required this.artist,
    required this.trackCount,
  });

  final String name;

  /// 収録曲のアーティスト。複数なら先頭（名前順）。
  final String? artist;
  final int trackCount;
}

class ArtistHit {
  const ArtistHit({
    required this.name,
    required this.albumCount,
    required this.trackCount,
  });

  final String name;
  final int albumCount;
  final int trackCount;
}

/// 検索語との一致範囲（元の文字列上のインデックス）。
class MatchRange {
  const MatchRange(this.start, this.end);
  final int start;
  final int end;
}

class LibrarySearch {
  const LibrarySearch._();

  /// 大文字小文字とダイアクリティカルマーク（é → e 等）の差を無視するための正規化。
  /// 1文字を1文字に写すので、正規化後のインデックスは元の文字列と一致する。
  static String normalize(String value) {
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      buffer.write(_foldRune(rune));
    }
    return buffer.toString().toLowerCase();
  }

  /// 検索語に一致する楽曲（一致度順）。空の検索語なら削除済みを除く全曲。
  static List<Track> filter(Iterable<Track> tracks, String query) {
    final normalizedQuery = normalize(query.trim());
    final active = tracks.where((track) => !track.isRemoved);
    if (normalizedQuery.isEmpty) return active.toList(growable: false);
    final ranked = <(int, int, Track)>[];
    var index = 0;
    for (final track in active) {
      final rank = _bestRank([
        track.title,
        track.artist,
        track.album,
      ], normalizedQuery);
      if (rank != null) ranked.add((rank, index, track));
      index++;
    }
    ranked.sort((a, b) {
      final byRank = a.$1.compareTo(b.$1);
      return byRank != 0 ? byRank : a.$2.compareTo(b.$2);
    });
    return ranked.map((entry) => entry.$3).toList(growable: false);
  }

  /// グループ化した検索結果。名前が一致したアルバム / アーティストと、
  /// いずれかの項目が一致した楽曲を返す。
  static SearchResults search(Iterable<Track> tracks, String query) {
    final trimmed = query.trim();
    final normalizedQuery = normalize(trimmed);
    final active = tracks.where((track) => !track.isRemoved).toList();
    if (normalizedQuery.isEmpty) {
      return SearchResults(
        query: trimmed,
        albums: const [],
        artists: const [],
        tracks: active,
      );
    }

    final albumTracks = <String, List<Track>>{};
    final artistTracks = <String, List<Track>>{};
    for (final track in active) {
      final album = track.album?.trim();
      if (album != null && album.isNotEmpty) {
        albumTracks.putIfAbsent(album, () => []).add(track);
      }
      final artist = track.artist?.trim();
      if (artist != null && artist.isNotEmpty) {
        artistTracks.putIfAbsent(artist, () => []).add(track);
      }
    }

    List<T> rankedNames<T>(
      Map<String, List<Track>> groups,
      T Function(String name, List<Track> members) build,
    ) {
      final hits = <(int, String)>[];
      for (final name in groups.keys) {
        final rank = matchRank(name, normalizedQuery);
        if (rank != null) hits.add((rank, name));
      }
      hits.sort((a, b) {
        final byRank = a.$1.compareTo(b.$1);
        return byRank != 0
            ? byRank
            : a.$2.toLowerCase().compareTo(b.$2.toLowerCase());
      });
      return hits
          .map((hit) => build(hit.$2, groups[hit.$2]!))
          .toList(growable: false);
    }

    return SearchResults(
      query: trimmed,
      albums: rankedNames(albumTracks, (name, members) {
        final artists =
            members
                .map((track) => track.artist?.trim())
                .whereType<String>()
                .where((artist) => artist.isNotEmpty)
                .toSet()
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        return AlbumHit(
          name: name,
          artist: artists.isEmpty ? null : artists.first,
          trackCount: members.length,
        );
      }),
      artists: rankedNames(artistTracks, (name, members) {
        final albums = members
            .map((track) => track.album?.trim())
            .whereType<String>()
            .where((album) => album.isNotEmpty)
            .toSet();
        return ArtistHit(
          name: name,
          albumCount: albums.length,
          trackCount: members.length,
        );
      }),
      tracks: filter(active, trimmed),
    );
  }

  /// [text] 内で [query] が最初に一致する範囲。ハイライト描画に使う。
  /// 一致しない、または検索語が空なら null。
  static MatchRange? matchRange(String? text, String query) {
    if (text == null) return null;
    final normalizedQuery = normalize(query.trim());
    if (normalizedQuery.isEmpty) return null;
    final start = normalize(text).indexOf(normalizedQuery);
    if (start < 0) return null;
    return MatchRange(start, start + normalizedQuery.length);
  }

  /// 一致度。0 = 単語の前方一致、1 = 部分一致、null = 不一致。
  /// [normalizedQuery] は [normalize] 済みであること。
  static int? matchRank(String? text, String normalizedQuery) {
    if (text == null || normalizedQuery.isEmpty) return null;
    final normalized = normalize(text);
    var start = normalized.indexOf(normalizedQuery);
    while (start >= 0) {
      if (start == 0 || _isWordBoundary(normalized.codeUnitAt(start - 1))) {
        return 0;
      }
      start = normalized.indexOf(normalizedQuery, start + 1);
    }
    return normalized.contains(normalizedQuery) ? 1 : null;
  }

  static int? _bestRank(List<String?> fields, String normalizedQuery) {
    int? best;
    for (final field in fields) {
      final rank = matchRank(field, normalizedQuery);
      if (rank != null && (best == null || rank < best)) best = rank;
    }
    return best;
  }

  static bool _isWordBoundary(int codeUnit) {
    final char = String.fromCharCode(codeUnit);
    return char.trim().isEmpty || _wordSeparators.contains(char);
  }

  static const _wordSeparators = "-–—_.,:;!?'\"()[]{}/&・「」『』（）";

  /// ラテン文字のダイアクリティカルマークを外す（1文字→1文字）。
  static String _foldRune(int rune) {
    final char = String.fromCharCode(rune);
    final index = _accented.indexOf(char);
    return index < 0 ? char : _bases[index];
  }

  static const _accented =
      'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÝýÿÑñÇçŠšŽžŁłŃńŚśŹźŻżĆćĞğİıŞşŐőŰűĀāĒēĪīŌōŪū';
  static const _bases =
      'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuYyyNnCcSsZzLlNnSsZzZzCcGgIiSsOoUuAaEeIiOoUu';
}
