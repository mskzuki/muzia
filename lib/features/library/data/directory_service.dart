import 'dart:io';

abstract interface class DirectoryService {
  Future<bool> isDirectory(String path);
}

class NativeDirectoryService implements DirectoryService {
  @override
  Future<bool> isDirectory(String path) async {
    try {
      final entity = await FileSystemEntity.type(path, followLinks: false);
      return entity == FileSystemEntityType.directory;
    } on FileSystemException {
      return false;
    }
  }
}
