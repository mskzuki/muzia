import 'package:muzia/features/library/domain/track.dart';

/// 楽曲一覧のソート対象列。
enum TrackSortField { title, artist, album, duration }

/// 楽曲一覧のソート状態。永続化しない（起動時は登録順）。
class TrackSort {
  const TrackSort(this.field, {this.ascending = true});

  final TrackSortField field;
  final bool ascending;

  /// ヘッダをクリックしたときの次の状態。同じ列なら昇順⇄降順、別の列なら昇順。
  TrackSort? toggled(TrackSortField next) =>
      next == field ? TrackSort(field, ascending: !ascending) : TrackSort(next);

  @override
  bool operator ==(Object other) =>
      other is TrackSort &&
      other.field == field &&
      other.ascending == ascending;

  @override
  int get hashCode => Object.hash(field, ascending);
}

/// [sort] に従って安定ソートした新しいリストを返す。null（未設定）は昇降順に
/// 関わらず常に末尾。文字列は大文字小文字を無視して比較する。
/// [sort] が null なら元の順序。
List<Track> sortTracks(List<Track> tracks, TrackSort? sort) {
  if (sort == null) return tracks;
  final indexed = tracks.asMap().entries.toList(growable: false);
  indexed.sort((a, b) {
    final left = _sortKey(a.value, sort.field);
    final right = _sortKey(b.value, sort.field);
    if (left == null || right == null) {
      if (left == null && right == null) return a.key.compareTo(b.key);
      return left == null ? 1 : -1;
    }
    final result = left.compareTo(right);
    if (result != 0) return sort.ascending ? result : -result;
    return a.key.compareTo(b.key);
  });
  return indexed.map((entry) => entry.value).toList(growable: false);
}

Comparable<Object>? _sortKey(Track track, TrackSortField field) {
  switch (field) {
    case TrackSortField.title:
      return _textKey(track.title);
    case TrackSortField.artist:
      return _textKey(track.artist);
    case TrackSortField.album:
      return _textKey(track.album);
    case TrackSortField.duration:
      return track.durationMs;
  }
}

String? _textKey(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed.toLowerCase();
}

/// 再生時間の表示（`m:ss`、1時間以上は `h:mm:ss`）。未取得は「—」。
String formatTrackDuration(int? durationMs) {
  if (durationMs == null || durationMs < 0) return '—';
  final totalSeconds = durationMs ~/ 1000;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final mmss =
      '${hours > 0 ? minutes.toString().padLeft(2, '0') : minutes}'
      ':${seconds.toString().padLeft(2, '0')}';
  return hours > 0 ? '$hours:$mmss' : mmss;
}
