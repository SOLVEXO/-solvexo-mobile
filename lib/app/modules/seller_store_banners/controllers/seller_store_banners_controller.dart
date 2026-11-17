import 'dart:io';

import 'package:book_store_app/app/data/models/activity_log/activity_log_model.dart';
import 'package:book_store_app/app/data/models/store_banner/store_banner_model.dart';
import 'package:book_store_app/app/data/repositories/store_banner_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

/// Drives the seller's free storefront hero carousel screen
/// (`/seller/store-banners`) — list, create, edit, pause/resume, delete and
/// per-banner activity timeline, all against [StoreBannerRepository].
class SellerStoreBannersController extends GetxController {
  final StoreBannerRepository _repo = StoreBannerRepository();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxList<StoreBannerModel> banners = <StoreBannerModel>[].obs;

  String storeId = '';

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    await refreshData();
  }

  Future<void> refreshData() async {
    if (storeId.isEmpty) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    banners.assignAll(await _repo.list(storeId));
    isLoading.value = false;
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<bool> createBanner({
    required File file,
    File? mobileFile,
    String type = 'hero',
    String? ctaLabel,
    String linkType = 'external',
    String? linkTarget,
    int? order,
    int? priority,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    if (storeId.isEmpty || isSaving.value) return false;
    isSaving.value = true;
    final result = await _repo.create(
      storeId: storeId,
      file: file,
      mobileFile: mobileFile,
      type: type,
      ctaLabel: ctaLabel,
      linkType: linkType,
      linkTarget: linkTarget,
      order: order,
      priority: priority,
      startAt: startAt,
      endAt: endAt,
    );
    isSaving.value = false;

    if (result.success && result.data != null) {
      banners.add(result.data!);
      return true;
    }
    ToastUtil.showToast(result.message ?? 'Failed to create banner.');
    return false;
  }

  // ── Update (JSON-only — image can't be changed after creation) ─────────────

  Future<bool> updateBanner(
    StoreBannerModel existing, {
    String? type,
    String? ctaLabel,
    String? linkType,
    String? linkTarget,
    int? order,
    int? priority,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    if (storeId.isEmpty || isSaving.value) return false;
    isSaving.value = true;
    final result = await _repo.update(
      storeId: storeId,
      bannerId: existing.id,
      type: type,
      ctaLabel: ctaLabel,
      linkType: linkType,
      linkTarget: linkTarget,
      order: order,
      priority: priority,
      startAt: startAt,
      endAt: endAt,
    );
    isSaving.value = false;

    if (result.success && result.data != null) {
      final idx = banners.indexWhere((b) => b.id == existing.id);
      if (idx != -1) banners[idx] = result.data!;
      return true;
    }
    ToastUtil.showToast(result.message ?? 'Failed to update banner.');
    return false;
  }

  // ── Status actions ───────────────────────────────────────────────────────

  Future<void> pauseBanner(StoreBannerModel banner) async {
    final ok = await _repo.pause(storeId, banner.id);
    if (ok) {
      await refreshData();
    } else {
      ToastUtil.showToast('Failed to pause banner.');
    }
  }

  Future<void> resumeBanner(StoreBannerModel banner) async {
    final ok = await _repo.resume(storeId, banner.id);
    if (ok) {
      await refreshData();
    } else {
      ToastUtil.showToast('Failed to resume banner.');
    }
  }

  Future<void> deleteBanner(StoreBannerModel banner) async {
    final ok = await _repo.delete(storeId, banner.id);
    if (ok) {
      banners.removeWhere((b) => b.id == banner.id);
    } else {
      ToastUtil.showToast('Failed to delete banner.');
    }
  }

  Future<List<ActivityLogModel>> loadTimeline(String bannerId) => _repo.timeline(storeId, bannerId);
}
