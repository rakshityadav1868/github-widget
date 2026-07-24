package com.rakshityadav.github_widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import dev.fluttercommunity.workmanager.BackgroundWorker

/// Fires when the system wallpaper changes, even while Forge isn't running,
/// and enqueues a one-off run of the same background task that periodically
/// refreshes the widget (see background_refresh.dart) - so a new wallpaper
/// is picked up right away instead of waiting for the next 15-minute cycle
/// or for the app to be reopened.
///
/// This reuses the workmanager plugin's own Worker rather than adding a
/// second Dart entry point: the plugin identifies which registered Dart
/// callback to run via a single input-data key (DART_TASK_KEY), so enqueuing
/// a OneTimeWorkRequest with that key set to the same task name used by the
/// periodic registration runs the exact same Dart code.
///
/// The new wallpaper color is read *here*, before the work is enqueued,
/// rather than by the Dart task itself. The task runs in a headless engine
/// that cannot reach MainActivity's wallpaper method channel, so it has no
/// way to see the new color; this receiver has a real Context and does.
class WallpaperChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_WALLPAPER_CHANGED) return

        // Must happen before enqueuing: the work reads these values back.
        RenderPrefs.capture(context)

        val input = Data.Builder()
            .putString(BackgroundWorker.DART_TASK_KEY, "refresh_widget")
            .build()
        val request = OneTimeWorkRequest.Builder(BackgroundWorker::class.java)
            .setInputData(input)
            .build()
        WorkManager.getInstance(context.applicationContext)
            .enqueueUniqueWork(
                "wallpaper_changed_refresh",
                ExistingWorkPolicy.REPLACE,
                request,
            )
    }
}
