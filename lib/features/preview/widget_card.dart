import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../data/models/github_stats.dart';
import '../../widgets/contribution_grid.dart';
import '../../widgets/stat_tile.dart';

/// The widget itself: a rounded card with a stat column on the left (day streak
/// and PRs merged) and the real contribution grid on the right, colored per
/// [brightness] via [WidgetPalette], matching the reference design.
class WidgetCard extends StatelessWidget {
  const WidgetCard({
    super.key,
    required this.stats,
    required this.brightness,
    this.animate = true,
    this.gridKey,
  });

  final GitHubStats stats;
  final Brightness brightness;
  final bool animate;
  final Key? gridKey;

  @override
  Widget build(BuildContext context) {
    final palette = WidgetPalette.of(brightness);
    return Container(
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: brightness == Brightness.light
            ? Border.all(color: const Color(0xFFECECEC))
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
}
