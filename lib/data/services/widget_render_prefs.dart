import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// Which palette the widget uses: a manually forced Light or Dark look, or
/// [matchWallpaper] to follow the wallpaper-derived color.
enum WidgetThemeMode { light, dark, matchWallpaper }

/// How to render the widget, recorded while the app is in the foreground so
/// that the headless background refresh can reproduce it exactly.
///
/// The background isolate has no Activity, no view and no surface, so it
/// cannot read the wallpaper color, the system light/dark setting or the
/// screen density - and every one of those failures is silent, yielding a
/// white, purple, blurry widget rather than an error. So it doesn't ask.
/// Android writes the three system values on every resume and on every
/// wallpaper change (see RenderPrefs.kt), the app writes the user's chosen
/// [mode], and the background only ever reads them back.
///
/// [load] returning null means "no faithful render is possible right now" -
/// callers must then leave the existing widget image alone rather than
/// falling back to defaults. A widget showing slightly old numbers is a far
/// better outcome than one repainted in the wrong theme.
@immutable
class WidgetRenderPrefs {
  const WidgetRenderPrefs({
    required this.systemBrightness,
    required this.pixelRatio,
    required this.mode,
    this.wallpaperArgb,
  });

  /// Written by RenderPrefs.kt - keep these in sync with it.
  static const wallpaperArgbKey = 'render_wallpaper_argb';
  static const isDarkKey = 'render_is_dark';
  static const pixelRatioKey = 'render_pixel_ratio';

  /// Written from Dart, since it's a user choice rather than a system value.
  static const modeKey = 'render_mode';

  /// The phone's light/dark setting as of the last capture.
  final Brightness systemBrightness;

  /// The screen's device pixel ratio. Rendering at the platform default of
  /// 1.0 instead of this produces a third-size image that the launcher
  /// upscales into a blur.
  final double pixelRatio;

  final WidgetThemeMode mode;

  /// The wallpaper's primary color, or null when the system couldn't report
  /// one (pre-API 27, or a live wallpaper publishing no colors).
  final int? wallpaperArgb;

  /// The brightness to actually render at: a manually chosen Light or Dark
  /// wins over the system setting, matching how the app's own preview
  /// resolves it.
  Brightness get brightness => switch (mode) {
        WidgetThemeMode.light => Brightness.light,
        WidgetThemeMode.dark => Brightness.dark,
        WidgetThemeMode.matchWallpaper => systemBrightness,
      };

  /// The wallpaper-derived scheme, or null to use the static palette.
  ///
  /// Null for a manually chosen Light/Dark (which deliberately uses the
  /// static palette), and null when there's no wallpaper color to seed from.
  /// Note there is no fallback to Android's dynamic-color API here, unlike
  /// [WallpaperColors]: that API reports a generic purple on the OEM skins
  /// this app targets, and reaching it from the background is exactly how
  /// the widget used to turn purple.
  ColorScheme? get scheme {
    final argb = wallpaperArgb;
    if (mode != WidgetThemeMode.matchWallpaper || argb == null) return null;
    return ColorScheme.fromSeed(
      seedColor: Color(argb & 0xFFFFFFFF),
      brightness: brightness,
    );
  }

  /// Records the user's palette choice. The system values alongside it are
  /// written natively; this is the only piece Dart owns.
  static Future<void> saveMode(WidgetThemeMode mode) async {
    await HomeWidget.saveWidgetData<String>(modeKey, mode.name);
  }

  /// Reads back a complete set of render parameters, or null if the app has
  /// never captured them (so nothing faithful can be rendered yet).
  static Future<WidgetRenderPrefs?> load() async {
    // Density is the required key: it's written on every capture, so its
    // absence means no capture has ever happened on this install.
    final ratio =
        double.tryParse(await HomeWidget.getWidgetData<String>(pixelRatioKey) ?? '');
    if (ratio == null || ratio <= 0) return null;

    final isDark = await HomeWidget.getWidgetData<bool>(isDarkKey) ?? false;
    final argb = await HomeWidget.getWidgetData<int>(wallpaperArgbKey);
    final modeName = await HomeWidget.getWidgetData<String>(modeKey);

    return WidgetRenderPrefs(
      systemBrightness: isDark ? Brightness.dark : Brightness.light,
      pixelRatio: ratio,
      // Wallpaper matching is the default, same as the app's preview screen.
      mode: WidgetThemeMode.values.asNameMap()[modeName] ??
          WidgetThemeMode.matchWallpaper,
      wallpaperArgb: argb,
    );
  }
}
