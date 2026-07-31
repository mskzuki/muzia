import 'package:file_selector/file_selector.dart';

abstract interface class FilePickerService {
  Future<String?> pickDirectory();
}

class NativeFilePickerService implements FilePickerService {
  @override
  Future<String?> pickDirectory() async {
    return getDirectoryPath();
  }
}
