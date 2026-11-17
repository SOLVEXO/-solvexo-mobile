import 'package:book_store_app/app/data/models/ai_studio/ai_credits_overview_model.dart';
import 'package:book_store_app/app/data/repositories/ai_studio_repository.dart';
import 'package:book_store_app/app/data/repositories/platform_plans_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AiStudioHubController extends GetxController {
  final AiStudioRepository _repo = AiStudioRepository();
  final PlatformPlansRepository _platformRepo = PlatformPlansRepository();

  String storeId = '';
  final RxBool isLoading = true.obs;
  final RxBool isBuyingCredits = false.obs;
  final Rx<AiCreditsOverviewModel?> credits = Rx<AiCreditsOverviewModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ AiStudioHubController: no storeId in prefs');
      isLoading.value = false;
      return;
    }
    await refresh();
  }

  @override
  Future<void> refresh() async {
    isLoading.value = true;
    credits.value = await _repo.getCredits(storeId);
    isLoading.value = false;
  }

  Future<void> buyCredits() async {
    if (isBuyingCredits.value) return;
    isBuyingCredits.value = true;
    final ok = await _platformRepo.purchaseAddon(storeId, addonType: 'extra_ai_credits');
    isBuyingCredits.value = false;
    if (ok) await refresh();
  }

  void openHistory() => Get.toNamed(Routes.aiStudioHistory);
}
