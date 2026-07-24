import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Resolves a [ColorScheme] that actually matches the phone's current
/// wallpaper.
///
/// Reads the wallpaper's real color via
/// `WallpaperManager.getWallpaperColors()` - the same system API Android
/// itself uses for Material You, available since Android 8.1 (API 27), and
/// unlike reading the wallpaper bitmap directly it needs no storage
/// permission.
///
/// Returns null when no wallpaper color is available, and deliberately does
/// *not* fall back to Android's own dynamic-color API
/// (`DynamicColorPlugin.getCorePalette`). That API isn't reliable across OEM
/// skins: many either don't implement per-wallpaper extraction or silently
/// return a generic default palette - a fixed purple, unrelated to the real
/// wallpaper. A fallback that confidently reports the wrong colors is worse
/// than no fallback, so null here means "no wallpaper match available" and
/// callers use the static palette, which at least looks deliberate.
class WallpaperColors {
  static const _channel = MethodChannel('forge/wallpaper');

  /// The wallpaper-matched scheme, or null if this device can't report one.
  ///
  /// Only answers in the foreground: the channel is registered on
  /// MainActivity's engine. Background code must read the value captured by
  /// `WidgetRenderPrefs` rather than calling this.
  static Future<ColorScheme?> resolve(Brightness brightness) async {
    final argb = await primaryArgb();
    if (argb == null) return null;
    return ColorScheme.fromSeed(
      seedColor: Color(argb & 0xFFFFFFFF),
      brightness: brightness,
    );
  }

  /// The wallpaper's primary color as an ARGB int, or null if unavailable.
  static Future<int?> primaryArgb() async {
    try {
      return await _channel.invokeMethod<int>('getWallpaperColor');
    } catch (_) {
      return null;
    }
  }
}
