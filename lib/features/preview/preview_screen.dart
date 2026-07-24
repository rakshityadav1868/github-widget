import 'package:flutter/material.dart';

import '../../data/models/github_stats.dart';
import '../../data/services/widget_updater.dart';
import '../../widgets/contribution_grid.dart';
import 'widget_card.dart';

/// Shows the widget in both dark and light, with a replay control — the in-app
/// preview where the grid animation plays in full.
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
  final _darkKey = GlobalKey<ContributionGridState>();
  final _lightKey = GlobalKey<ContributionGridState>();

  void _replay() {
    _darkKey.currentState?.replay();
    _lightKey.currentState?.replay();
  }

  Future<void> _addToHome() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await WidgetUpdater.update(widget.stats);
      await WidgetUpdater.requestPin();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Add the widget from your home screen: long-press → Widgets → GitHub Widget.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _label(context, 'DARK'),
          WidgetCard(
            stats: widget.stats,
            brightness: Brightness.dark,
            gridKey: _darkKey,
          ),
          const SizedBox(height: 28),
          _label(context, 'LIGHT'),
          WidgetCard(
            stats: widget.stats,
            brightness: Brightness.light,
            gridKey: _lightKey,
          ),
          const SizedBox(height: 28),
          Center(
            child: FilledButton.icon(
              onPressed: _addToHome,
              icon: const Icon(Icons.add_to_home_screen, size: 18),
              label: const Text('Add to home screen'),
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

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 2,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}
