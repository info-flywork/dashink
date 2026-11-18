package com.flywork.dashink

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// RevenueCat (ve ileride Paywalls) için FlutterFragmentActivity gerekir.
/// launchMode=singleTop: banka doğrulaması sırasında satın alma iptal olmasın.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Kalıcı reddedilen izinler için uygulamanın sistem ayarları sayfası.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dashink/app_settings")
            .setMethodCallHandler { call, result ->
                if (call.method == "open") {
                    try {
                        val intent = Intent(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.fromParts("package", packageName, null),
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
