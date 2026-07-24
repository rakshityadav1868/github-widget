import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/github_stats.dart';
import '../../data/services/widget_updater.dart';
import '../../widgets/contribution_grid.dart';
import 'widget_card.dart';

/// Which palette the widget uses: a manually forced Light or Dark look, or
/// [matchWallpaper] to follow the system's dynamic color (Android 12+ /
/// Samsung theming).
enum _ThemeChoice { light, dark, matchWallpaper }

/// Shows the widget with a Light/Dark/Match-wallpaper toggle. The selected
/// mode drives both the preview and what gets pushed to the home-screen
/// widget - picking Light or Dark always forces that static palette, even on
/// devices that support wallpaper-matched dynamic color.
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
  _ThemeChoice? _choice;

  bool _hasDynamicColor(BuildContext context) =>
      ThemeProvider.maybeOf(context) != null;

  /// The selected choice, defaulting to wallpaper matching when it's
  /// available, otherwise the phone's current system brightness.
  _ThemeChoice _effectiveChoice(BuildContext context) {
    if (_choice != null) return _choice!;
    if (_hasDynamicColor(context)) return _ThemeChoice.matchWallpaper;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? _ThemeChoice.dark
        : _ThemeChoice.light;
  }

  Brightness _brightnessFor(BuildContext context, _ThemeChoice choice) {
    switch (choice) {
      case _ThemeChoice.dark:
        return Brightness.dark;
      case _ThemeChoice.light:
        return Brightness.light;
      case _ThemeChoice.matchWallpaper:
        return ThemeProvider.maybeOf(context)?.brightness ??
            MediaQuery.platformBrightnessOf(context);
    }
  }

  /// Only non-null when the user explicitly chose wallpaper matching - a
  /// manually picked Light/Dark always wins over the system dynamic scheme.
  ColorScheme? _dynamicSchemeFor(BuildContext context, _ThemeChoice choice) {
    if (choice != _ThemeChoice.matchWallpaper) return null;
    return ThemeProvider.maybeOf(context);
  }

  void _replay() => _gridKey.currentState?.replay();

  Future<void> _addToHome() async {
    final messenger = ScaffoldMessenger.of(context);
    final choice = _effectiveChoice(context);
    final brightness = _brightnessFor(context, choice);
    final dynamicScheme = _dynamicSchemeFor(context, choice);
    try {
      await WidgetUpdater.update(
        widget.stats,
        brightness: brightness,
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
    final choice = _effectiveChoice(context);
    final mode = _brightnessFor(context, choice);
    final dynamicScheme = _dynamicSchemeFor(context, choice);
    final hasDynamicColor = _hasDynamicColor(context);
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
            child: SegmentedButton<_ThemeChoice>(
              segments: [
                const ButtonSegment(
                  value: _ThemeChoice.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                const ButtonSegment(
                  value: _ThemeChoice.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                if (hasDynamicColor)
                  const ButtonSegment(
                    value: _ThemeChoice.matchWallpaper,
                    label: Text('Theme match'),
                    icon: Icon(Icons.wallpaper_outlined),
                  ),
              ],
              selected: {choice},
              onSelectionChanged: (selection) =>
                  setState(() => _choice = selection.first),
            ),
          ),
          const SizedBox(height: 24),
          WidgetCard(
            stats: widget.stats,
            brightness: mode,
            dynamicScheme: dynamicScheme,
            gridKey: _gridKey,
          ),
          const SizedBox(height: 28),
          Center(
            child: FilledButton.icon(
              onPressed: _addToHome,
              icon: const Icon(Icons.add_to_home_screen, size: 18),
              label: Text('Add ${_labelFor(choice)} widget to home'),
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

  String _labelFor(_ThemeChoice choice) {
    switch (choice) {
      case _ThemeChoice.dark:
        return 'dark';
      case _ThemeChoice.light:
        return 'light';
      case _ThemeChoice.matchWallpaper:
        return 'theme-matched';
    }
  }
}
