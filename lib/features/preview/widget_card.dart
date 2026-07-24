import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../data/models/github_stats.dart';
import '../../widgets/contribution_grid.dart';
import '../../widgets/stat_tile.dart';

/// The widget itself: a rounded card with a stat column on the left (day streak
/// and PRs merged) and the real contribution grid on the right, colored per
/// [brightness] via [WidgetPalette], matching the reference design.
///
/// Pass [dynamicScheme] to color the card from the wallpaper-derived system
/// theme (Android 12+ / Samsung theming) instead of the static green
/// palette. It's an explicit, caller-controlled override rather than
/// something this widget infers on its own - the caller decides whether the
/// user wants wallpaper matching or a manually forced light/dark look.
class WidgetCard extends StatelessWidget {
  const WidgetCard({
    super.key,
    required this.stats,
    required this.brightness,
    this.dynamicScheme,
    this.animate = true,
    this.gridKey,
  });

  final GitHubStats stats;
  final Brightness brightness;
  final ColorScheme? dynamicScheme;
  final bool animate;
  final Key? gridKey;

  @override
  Widget build(BuildContext context) {
    final palette = _resolvePalette();
    return Container(
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: brightness == Brightness.light
            ? Border.all(
                color: dynamicScheme?.outlineVariant ??
                    const Color(0xFFECECEC),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatTile(
                value: '${stats.currentStreak}',
                label: 'day streak',
                valueColor: palette.primaryText,
                labelColor: palette.secondaryText,
                valueSize: 24,
              ),
              const SizedBox(height: 12),
              StatTile(
                value: '${stats.prsMerged}',
                label: 'PRs merged',
                valueColor: palette.accentGreen,
                labelColor: palette.secondaryText,
                valueSize: 24,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ContributionGrid(
              key: gridKey,
              weeks: stats.weeks,
              palette: palette,
              gap: 4,
              animate: animate,
            ),
          ),
        ],
      ),
    );
  }

  /// Uses [dynamicScheme] when the caller explicitly opted into wallpaper
  /// matching; otherwise the static palette for [brightness] - so a manually
  /// picked Light/Dark mode is never silently overridden.
  WidgetPalette _resolvePalette() {
    if (dynamicScheme != null) {
      return WidgetPalette.fromColorScheme(dynamicScheme!);
    }
    return WidgetPalette.of(brightness);
  }
}
