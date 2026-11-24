package com.edudeen.app

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Lets Dart hide "Take photo" on devices without any camera
        // (the manifest declares the camera feature as optional).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.edudeen.app/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasCamera" -> result.success(
                        packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY)
                    )
                    else -> result.notImplemented()
                }
            }
    }
}
