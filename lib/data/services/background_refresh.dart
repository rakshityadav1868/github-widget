import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'github_api.dart';
import 'token_store.dart';
import 'widget_render_prefs.dart';
import 'widget_updater.dart';

const _taskName = 'refresh_widget';

/// Runs in a headless background isolate the OS spins up on its own
/// schedule - there's no running app, no UI, just this callback. Must stay a
/// top-level function so the native side can find it by name.
///
/// This same task also runs on-demand right after the wallpaper changes (see
/// WallpaperChangeReceiver.kt), not just on the periodic schedule.
///
/// Deliberately, this task does not resolve *any* theme itself. It has no
/// Activity, no view and no surface, so asking the platform for the
/// wallpaper color, the light/dark setting or the screen density all fail -
/// silently, and with plausible-looking wrong answers rather than errors.
/// Doing so repainted the widget white, purple and blurry every 15 minutes.
/// It now only refreshes the *numbers*, and replays the appearance captured
/// by [WidgetRenderPrefs] while the app was last in the foreground.
@pragma('vm:entry-point')
void backgroundDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, inputData) async {
    if (task != _taskName) return true;

    final store = TokenStore();
    final token = await store.readToken();
    final login = await store.readLogin();
    if (token == null || login == null) return true;

    // Load these before spending a network call: with no captured
    // appearance there is nothing faithful to render, and repainting the
    // widget from defaults is precisely the bug this guards against.
    final prefs = await WidgetRenderPrefs.load();
    if (prefs == null) {
      debugPrint('Forge: no captured render prefs; leaving the widget as-is.');
      return true;
    }

    final api = GitHubApi(token: token);
    try {
      final stats = await api.fetchStats(login);
      await WidgetUpdater.update(
        stats,
        brightness: prefs.brightness,
        dynamicScheme: prefs.scheme,
        pixelRatio: prefs.pixelRatio,
      );
    } catch (error, stack) {
      // Network hiccup, rate limit, etc. - the next scheduled run retries.
      // Logged rather than swallowed: silent catches here are why the widget
      // regressed for three releases without anyone noticing.
      debugPrint('Forge: background refresh failed: $error\n$stack');
    } finally {
      api.close();
    }
    return true;
  });
}

/// Keeps the home-screen widget fresh even when the app isn't open, by
/// periodically re-fetching stats in the background (Android WorkManager).
class BackgroundRefresh {
  /// Registers [backgroundDispatcher] with the OS. Call once at app start,
  /// before scheduling or cancelling anything.
  static Future<void> initialize() {
    return Workmanager().initialize(backgroundDispatcher);
  }

  /// Starts periodic refresh. Android treats 15 minutes as the minimum
  /// interval, not a guarantee - the OS can and will delay it under Doze or
  /// battery saver. Safe to call repeatedly: [ExistingPeriodicWorkPolicy.keep]
  /// leaves an already-scheduled task alone.
  static Future<void> schedule() {
    return Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  /// Stops periodic refresh, e.g. on sign-out.
  static Future<void> cancel() {
    return Workmanager().cancelByUniqueName(_taskName);
  }
}
