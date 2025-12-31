import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class MediaPermissionHandler {
  static Future<bool> requestCameraPermission() async {
    // PermissionStatus permission = await Permission.camera.request();

    return true;
  }

  static Future<PermissionStatus> checkGalleryPermission() async {
    PermissionStatus permission = Platform.isIOS
        ? await Permission.photos.status
        : await Permission.storage.status;

    return permission;
  }

  static Future<PermissionStatus> checkCameraPermission() async {
    PermissionStatus permission = Platform.isIOS
        ? await Permission.photos.status
        : await Permission.storage.status;

    return permission;
  }

  static Future<bool> requestGalleryPermission() async {
    // PermissionStatus permission = Platform.isIOS
    //     ? await Permission.photos.request()
    //     : await Permission.storage.request();

    return true;
  }
}
