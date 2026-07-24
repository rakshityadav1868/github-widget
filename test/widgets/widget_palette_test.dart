import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:github_widget/core/colors.dart';
import 'package:github_widget/data/services/widget_render_prefs.dart';

double _hue(Color color) => HSLColor.fromColor(color).hue;

/// The widget is supposed to take its color from whatever the wallpaper
/// actually is. These check that it does so for *every* hue - including
/// purple, which is easy to confuse with the generic Material baseline
/// palette that Android's dynamic-color API returns on some OEM skins.
/// Dropping that fallback removed the fake purple; it must not have removed
/// support for genuinely purple wallpapers.
void main() {
  const wallpapers = <String, int>{
    'deep purple': 0xFF6A1B9A,
    'violet': 0xFF7C4DFF,
    'red': 0xFFB71C1C,
    'green': 0xFF1B5E20,
    'blue': 0xFF0D47A1,
    'orange': 0xFFE65100,
  };

  group('the widget palette follows the wallpaper hue', () {
    wallpapers.forEach((name, argb) {
      test(name, () {
        final seed = Color(argb);
        final scheme = ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        );
        final palette = WidgetPalette.fromColorScheme(scheme);

        // Material's tonal mapping shifts hue slightly while adjusting
        // chroma and tone; what matters is that it stays the same color to
        // the eye rather than snapping to some unrelated default.
        expect(
          _hue(palette.accentGreen),
          closeTo(_hue(seed), 15),
          reason: '$name wallpaper should give a $name accent',
        );
        expect(
          _hue(palette.gridLevels[2]),
          closeTo(_hue(seed), 15),
          reason: '$name wallpaper should give a $name contribution grid',
        );
      });
    });
  });

  test('two different wallpapers never collapse to the same palette', () {
    // The old dynamic-color fallback returned one fixed palette no matter
    // what the wallpaper was, which is exactly how a red-and-black phone
    // ended up with a purple widget.
    final palettes = wallpapers.values.map((argb) {
      final scheme = ColorScheme.fromSeed(
        seedColor: Color(argb),
        brightness: Brightness.dark,
      );
      return WidgetPalette.fromColorScheme(scheme).accentGreen.toARGB32();
    }).toSet();

    expect(palettes, hasLength(wallpapers.length));
  });

  test('a purple wallpaper survives the round trip through stored prefs', () {
    // The background refresh rebuilds the scheme from the stored seed rather
    // than from a live platform call, so the seed has to be what comes back.
    const purple = 0xFF6A1B9A;
    const prefs = WidgetRenderPrefs(
      systemBrightness: Brightness.dark,
      pixelRatio: 3.0,
      mode: WidgetThemeMode.matchWallpaper,
      wallpaperArgb: purple,
    );

    expect(
      _hue(prefs.scheme!.primary),
      closeTo(_hue(const Color(purple)), 15),
    );
  });
}
