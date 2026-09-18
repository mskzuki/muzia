import 'package:muzia/features/library/domain/track.dart';

class LibraryCatalog {
  const LibraryCatalog(Iterable<Track> tracks) : _tracks = tracks;

  final Iterable<Track> _tracks;

  List<String> get artists => _values((track) => track.artist);

  /// ライブラリ全体の既存ジャンル一覧（重複なし・大文字小文字を無視してソート）。
  /// アーティスト未設定の楽曲も対象に含める。
  List<String> get genres {
    final values = <String>{};
    for (final track in _activeTracks) {
      final genre = track.genre?.trim();
      if (genre != null && genre.isNotEmpty) values.add(genre);
    }
    return values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  /// ライブラリ全体の既存アルバム名（重複なし・大文字小文字を無視してソート）。
  /// アーティスト未設定の楽曲も対象に含める。
  List<String> get albums {
    final values = <String>{};
    for (final track in _activeTracks) {
      final album = track.album?.trim();
      if (album != null && album.isNotEmpty) values.add(album);
    }
    return values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  List<String> albumsFor(String artist) =>
      _values((track) => track.artist == artist ? track.album : null);

  /// アーティスト / アルバムで絞り込んだ楽曲。アルバム名 → トラック番号（未設定は
  /// 末尾）→ タイトルの順に並べる（`06-album-detail` のトラック順表示に合わせる）。
  List<Track> tracksFor({String? artist, String? album}) {
    final matched = _activeTracks
        .where(
          (track) =>
              (artist == null || track.artist == artist) &&
              (album == null || track.album == album),
        )
        .toList();
    matched.sort((a, b) {
      final byAlbum = _compareText(a.album, b.album);
      if (byAlbum != 0) return byAlbum;
      final byNumber = _compareNullable(a.trackNumber, b.trackNumber);
      if (byNumber != 0) return byNumber;
      return _compareText(a.title, b.title);
    });
    return matched;
  }

  /// アーティスト詳細ヒーローのメタ情報（アルバム選択に左右されない全体の値）。
  ArtistSummary artistSummary(String artist) {
    final tracks = _activeTracks.where((track) => track.artist == artist);
    return ArtistSummary(
      albumCount: albumsFor(artist).length,
      trackCount: tracks.length,
      genre: _mostCommon(tracks.map((track) => track.genre)),
      totalDurationMs: _totalDuration(tracks),
    );
  }

  /// アルバム詳細ヒーローのメタ情報。
  AlbumSummary albumSummary(String album, {String? artist}) {
    final tracks = tracksFor(artist: artist, album: album);
    return AlbumSummary(
      artist: artist ?? _mostCommon(tracks.map((track) => track.artist)),
      releaseYear: _mostCommon(tracks.map((track) => track.releaseYear)),
      trackCount: tracks.length,
      totalDurationMs: _totalDuration(tracks),
    );
  }

  static int _totalDuration(Iterable<Track> tracks) =>
      tracks.fold(0, (sum, track) => sum + (track.durationMs ?? 0));

  /// 最も多く現れる値（未設定・空文字は無視。同数なら先に現れたもの）。
  static T? _mostCommon<T>(Iterable<T?> values) {
    final counts = <T, int>{};
    for (final value in values) {
      if (value == null || (value is String && value.trim().isEmpty)) continue;
      counts[value] = (counts[value] ?? 0) + 1;
    }
    T? best;
    var bestCount = 0;
    for (final entry in counts.entries) {
      if (entry.value > bestCount) {
        best = entry.key;
        bestCount = entry.value;
      }
    }
    return best;
  }

  static int _compareText(String? a, String? b) => _compareNullable(
    a == null || a.trim().isEmpty ? null : a.toLowerCase(),
    b == null || b.trim().isEmpty ? null : b.toLowerCase(),
  );

  static int _compareNullable<T extends Comparable<T>>(T? a, T? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
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

/// アーティスト全体の集計。
class ArtistSummary {
  const ArtistSummary({
    required this.albumCount,
    required this.trackCount,
    required this.genre,
    required this.totalDurationMs,
  });

  final int albumCount;
  final int trackCount;

  /// 代表ジャンル（最多）。ジャンル未設定なら null。
  final String? genre;
  final int totalDurationMs;
}

/// アルバムの集計。
class AlbumSummary {
  const AlbumSummary({
    required this.artist,
    required this.releaseYear,
    required this.trackCount,
    required this.totalDurationMs,
  });

  final String? artist;
  final int? releaseYear;
  final int trackCount;
  final int totalDurationMs;
}
