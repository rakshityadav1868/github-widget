import 'package:flutter/material.dart';

/// Colors for Forge, matching the reference design.
///
/// Two palettes - [dark] and [light] - each describing the widget card
/// background, the contribution-grid empty cell, the five green intensity
/// levels of the grid, and the text/accent colors.
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

  static WidgetPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
