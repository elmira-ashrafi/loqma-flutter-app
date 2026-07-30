package delivery.loqma

import android.os.Bundle
import android.webkit.CookieManager
import androidx.activity.enableEdgeToEdge
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Backward-compatible edge-to-edge (Play / Android 15+ recommendation).
        enableEdgeToEdge()
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "delivery.loqma/cdn_cookies",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCookies" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.error("invalid", "url required", null)
                        return@setMethodCallHandler
                    }
                    val cookies = CookieManager.getInstance().getCookie(url) ?: ""
                    result.success(cookies)
                }
                "setCookies" -> {
                    val url = call.argument<String>("url")
                    val cookies = call.argument<String>("cookies")
                    if (url.isNullOrBlank() || cookies.isNullOrBlank()) {
                        result.error("invalid", "url and cookies required", null)
                        return@setMethodCallHandler
                    }
                    val manager = CookieManager.getInstance()
                    manager.setAcceptCookie(true)
                    for (part in cookies.split(";")) {
                        val trimmed = part.trim()
                        if (trimmed.isNotEmpty()) {
                            manager.setCookie(url, trimmed)
                        }
                    }
                    manager.flush()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
