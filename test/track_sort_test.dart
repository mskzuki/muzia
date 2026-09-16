import 'package:flutter_test/flutter_test.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/domain/track_sort.dart';

Track _track(String path, {String? title, String? artist, int? durationMs}) =>
    Track(
      filePath: path,
      fileExtension: '.mp3',
      title: title,
      artist: artist,
      durationMs: durationMs,
    );

void main() {
  final tracks = [
    _track('1', title: 'beta', artist: 'Zed', durationMs: 200000),
    _track('2', title: 'Alpha', artist: 'amy', durationMs: null),
    _track('3', title: null, artist: 'Amy', durationMs: 100000),
    _track('4', title: 'gamma', artist: null, durationMs: 100000),
  ];

  test('sort が null なら元の順序を返す', () {
    expect(sortTracks(tracks, null), same(tracks));
  });

  test('タイトルは大文字小文字を無視して昇順、未設定は末尾', () {
    final sorted = sortTracks(tracks, const TrackSort(TrackSortField.title));
    expect(sorted.map((t) => t.filePath), ['2', '1', '4', '3']);
  });

  test('降順でも未設定は末尾のまま', () {
    final sorted = sortTracks(
      tracks,
      const TrackSort(TrackSortField.title, ascending: false),
    );
    expect(sorted.map((t) => t.filePath), ['4', '1', '2', '3']);
  });

  test('同じ値は元の順序を保つ（安定ソート）', () {
    final sorted = sortTracks(tracks, const TrackSort(TrackSortField.duration));
    expect(sorted.map((t) => t.filePath), ['3', '4', '1', '2']);
    final byArtist = sortTracks(tracks, const TrackSort(TrackSortField.artist));
    // 'amy' と 'Amy' は同値として登録順（2, 3）を保つ。
    expect(byArtist.map((t) => t.filePath), ['2', '3', '1', '4']);
  });

  test('toggled は同じ列で昇降を切り替え、別の列は昇順から始める', () {
    const sort = TrackSort(TrackSortField.title);
    expect(
      sort.toggled(TrackSortField.title),
      const TrackSort(TrackSortField.title, ascending: false),
    );
    expect(
      sort.toggled(TrackSortField.album),
      const TrackSort(TrackSortField.album),
    );
  });

  test('再生時間を m:ss で表示し、未取得は「—」', () {
    expect(formatTrackDuration(null), '—');
    expect(formatTrackDuration(0), '0:00');
    expect(formatTrackDuration(59999), '0:59');
    expect(formatTrackDuration(238000), '3:58');
    expect(formatTrackDuration(3725000), '1:02:05');
  });
}
