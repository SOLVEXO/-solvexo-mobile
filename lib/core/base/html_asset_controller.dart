import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

/// Base for controllers backing a static-content screen (About, Privacy
/// Policy, Terms, ...) whose body is a bundled HTML asset — just loads the
/// asset string into [htmlContent] behind [isLoading].
abstract class HtmlAssetController extends GetxController {
  /// Path to the bundled HTML asset, e.g. `assets/html/about.html`.
  String get assetPath;

  final RxBool isLoading = true.obs;
  final RxString htmlContent = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  Future<void> loadContent() async {
    try {
      isLoading.value = true;
      htmlContent.value = await rootBundle.loadString(assetPath);
    } catch (e) {
      debugPrint('❌ Error loading $assetPath: $e');
      ToastUtil.showToast('Failed to load content');
    } finally {
      isLoading.value = false;
    }
  }
}
