import 'package:expressive_ui_kit/expressive_ui_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'src/core/core.dart';

class PlaygroundApp extends StatefulWidget {
  const PlaygroundApp({super.key});

  @override
  State<PlaygroundApp> createState() => _PlaygroundAppState();
}

class _PlaygroundAppState extends State<PlaygroundApp> {
  ThemeMode _mode = ThemeMode.system;

  late final GoRouter _router = AppRouter.build(
    onThemeModeChanged: (mode) => setState(() => _mode = mode),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Replit UI Playground · Flutter UI library for AI Chat Interfaces',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: AppTheme.playgroundLight,
      darkTheme: AppTheme.playgroundDark,
      routerConfig: _router,
      builder: (context, child) => METheme(
        data: METhemeData.expressive,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
