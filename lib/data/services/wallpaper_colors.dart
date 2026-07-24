import 'dart:ui' as ui;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';

/// Resolves a [ColorScheme] that actually matches the phone's current
/// wallpaper.
///
/// Android's own Material You dynamic-color API ([DynamicColorPlugin]) isn't
/// reliable across OEM skins - many either don't implement per-wallpaper
/// extraction or silently fall back to a generic default palette (a fixed
/// purple/white scheme, unrelated to the real wallpaper). So this reads the
/// actual wallpaper image via a platform channel and derives colors from it
/// directly first, and only falls back to the OS API - then a static
/// palette - if that isn't possible (e.g. a live wallpaper with no static
/// bitmap, or the platform channel is unavailable, such as on iOS).
class WallpaperColors {
  static const _channel = MethodChannel('forge/wallpaper');

  static Future<ColorScheme?> resolve(Brightness brightness) async {
    final fromWallpaper = await _fromWallpaperImage(brightness);
    if (fromWallpaper != null) return fromWallpaper;
    return _fromSystemDynamicColor(brightness);
  }

  static Future<ColorScheme?> _fromWallpaperImage(Brightness brightness) async {
    ui.Image? image;
    try {
      final bytes =
          await _channel.invokeMethod<Uint8List>('getWallpaperBytes');
      if (bytes == null || bytes.isEmpty) return null;

      image = await decodeImageFromList(bytes);
      final palette = await PaletteGenerator.fromImage(image);
      final seed = palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          palette.mutedColor?.color;
      if (seed == null) return null;

      return ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    } catch (_) {
      return null;
    } finally {
      image?.dispose();
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
