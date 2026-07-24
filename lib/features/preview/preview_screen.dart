import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/github_stats.dart';
import '../../data/services/widget_updater.dart';
import '../../widgets/contribution_grid.dart';
import 'widget_card.dart';

/// Shows the widget with a Light/Dark toggle. The selected mode drives both the
/// preview and what gets pushed to the home-screen widget.
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({
    super.key,
    required this.stats,
    this.subtitle,
    this.onSignOut,
  });

  final GitHubStats stats;
  final String? subtitle;
  final VoidCallback? onSignOut;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final _gridKey = GlobalKey<ContributionGridState>();
  Brightness? _mode;

  /// The selected mode, defaulting to the phone's current theme.
  Brightness get _effectiveMode =>
      _mode ?? MediaQuery.platformBrightnessOf(context);

  void _replay() => _gridKey.currentState?.replay();

  Future<void> _addToHome() async {
    final messenger = ScaffoldMessenger.of(context);
    final dynamicScheme = ThemeProvider.maybeOf(context);
    try {
      await WidgetUpdater.update(
        widget.stats,
        brightness: _effectiveMode,
        dynamicScheme: dynamicScheme,
      );
      await WidgetUpdater.requestPin();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Add the widget from your home screen: long-press → Widgets → Forge.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = _effectiveMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget preview'),
        actions: [
          if (widget.onSignOut != null)
            IconButton(
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          if (widget.subtitle != null) ...[
            Text(widget.subtitle!,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
          ],
          Center(
            child: SegmentedButton<Brightness>(
              segments: const [
                ButtonSegment(
                  value: Brightness.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: Brightness.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (selection) =>
                  setState(() => _mode = selection.first),
            ),
          ),
          const SizedBox(height: 24),
          WidgetCard(
            stats: widget.stats,
            brightness: mode,
            gridKey: _gridKey,
          ),
          const SizedBox(height: 28),
          Center(
            child: FilledButton.icon(
              onPressed: _addToHome,
              icon: const Icon(Icons.add_to_home_screen, size: 18),
              label: Text('Add ${mode == Brightness.dark ? 'dark' : 'light'} widget to home'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton.icon(
              onPressed: _replay,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Replay animation'),
            ),
          ),
        ],
      ),
    );
  }
}
