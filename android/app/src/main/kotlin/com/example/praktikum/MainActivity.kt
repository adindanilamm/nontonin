package com.example.praktikum

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MethodChannel "nontonin/launcher" dipakai Flutter untuk membuka
 * aplikasi lain (YouTube, browser, WhatsApp) lewat Intent Android.
 */
class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nontonin/launcher")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openYoutube" -> {
                        val key = call.argument<String>("key").orEmpty()
                        // Utamakan aplikasi YouTube, jika tidak ada buka di browser.
                        val opened = start("vnd.youtube:$key") ||
                            start("https://www.youtube.com/watch?v=$key")
                        result.success(opened)
                    }
                    "openUrl" -> {
                        val url = call.argument<String>("url").orEmpty()
                        result.success(url.isNotEmpty() && start(url))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun start(uri: String): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uri))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
    }
}
