import 'package:flutter/material.dart';

import 'colors.dart';

/// App-wide light and dark themes.
///
/// The app follows the phone's system brightness by default. On Android 12+
/// (and Samsung devices with wallpaper-based theming), the theme is derived
/// from the wallpaper's dynamic color so the whole app — and the widget —
/// blends with the rest of the system UI. The widget's own colors live in
/// [WidgetPalette]; these themes style the surrounding app.
class AppTheme {
  const AppTheme._();

  /// Resolves the [WidgetPalette] for the current [Brightness], using dynamic
  /// colors when available.
  static WidgetPalette paletteFor(Brightness brightness,
      {ColorScheme? dynamic}) {
    if (dynamic != null) return WidgetPalette.fromColorScheme(dynamic);
    return WidgetPalette.of(brightness);
  }

  static ThemeData light = _build(Brightness.light);
  static ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final palette = WidgetPalette.of(brightness);
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accentGreen,
        brightness: brightness,
      ),
      fontFamily: 'Roboto',
    );
  }
}

/// Provides the resolved [ColorScheme] (dynamic or fallback) to the widget
/// tree via an inherited widget.
class ThemeProvider extends InheritedWidget {
  const ThemeProvider({
    super.key,
    required this.scheme,
    required super.child,
  });

  final ColorScheme scheme;

  static ColorScheme? maybeOf(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    return result?.scheme;
  }

  static ColorScheme of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    return result?.scheme ??
        ColorScheme.fromSeed(seedColor: WidgetPalette.dark.accentGreen);
  }

  @override
  bool updateShouldNotify(ThemeProvider old) =>
      old.scheme != scheme;
}
