import 'package:flutter/material.dart';

import 'colors.dart';

/// App-wide light and dark themes.
///
/// The app follows the phone's system brightness by default. The widget's
/// own colors live in [WidgetPalette] and, when the user opts into "Theme
/// match", in the wallpaper-derived scheme resolved by
/// `WallpaperColors.resolve` and carried via [ThemeProvider]; these themes
/// style the surrounding app chrome only.
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

/// Provides the resolved wallpaper/dynamic [ColorScheme] to the widget tree,
/// when one could actually be derived - null means no real per-wallpaper
/// scheme is available on this device, and callers should fall back to the
/// static palette rather than inventing a fake "dynamic" one. This is what
/// [maybeOf] returning null vs. non-null actually means to callers like
/// `PreviewScreen`'s "Theme match" option.
class ThemeProvider extends InheritedWidget {
  const ThemeProvider({
    super.key,
    required this.scheme,
    required super.child,
  });

  final ColorScheme? scheme;

  static ColorScheme? maybeOf(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    return result?.scheme;
  }

  @override
  bool updateShouldNotify(ThemeProvider old) => old.scheme != scheme;
}
