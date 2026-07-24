import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:github_widget/data/services/widget_render_prefs.dart';

/// These lock down the invariant the whole widget-degradation fix rests on:
/// the background refresh renders only from parameters that were actually
/// captured, and never invents its own.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  late Map<String, Object?> stored;

  setUp(() {
    stored = <String, Object?>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = (call.arguments as Map).cast<String, Object?>();
      switch (call.method) {
        case 'getWidgetData':
          return stored[args['id'] as String] ?? args['defaultValue'];
        case 'saveWidgetData':
          stored[args['id'] as String] = args['data'];
          return true;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('load returns null when nothing has been captured', () async {
    // The background refresh must leave the existing widget image alone
    // rather than repaint it from defaults.
    expect(await WidgetRenderPrefs.load(), isNull);
  });

  test('load returns null when only some values were captured', () async {
    stored[WidgetRenderPrefs.isDarkKey] = true;
    stored[WidgetRenderPrefs.wallpaperArgbKey] = 0xFFB71C1C;

    expect(await WidgetRenderPrefs.load(), isNull);
  });

  test('load replays the captured density, brightness and wallpaper',
      () async {
    stored[WidgetRenderPrefs.pixelRatioKey] = '3.0';
    stored[WidgetRenderPrefs.isDarkKey] = true;
    stored[WidgetRenderPrefs.wallpaperArgbKey] = 0xFFB71C1C;

    final prefs = (await WidgetRenderPrefs.load())!;

    // Never the headless default of 1.0, which renders a blurry third-size
    // image.
    expect(prefs.pixelRatio, 3.0);
    // Never Flutter's headless default of light.
    expect(prefs.brightness, Brightness.dark);
    // Seeded from the real wallpaper, not a generic palette.
    expect(prefs.scheme, isNotNull);
    expect(prefs.scheme!.brightness, Brightness.dark);
  });

  test('a manually chosen Light or Dark wins over the system setting',
      () async {
    stored[WidgetRenderPrefs.pixelRatioKey] = '2.75';
    stored[WidgetRenderPrefs.isDarkKey] = true;
    stored[WidgetRenderPrefs.wallpaperArgbKey] = 0xFFB71C1C;
    await WidgetRenderPrefs.saveMode(WidgetThemeMode.light);

    final prefs = (await WidgetRenderPrefs.load())!;

    expect(prefs.brightness, Brightness.light);
    // Static palette, exactly as the app's own preview resolves it.
    expect(prefs.scheme, isNull);
  });

  test('wallpaper matching without a wallpaper color uses the static palette',
      () async {
    stored[WidgetRenderPrefs.pixelRatioKey] = '3.0';
    stored[WidgetRenderPrefs.isDarkKey] = true;
    await WidgetRenderPrefs.saveMode(WidgetThemeMode.matchWallpaper);

    final prefs = (await WidgetRenderPrefs.load())!;

    // Rather than falling back to Android's generic dynamic-color palette,
    // which reports purple on the OEM skins this app targets.
    expect(prefs.scheme, isNull);
    expect(prefs.brightness, Brightness.dark);
  });

  test('defaults to wallpaper matching when no mode was ever saved', () async {
    stored[WidgetRenderPrefs.pixelRatioKey] = '3.0';
    stored[WidgetRenderPrefs.isDarkKey] = false;
    stored[WidgetRenderPrefs.wallpaperArgbKey] = 0xFF1B5E20;

    final prefs = (await WidgetRenderPrefs.load())!;

    expect(prefs.mode, WidgetThemeMode.matchWallpaper);
    expect(prefs.scheme, isNotNull);
  });
}
