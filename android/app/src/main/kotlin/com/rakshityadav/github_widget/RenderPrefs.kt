package com.rakshityadav.github_widget

import android.app.WallpaperManager
import android.content.Context
import android.content.res.Configuration
import android.os.Build

/// Records everything the widget needs in order to be re-rendered
/// *identically* later, from the headless background isolate that refreshes
/// it (see background_refresh.dart).
///
/// That isolate runs in a FlutterEngine built with no Activity, no view and
/// no surface, so the three inputs a render needs are all unavailable there
/// and all fail silently:
///
///  - the wallpaper color: the method channel that reads it is registered on
///    MainActivity's engine, so in the background it throws
///    MissingPluginException and the Dart side falls back to Android's
///    generic dynamic-color palette - a purple unrelated to the wallpaper;
///  - the light/dark setting: delivered over SettingsChannel only once a
///    FlutterView attaches, so it stays at Flutter's default of light;
///  - the screen density: derived from viewport metrics that never arrive,
///    so it resolves to 1.0 and the widget renders at a third of its size,
///    then gets upscaled into a blur.
///
/// Guessing at these produced a white, purple, blurry widget every 15
/// minutes. So instead of guessing, we capture them here - from a real
/// Context, where all three are answerable - and let the background read
/// them back.
object RenderPrefs {
    /// The SharedPreferences file the home_widget plugin reads and writes.
    /// Hardcoded because the plugin's own constant is `internal` to it.
    private const val PREFERENCES = "HomeWidgetPreferences"

    private const val WALLPAPER_ARGB = "render_wallpaper_argb"
    private const val IS_DARK = "render_is_dark"
    private const val PIXEL_RATIO = "render_pixel_ratio"

    /// Snapshots the current wallpaper color, night-mode setting and screen
    /// density. Cheap enough to call on every resume and on every wallpaper
    /// change.
    fun capture(context: Context) {
        val prefs = context
            .getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()

        // Removed rather than left stale when the system can't report a
        // color: a missing key tells the background to use the static
        // palette, whereas a stale one would tint the widget to a wallpaper
        // that is no longer there.
        val argb = wallpaperArgb(context)
        if (argb != null) {
            prefs.putInt(WALLPAPER_ARGB, argb)
        } else {
            prefs.remove(WALLPAPER_ARGB)
        }

        val night =
            context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        prefs.putBoolean(IS_DARK, night == Configuration.UI_MODE_NIGHT_YES)

        // Stored as a string, not a float: Flutter's standard message codec
        // has no Float type, so a SharedPreferences float would not survive
        // the trip back to Dart.
        prefs.putString(
            PIXEL_RATIO,
            context.resources.displayMetrics.density.toString(),
        )

        prefs.apply()
    }

    /// The wallpaper's primary color as an ARGB int, or null if unavailable
    /// (pre-API 27, or a live wallpaper that publishes no colors).
    ///
    /// getWallpaperColors() is API 27+, so this must not even be called on
    /// older devices - not just wrapped in try/catch, since a missing method
    /// is a NoSuchMethodError (not an Exception) and would crash rather than
    /// being caught.
    fun wallpaperArgb(context: Context): Int? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1) return null
        return try {
            WallpaperManager.getInstance(context.applicationContext)
                .getWallpaperColors(WallpaperManager.FLAG_SYSTEM)
                ?.primaryColor
                ?.toArgb()
        } catch (e: Throwable) {
            null
        }
    }
}
