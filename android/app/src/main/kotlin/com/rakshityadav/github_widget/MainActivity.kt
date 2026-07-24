package com.rakshityadav.github_widget

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

/// MainActivity with dynamic color support (Android 12+ / Samsung themes).
/// The `dynamic_color` package reads the wallpaper-derived colors and makes
/// them available to the Flutter app via `DynamicColorBuilder`.
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
}
