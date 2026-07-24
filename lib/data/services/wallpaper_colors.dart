import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Resolves a [ColorScheme] that actually matches the phone's current
/// wallpaper.
///
/// Android's own Material You dynamic-color API ([DynamicColorPlugin]) isn't
/// reliable across OEM skins - many either don't implement per-wallpaper
/// extraction or silently fall back to a generic default palette (a fixed
/// purple/black scheme, unrelated to the real wallpaper). So this reads the
/// wallpaper's actual color via `WallpaperManager.getWallpaperColors()` - the
/// same system API Android itself uses for Material You, available since
/// Android 8.1 (API 27), and unlike reading the wallpaper bitmap directly,
/// it needs no storage permission. Falls back to the OS dynamic-color API,
/// then null (static palette), if that isn't available.
class WallpaperColors {
  static const _channel = MethodChannel('forge/wallpaper');

  static Future<ColorScheme?> resolve(Brightness brightness) async {
    final fromWallpaper = await _fromWallpaperColor(brightness);
    if (fromWallpaper != null) return fromWallpaper;
    return _fromSystemDynamicColor(brightness);
  }

  static Future<ColorScheme?> _fromWallpaperColor(Brightness brightness) async {
    try {
      final argb = await _channel.invokeMethod<int>('getWallpaperColor');
      if (argb == null) return null;
      return ColorScheme.fromSeed(seedColor: Color(argb), brightness: brightness);
    } catch (_) {
      return null;
    }
  }

  static Future<ColorScheme?> _fromSystemDynamicColor(
    Brightness brightness,
  ) async {
    try {
      final palette = await DynamicColorPlugin.getCorePalette();
      return palette?.toColorScheme(brightness: brightness);
    } catch (_) {
      return null;
    }
  }
}
