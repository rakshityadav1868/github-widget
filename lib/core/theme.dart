import 'package:flutter/material.dart';

import 'colors.dart';

/// App-wide light and dark themes.
///
/// The app follows the phone's system brightness by default. The widget's own
/// colors live in [WidgetPalette]; these themes style the surrounding app.
class AppTheme {
  const AppTheme._();

  static ThemeData light = _build(Brightness.light);
  static ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final palette = WidgetPalette.of(brightness);
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accentGreen,
        brightness: brightness,
      ),
      fontFamily: 'Roboto',
    );
  }
}
