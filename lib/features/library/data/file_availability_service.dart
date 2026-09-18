import 'dart:io';

/// ライブラリ内の音楽ファイルが現在も存在するかを確認する。
abstract interface class FileAvailabilityService {
  Future<bool> exists(String filePath);
}

class NativeFileAvailabilityService implements FileAvailabilityService {
  const NativeFileAvailabilityService();

  @override
  Future<bool> exists(String filePath) async {
    try {
      return await File(filePath).exists();
    } on FileSystemException {
      return false;
    }
  }
}

/// 常に存在するとみなす。実ファイルを持たないテストやインメモリ運用向け。
class AlwaysAvailableFileService implements FileAvailabilityService {
  const AlwaysAvailableFileService();

  @override
  Future<bool> exists(String filePath) async => true;
}
