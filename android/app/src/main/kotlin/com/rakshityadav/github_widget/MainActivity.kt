package com.rakshityadav.github_widget

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// Exposes the phone's actual wallpaper color to Dart via
/// WallpaperManager.getWallpaperColors() - the same system API Android
/// itself uses for Material You theming, available since Android 8.1
/// (API 27). Unlike reading the wallpaper bitmap directly
/// (WallpaperManager.getDrawable()), this requires no storage permission at
/// all, since it returns pre-computed representative colors rather than the
/// raw image.
///
/// Note that this channel is registered on *this Activity's* engine, so it
/// only answers while the app is in the foreground. The background refresh
/// isolate has its own engine and cannot reach it - which is why the render
/// parameters are also snapshotted to disk by [RenderPrefs] on every resume.
class MainActivity : FlutterActivity() {
    private val channelName = "forge/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "getWallpaperColor") {
                    result.success(RenderPrefs.wallpaperArgb(this))
                } else {
                    result.notImplemented()
                }
            }
    }

    /// Snapshots the wallpaper color, night-mode setting and screen density
    /// for the background refresh to reuse. On resume rather than on create,
    /// so that a wallpaper or dark-mode change made while Forge sat in the
    /// background is picked up when the user comes back.
    override fun onResume() {
        super.onResume()
        RenderPrefs.capture(this)
    }
}
