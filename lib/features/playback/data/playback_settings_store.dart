import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 再生関連の設定（音量）の保存先。
abstract interface class PlaybackSettingsStore {
  Future<double?> loadVolume();
  Future<void> saveVolume(double volume);
}

class InMemoryPlaybackSettingsStore implements PlaybackSettingsStore {
  InMemoryPlaybackSettingsStore({this.volume});
  double? volume;

  @override
  Future<double?> loadVolume() async => volume;

  @override
  Future<void> saveVolume(double volume) async => this.volume = volume;
}

/// アプリケーションサポートディレクトリの JSON ファイルへ保存する。
/// ライブラリDBとは独立しており、壊れていても既定値で起動できる。
class FilePlaybackSettingsStore implements PlaybackSettingsStore {
  FilePlaybackSettingsStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;

  Future<File> _file() async =>
      File(p.join((await _directory()).path, 'playback_settings.json'));

  @override
  Future<double?> loadVolume() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString());
      final volume = json is Map ? json['volume'] : null;
      return volume is num ? volume.toDouble() : null;
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<void> saveVolume(double volume) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode({'volume': volume}));
  }
}
