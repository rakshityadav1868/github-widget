import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../../features/preview/widget_card.dart';
import '../models/github_stats.dart';

/// Renders the [WidgetCard] to an image and pushes it to the native
/// home-screen widget via the `home_widget` plugin.
class WidgetUpdater {
  static const imageKey = 'widget_image';
  static const androidProvider = 'GithubWidgetProvider';
  static const qualifiedAndroidProvider =
      'com.rakshityadav.github_widget.GithubWidgetProvider';

  /// Renders the widget for the given [stats] and refreshes the home screen.
  ///
  /// When [brightness] is provided along with a [dynamicScheme], the widget
  /// picks up the wallpaper-derived dynamic colors so it matches the system
  /// theme (Android 12+ / Samsung).
  static Future<void> update(
    GitHubStats stats, {
    Brightness? brightness,
    ColorScheme? dynamicScheme,
  }) async {
    final resolved =
        brightness ?? PlatformDispatcher.instance.platformBrightness;
    await HomeWidget.renderFlutterWidget(
      _Renderable(
        stats: stats,
        brightness: resolved,
        dynamicScheme: dynamicScheme,
      ),
      key: imageKey,
      logicalSize: const Size(360, 190),
    );
    await HomeWidget.updateWidget(androidName: androidProvider);
  }

  /// Asks the launcher to pin the widget to the home screen (Android only).
  static Future<void> requestPin() async {
    await HomeWidget.requestPinWidget(
      androidName: androidProvider,
      qualifiedAndroidName: qualifiedAndroidProvider,
    );
  }
}

class _Renderable extends StatelessWidget {
  const _Renderable({
    required this.stats,
    required this.brightness,
    this.dynamicScheme,
  });
  final GitHubStats stats;
  final Brightness brightness;
  final ColorScheme? dynamicScheme;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WidgetCard(
          stats: stats,
          brightness: brightness,
          dynamicScheme: dynamicScheme,
          animate: false,
        ),
      ),
    );
  }
}
