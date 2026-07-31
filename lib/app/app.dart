import 'package:flutter/material.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_page.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';

void runMuziaApp({
  AppShellViewModel? viewModel,
  LibraryViewModel? libraryViewModel,
}) {
  runApp(MuziaApp(viewModel: viewModel, libraryViewModel: libraryViewModel));
}

class MuziaApp extends StatelessWidget {
  const MuziaApp({super.key, this.viewModel, this.libraryViewModel});

  final AppShellViewModel? viewModel;
  final LibraryViewModel? libraryViewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muzia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: AppShellPage(
        viewModel: viewModel ?? AppShellViewModel(),
        libraryViewModel: libraryViewModel ?? LibraryViewModel(),
      ),
    );
  }
}
