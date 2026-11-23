import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// What the app is about to ask for (R7). Shown in the app's own dialog
/// before the system prompt, in English or Urdu, because Android's system
/// dialogs cannot carry our text and iOS has no usage text for notifications.
enum PermissionKind { camera, photos, notifications }

class PermissionRationale {
  PermissionRationale._();

  static String title(PermissionKind k) => switch (k) {
        PermissionKind.camera => 'Allow camera access'.tr,
        PermissionKind.photos => 'Allow photo access'.tr,
        PermissionKind.notifications => 'Turn on notifications'.tr,
      };

  static String body(PermissionKind k) => switch (k) {
        PermissionKind.camera =>
          'Edudeen uses the camera only when you take a photo to upload, such as a payment proof, a return photo or your profile picture.'.tr,
        PermissionKind.photos =>
          'Edudeen opens your photos only to upload the picture you choose, such as a payment proof, a review photo or your profile picture.'.tr,
        PermissionKind.notifications =>
          'Get updates about your orders, downloads, messages and offers. You can change this anytime in Notification Preferences.'.tr,
      };

  /// true = user wants to continue to the system prompt.
  static Future<bool> ask(PermissionKind k) async {
    final r = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title(k)),
        content: Text(body(k)),
        actions: [
          TextButton(
            key: const Key('rationaleNotNow'),
            style: TextButton.styleFrom(minimumSize: const Size(64, 44)),
            onPressed: () => Get.back(result: false),
            child: Text('Not now'.tr),
          ),
          FilledButton(
            key: const Key('rationaleContinue'),
            style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
            onPressed: () => Get.back(result: true),
            child: Text('Continue'.tr),
          ),
        ],
      ),
    );
    return r == true;
  }
}
