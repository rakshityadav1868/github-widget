import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/github_stats.dart';
import '../../data/services/widget_render_prefs.dart';
import '../../data/services/widget_updater.dart';
import '../../widgets/contribution_grid.dart';
import 'widget_card.dart';

/// Shows the widget with a Light/Dark/Match-wallpaper toggle. The selected
/// mode drives both the preview and what gets pushed to the home-screen
/// widget - picking Light or Dark always forces that static palette, even on
/// devices that support wallpaper-matched dynamic color.
///
/// The choice is persisted via [WidgetRenderPrefs] so the background refresh
/// keeps honoring it; without that it would re-render on its own default
/// every 15 minutes and quietly undo the user's pick.
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
  WidgetThemeMode? _choice;

  bool _hasDynamicColor(BuildContext context) =>
      ThemeProvider.maybeOf(context) != null;

  /// The selected choice, defaulting to wallpaper matching when it's
  /// available, otherwise the phone's current system brightness.
  WidgetThemeMode _effectiveChoice(BuildContext context) {
    if (_choice != null) return _choice!;
    if (_hasDynamicColor(context)) return WidgetThemeMode.matchWallpaper;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? WidgetThemeMode.dark
        : WidgetThemeMode.light;
  }

  Brightness _brightnessFor(BuildContext context, WidgetThemeMode choice) {
    switch (choice) {
      case WidgetThemeMode.dark:
        return Brightness.dark;
      case WidgetThemeMode.light:
        return Brightness.light;
      case WidgetThemeMode.matchWallpaper:
        return ThemeProvider.maybeOf(context)?.brightness ??
            MediaQuery.platformBrightnessOf(context);
    }
  }

  /// Only non-null when the user explicitly chose wallpaper matching - a
  /// manually picked Light/Dark always wins over the system dynamic scheme.
  ColorScheme? _dynamicSchemeFor(BuildContext context, WidgetThemeMode choice) {
    if (choice != WidgetThemeMode.matchWallpaper) return null;
    return ThemeProvider.maybeOf(context);
  }

  void _replay() => _gridKey.currentState?.replay();

  Future<void> _addToHome() async {
    final messenger = ScaffoldMessenger.of(context);
    final choice = _effectiveChoice(context);
    // Read off the context before any await, for use if nothing was captured.
    final fallbackBrightness = _brightnessFor(context, choice);
    final fallbackScheme = _dynamicSchemeFor(context, choice);
    try {
      // Persist the choice, then render from exactly what was persisted -
      // the same path the background refresh takes. Rendering from local
      // state instead would let the widget the user pins and the widget
      // they get 15 minutes later drift apart, which is the whole class of
      // bug this is guarding against.
      await WidgetRenderPrefs.saveMode(choice);
      final prefs = await WidgetRenderPrefs.load();
      await WidgetUpdater.update(
        widget.stats,
        brightness: prefs?.brightness ?? fallbackBrightness,
        dynamicScheme: prefs?.scheme ?? fallbackScheme,
        pixelRatio: prefs?.pixelRatio,
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
            child: SegmentedButton<WidgetThemeMode>(
              segments: [
                const ButtonSegment(
                  value: WidgetThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                const ButtonSegment(
                  value: WidgetThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                if (hasDynamicColor)
                  const ButtonSegment(
                    value: WidgetThemeMode.matchWallpaper,
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

  String _labelFor(WidgetThemeMode choice) {
    switch (choice) {
      case WidgetThemeMode.dark:
        return 'dark';
      case WidgetThemeMode.light:
        return 'light';
      case WidgetThemeMode.matchWallpaper:
        return 'theme-matched';
    }
  }
}
