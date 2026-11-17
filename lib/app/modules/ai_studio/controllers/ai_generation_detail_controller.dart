import 'package:book_store_app/app/data/models/ai_studio/ai_generation_model.dart';
import 'package:book_store_app/app/data/repositories/ai_studio_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Per-screen controller for a single generation's detail page — always
/// re-put per navigation (same pattern as ProductDetail/Checkout), since the
/// generation id comes from route arguments.
class AiGenerationDetailController extends GetxController {
  final AiStudioRepository _repo = AiStudioRepository();

  final String generationId = Get.arguments as String;
  String _storeId = '';

  final RxBool isLoading = true.obs;
  final RxBool isAccepting = false.obs;
  final Rx<AiGenerationModel?> generation = Rx<AiGenerationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    _storeId = await AppPreferences.getStoreId() ?? '';
    if (_storeId.isEmpty) {
      debugPrint('⚠️ AiGenerationDetailController: no storeId in prefs');
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    generation.value = await _repo.getGeneration(_storeId, generationId);
    isLoading.value = false;
  }

  Future<void> accept({bool applyToProduct = false}) async {
    if (isAccepting.value) return;
    isAccepting.value = true;
    final updated = await _repo.acceptGeneration(_storeId, generationId, applyToProduct: applyToProduct);
    isAccepting.value = false;
    if (updated != null) {
      generation.value = updated;
      ToastUtil.showToast(applyToProduct ? 'Applied to product' : 'Marked as accepted');
    }
  }
}
