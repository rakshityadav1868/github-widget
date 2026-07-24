import 'package:flutter/material.dart';

import 'core/theme.dart';

void main() => runApp(const GitHubWidgetApp());

class GitHubWidgetApp extends StatelessWidget {
  const GitHubWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Widget',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const _HomePlaceholder(),
    );
  }
}

/// Temporary landing screen. Replaced by the onboarding + preview flow in
/// later PRs (see ROADMAP.md).
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.grid_view_rounded, size: 48),
            SizedBox(height: 16),
            Text('GitHub Widget',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Setup coming next', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
