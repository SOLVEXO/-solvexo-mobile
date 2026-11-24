import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Whether this device has a camera. The Android manifest declares the camera
/// feature as optional, so "Take photo" must be hidden (or refused) on
/// devices without one. Call [init] once in main(); [available] is then a
/// cheap synchronous read. Defaults to true if the check can't run.
class DeviceCamera {
  DeviceCamera._();

  static const _channel = MethodChannel('com.edudeen.app/device');
  static bool _available = true;

  static bool get available => _available;

  static Future<void> init() async {
    if (!Platform.isAndroid) return;
    try {
      _available = await _channel.invokeMethod<bool>('hasCamera') ?? true;
    } catch (e) {
      debugPrint('DeviceCamera.init failed (assuming camera present): $e');
    }
  }
}
