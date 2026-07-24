import 'package:flutter/material.dart';

/// Colors for Forge, matching the reference design.
///
/// Two palettes — [dark] and [light] — each describing the widget card
/// background, the contribution-grid empty cell, the five green intensity
/// levels of the grid, and the text/accent colors.
///
/// On Android 12+ (and devices with Samsung's wallpaper-based theming), a
/// [dynamic] palette is derived from the wallpaper / system theme so the
/// widget blends with the rest of the UI. When dynamic colors aren't
/// available, [of] falls back to [dark] / [light].
class WidgetPalette {
  const WidgetPalette({
    required this.cardBackground,
    required this.emptyCell,
    required this.gridLevels,
    required this.primaryText,
    required this.secondaryText,
    required this.accentGreen,
  });

  /// Card background (near-black in dark, white in light).
  final Color cardBackground;

  /// Empty contribution-grid cell.
  final Color emptyCell;

  /// Five green intensities, lightest to darkest activity.
  final List<Color> gridLevels;

  /// Big numbers and titles.
  final Color primaryText;

  /// Labels like "day streak".
  final Color secondaryText;

  /// Green highlight (e.g. the "148 PRs merged" number).
  final Color accentGreen;

  static const WidgetPalette dark = WidgetPalette(
    cardBackground: Color(0xFF0D0D0D),
    emptyCell: Color(0xFF1B1F24),
    gridLevels: [
      Color(0xFF0E4429),
      Color(0xFF196C2E),
      Color(0xFF26A641),
      Color(0xFF3FB950),
      Color(0xFF56D364),
    ],
    primaryText: Color(0xFFFFFFFF),
    secondaryText: Color(0xFF9EA3A8),
    accentGreen: Color(0xFF3FB950),
  );

  static const WidgetPalette light = WidgetPalette(
    cardBackground: Color(0xFFFFFFFF),
    emptyCell: Color(0xFFEBEDF0),
    gridLevels: [
      Color(0xFF9BE9A8),
      Color(0xFF40C463),
      Color(0xFF30A14E),
      Color(0xFF216E39),
      Color(0xFF166B34),
    ],
    primaryText: Color(0xFF1B1F24),
    secondaryText: Color(0xFF8A9096),
    accentGreen: Color(0xFF2DA44E),
  );

  /// Builds a palette from a Material [ColorScheme], so the widget picks up
  /// the wallpaper-derived dynamic colors on Android 12+ / Samsung themes.
  ///
  /// The contribution grid keeps its GitHub-green levels (so the visual stays
  /// recognizable), while the card, text, and accent colors follow the system
  /// theme.
  static WidgetPalette fromColorScheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final primary = scheme.primary;
    final surface = scheme.surface;
    final onSurface = scheme.onSurface;
    final onSurfaceVariant = scheme.onSurfaceVariant;

    // Derive five green-ish levels from the primary color so the grid still
    // looks like GitHub's contribution calendar but tinted to the theme.
    final levels = _deriveGridLevels(primary, isDark);

    return WidgetPalette(
      cardBackground: surface,
      emptyCell: isDark
          ? onSurface.withValues(alpha: 0.08)
          : onSurface.withValues(alpha: 0.06),
      gridLevels: levels,
      primaryText: onSurface,
      secondaryText: onSurfaceVariant,
      accentGreen: primary,
    );
  }

  /// Generates five grid intensity colors from a seed [color].
  /// Returns colors for activity levels 1–4 (plus one extra for safety).
  /// The grid uses shades of the seed color's hue, at increasing
  /// lightness/darkness per level, so it matches the wallpaper theme while
  /// keeping the same darkest-to-brightest progression as the static
  /// palettes.
  static List<Color> _deriveGridLevels(Color seed, bool isDark) {
    final hue = HSVColor.fromColor(seed).hue;
    return [
      // Level 1 — lightest
      HSLColor.fromAHSL(1, hue, 0.45, isDark ? 0.28 : 0.72).toColor(),
      // Level 2
      HSLColor.fromAHSL(1, hue, 0.45, isDark ? 0.42 : 0.60).toColor(),
      // Level 3
      HSLColor.fromAHSL(1, hue, 0.50, isDark ? 0.56 : 0.50).toColor(),
      // Level 4 — darkest
      HSLColor.fromAHSL(1, hue, 0.50, isDark ? 0.70 : 0.40).toColor(),
      // Level 5 (extra, for safety)
      HSLColor.fromAHSL(1, hue, 0.50, isDark ? 0.85 : 0.30).toColor(),
    ];
  }

  static WidgetPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
