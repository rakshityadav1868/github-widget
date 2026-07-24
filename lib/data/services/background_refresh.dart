import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'github_api.dart';
import 'token_store.dart';
import 'widget_updater.dart';

const _taskName = 'refresh_widget';

/// Runs in a headless background isolate the OS spins up on its own
/// schedule - there's no running app, no UI, just this callback. Must stay a
/// top-level function so the native side can find it by name.
@pragma('vm:entry-point')
void backgroundDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, inputData) async {
    if (task != _taskName) return true;

    final store = TokenStore();
    final token = await store.readToken();
    final login = await store.readLogin();
    if (token == null || login == null) return true;

    final api = GitHubApi(token: token);
    try {
      final stats = await api.fetchStats(login);
      await WidgetUpdater.update(stats);
    } catch (_) {
      // Network hiccup, rate limit, etc. - the next scheduled run retries.
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
