package com.rakshityadav.github_widget

import android.app.WallpaperManager
import android.os.Build
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
class MainActivity : FlutterActivity() {
    private val channelName = "forge/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "getWallpaperColor") {
                    result.success(readWallpaperColor())
                } else {
                    result.notImplemented()
                }
            }
    }

    /// Returns the wallpaper's primary color as an ARGB int, or null if
    /// unavailable (pre-API 27, or a live wallpaper that doesn't publish
    /// colors). getWallpaperColors() is API 27+, so this must not even be
    /// called on older devices - not just wrapped in try/catch, since a
    /// missing method is a NoSuchMethodError (not an Exception) and would
    /// crash rather than being caught.
    private fun readWallpaperColor(): Int? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1) return null
        return try {
            val manager = WallpaperManager.getInstance(applicationContext)
            val colors = manager.getWallpaperColors(WallpaperManager.FLAG_SYSTEM)
            colors?.primaryColor?.toArgb()
        } catch (e: Throwable) {
            null
        }
    }
}
