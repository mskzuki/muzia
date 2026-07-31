import 'package:flutter/foundation.dart';

enum AppShellStatus { loading, empty, error }

typedef LibraryInitializer = Future<void> Function();

class AppShellViewModel extends ChangeNotifier {
  AppShellViewModel({LibraryInitializer? initializeLibrary})
    : _initializeLibrary = initializeLibrary ?? _emptyLibraryInitializer;

  final LibraryInitializer _initializeLibrary;
  AppShellStatus _status = AppShellStatus.loading;
  String? _errorMessage;

  AppShellStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _setState(AppShellStatus.loading);
    try {
      await _initializeLibrary();
      _errorMessage = null;
      _setState(AppShellStatus.empty);
    } catch (_) {
      _errorMessage = 'ライブラリの読み込みに失敗しました。';
      _setState(AppShellStatus.error);
    }
  }

  void _setState(AppShellStatus status) {
    _status = status;
    notifyListeners();
  }

  static Future<void> _emptyLibraryInitializer() async {}
}
