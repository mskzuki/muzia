// デザイン視覚確認用の一時エントリポイント。
// 実ユーザーのライブラリDBに触れず、インメモリのシードデータで起動する。
// 使い方: flutter run -d macos -t tool/design_preview_main.dart
import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/data/music_repository.dart';
import 'package:muzia/features/library/domain/track.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';

const _tracks = [
  Track(
    filePath: '/tmp/a.flac',
    fileExtension: '.flac',
    title: 'Neon Hours',
    artist: 'Midnight Arcade',
    album: 'Parallel Lines',
    releaseInfo: '2024',
  ),
  Track(
    filePath: '/tmp/b.flac',
    fileExtension: '.flac',
    title: 'Coastlines',
    artist: 'Hollow Coast',
    album: 'Tidewater',
    releaseInfo: '2023',
  ),
  Track(
    filePath: '/tmp/c.m4a',
    fileExtension: '.m4a',
    title: 'Paper Crowns',
    artist: 'The Velvet Hours',
    album: 'Slow Burn',
    releaseInfo: '2022',
  ),
  Track(
    filePath: '/tmp/d.m4a',
    fileExtension: '.m4a',
    title: 'Static Bloom',
    artist: 'Cascade Theory',
    album: 'Half-Light',
    releaseInfo: '2024',
  ),
  Track(
    filePath: '/tmp/e.mp3',
    fileExtension: '.mp3',
    title: 'Golden Static',
    artist: 'Midnight Arcade',
    album: 'Parallel Lines',
    releaseInfo: '2024',
  ),
  Track(
    filePath: '/tmp/f.mp3',
    fileExtension: '.mp3',
    title: 'Riverbed',
    artist: 'Anna Reyes',
    album: 'Northbound',
    releaseInfo: '2021',
  ),
];

Future<void> main() async {
  final repository = InMemoryMusicRepository();
  await repository.registerFolder('/tmp/music', _tracks);
  final library = LibraryViewModel(repository: repository);
  await library.initialize();
  runMuziaApp(libraryViewModel: library);
}
