package com.rakshityadav.github_widget

import android.app.WallpaperManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

/// Exposes the phone's actual current wallpaper image to Dart, so the widget
/// can derive colors from it directly. This is more reliable than depending
/// solely on Android's own Material You dynamic-color API, which many OEM
/// skins either don't implement or fall back to a generic default palette
/// on (recognizable as a plain purple/white scheme unrelated to the real
/// wallpaper).
class MainActivity : FlutterActivity() {
    private val channelName = "forge/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "getWallpaperBytes") {
                    result.success(readWallpaperBytes())
                } else {
                    result.notImplemented()
                }
            }
    }

    /// Returns a small downscaled PNG of the current home-screen wallpaper,
    /// or null if it isn't readable (e.g. a live wallpaper with no static
    /// bitmap, or the OS denies access). Downscaling keeps this fast and
    /// means we never hold a full-resolution copy of the wallpaper in memory.
    private fun readWallpaperBytes(): ByteArray? {
        return try {
            val manager = WallpaperManager.getInstance(applicationContext)
            val drawable = manager.drawable ?: manager.fastDrawable ?: return null
            val bitmap = (drawable as? BitmapDrawable)?.bitmap ?: drawableToBitmap(drawable)
            val scaled = downscale(bitmap, 96)
            ByteArrayOutputStream().use { stream ->
                scaled.compress(Bitmap.CompressFormat.PNG, 100, stream)
                stream.toByteArray()
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        val width = drawable.intrinsicWidth.coerceAtLeast(1)
        val height = drawable.intrinsicHeight.coerceAtLeast(1)
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    private fun downscale(bitmap: Bitmap, maxDimension: Int): Bitmap {
        val ratio = minOf(
            maxDimension.toFloat() / bitmap.width,
            maxDimension.toFloat() / bitmap.height,
        ).coerceAtMost(1f)
        val width = (bitmap.width * ratio).toInt().coerceAtLeast(1)
        val height = (bitmap.height * ratio).toInt().coerceAtLeast(1)
        return Bitmap.createScaledBitmap(bitmap, width, height, true)
    }
}
