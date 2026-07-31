import 'package:flutter/material.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_page.dart';
import 'package:muzia/features/app_shell/presentation/app_shell_view_model.dart';

void runMuziaApp({AppShellViewModel? viewModel}) {
  runApp(MuziaApp(viewModel: viewModel));
}

class MuziaApp extends StatelessWidget {
  const MuziaApp({super.key, this.viewModel});

  final AppShellViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muzia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: AppShellPage(viewModel: viewModel ?? AppShellViewModel()),
    );
  }
}
