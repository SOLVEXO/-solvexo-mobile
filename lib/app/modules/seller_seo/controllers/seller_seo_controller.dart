import 'package:book_store_app/app/data/models/seo/seo_dashboard_model.dart';
import 'package:book_store_app/app/data/models/seo/seo_meta_model.dart';
import 'package:book_store_app/app/data/repositories/seo_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SellerSeoController extends GetxController {
  final SeoRepository _repo = SeoRepository();

  String storeId = '';
  final RxBool isLoading = true.obs;
  final RxBool isSavingStoreMeta = false.obs;
  final RxBool isTogglingChecklist = false.obs;

  final Rx<SeoDashboardModel?> dashboard = Rx<SeoDashboardModel?>(null);
  final Rx<SeoMetaModel?> storeMeta = Rx<SeoMetaModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ SellerSeoController: no storeId in prefs');
      isLoading.value = false;
      return;
    }
    await refresh();
  }

  @override
  Future<void> refresh() async {
    isLoading.value = true;
    final results = await Future.wait([
      _repo.getDashboard(storeId),
      _repo.getStoreSeo(storeId),
    ]);
    dashboard.value = results[0] as SeoDashboardModel?;
    storeMeta.value = results[1] as SeoMetaModel?;
    isLoading.value = false;
  }

  Future<void> toggleChecklistItem(String key, bool done) async {
    if (isTogglingChecklist.value) return;
    isTogglingChecklist.value = true;
    try {
      final updated = await _repo.updateChecklistItem(storeId, key: key, done: done);
      if (updated != null) await refresh();
    } finally {
      isTogglingChecklist.value = false;
    }
  }

  Future<void> saveStoreMeta({
    String? metaTitle,
    String? metaDescription,
    String? ogTitle,
    String? ogDescription,
    String? ogImage,
    String? twitterCard,
    String? canonicalUrlOverride,
    bool? noindex,
    List<String>? keywords,
  }) async {
    if (isSavingStoreMeta.value) return;
    isSavingStoreMeta.value = true;
    try {
      final updated = await _repo.updateStoreSeo(
        storeId,
        metaTitle: metaTitle,
        metaDescription: metaDescription,
        ogTitle: ogTitle,
        ogDescription: ogDescription,
        ogImage: ogImage,
        twitterCard: twitterCard,
        canonicalUrlOverride: canonicalUrlOverride,
        noindex: noindex,
        keywords: keywords,
      );
      if (updated != null) {
        storeMeta.value = updated;
        await refresh();
      }
    } finally {
      isSavingStoreMeta.value = false;
    }
  }
}
