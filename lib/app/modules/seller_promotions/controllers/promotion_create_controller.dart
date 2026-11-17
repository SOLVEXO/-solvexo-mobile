import 'dart:async';
import 'dart:io';

import 'package:book_store_app/app/data/models/promotions/promotion_price_breakdown_model.dart';
import 'package:book_store_app/app/data/repositories/promotions_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Backs [PromotionCreateView] — a dedicated pushed screen (not a bottom
/// sheet) given the number of fields. Debounces `previewPrice` calls as the
/// seller changes placement/dates/isPeak so the quoted price stays live
/// without hammering the endpoint on every keystroke/tap.
class PromotionCreateController extends GetxController {
  PromotionCreateController({PromotionsRepository? repository}) : _repo = repository ?? PromotionsRepository();

  final PromotionsRepository _repo;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  String storeId = '';
  final RxBool isSubmitting = false.obs;
  final RxBool isPreviewing = false.obs;

  final RxString placement = 'homepageHero'.obs;
  final Rx<DateTime?> startAt = Rx<DateTime?>(null);
  final Rx<DateTime?> endAt = Rx<DateTime?>(null);
  final RxBool isPeak = false.obs;
  final RxString linkType = 'external'.obs;

  final Rx<File?> mainFile = Rx<File?>(null);
  final Rx<File?> mobileFile = Rx<File?>(null);

  final TextEditingController ctaLabelCtrl = TextEditingController();
  final TextEditingController linkTargetCtrl = TextEditingController();
  final TextEditingController messageCtrl = TextEditingController();

  final Rx<PromotionPriceBreakdownModel?> priceBreakdown = Rx<PromotionPriceBreakdownModel?>(null);

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    // Sensible defaults — starts an hour from now, runs for a day — so the
    // preview has something valid to quote immediately.
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, now.hour).add(const Duration(hours: 1));
    startAt.value = start;
    endAt.value = start.add(const Duration(days: 1));
    _fetchPreview();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    ctaLabelCtrl.dispose();
    linkTargetCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }

  void setPlacement(String value) {
    if (placement.value == value) return;
    placement.value = value;
    _schedulePreview();
  }

  void setLinkType(String value) => linkType.value = value;

  void togglePeak(bool value) {
    isPeak.value = value;
    _schedulePreview();
  }

  void setStartAt(DateTime value) {
    startAt.value = value;
    if (endAt.value == null || !endAt.value!.isAfter(value)) {
      endAt.value = value.add(const Duration(hours: 1));
    }
    _schedulePreview();
  }

  void setEndAt(DateTime value) {
    endAt.value = value;
    _schedulePreview();
  }

  void setMainFile(File file) => mainFile.value = file;
  void clearMainFile() => mainFile.value = null;
  void setMobileFile(File file) => mobileFile.value = file;
  void clearMobileFile() => mobileFile.value = null;

  void _schedulePreview() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, _fetchPreview);
  }

  Future<void> _fetchPreview() async {
    if (storeId.isEmpty || startAt.value == null || endAt.value == null) return;
    if (!endAt.value!.isAfter(startAt.value!)) {
      priceBreakdown.value = null;
      return;
    }
    isPreviewing.value = true;
    try {
      priceBreakdown.value = await _repo.previewPrice(
        storeId: storeId,
        placement: placement.value,
        startAt: startAt.value!,
        endAt: endAt.value!,
        isPeak: isPeak.value,
      );
    } finally {
      isPreviewing.value = false;
    }
  }

  /// Returns true on success — [PromotionCreateView] pops back to the list
  /// and refreshes it. On failure the backend's own message (entitlement
  /// caps, validation, feature-flag gating) is surfaced via toast; no
  /// client-side cap logic is invented here.
  Future<bool> submit() async {
    if (isSubmitting.value) return false;

    if (storeId.isEmpty) {
      ToastUtil.showToast('Store not found. Please try again.');
      return false;
    }
    if (mainFile.value == null) {
      ToastUtil.showToast('Please choose a creative image.');
      return false;
    }
    if (startAt.value == null || endAt.value == null || !endAt.value!.isAfter(startAt.value!)) {
      ToastUtil.showToast('Please choose a valid date range.');
      return false;
    }

    isSubmitting.value = true;
    try {
      final result = await _repo.create(
        storeId: storeId,
        placement: placement.value,
        startAt: startAt.value!,
        endAt: endAt.value!,
        file: mainFile.value!,
        mobileFile: mobileFile.value,
        ctaLabel: ctaLabelCtrl.text.trim().isEmpty ? null : ctaLabelCtrl.text.trim(),
        linkType: linkType.value,
        linkTarget: linkTargetCtrl.text.trim().isEmpty ? null : linkTargetCtrl.text.trim(),
        message: messageCtrl.text.trim().isEmpty ? null : messageCtrl.text.trim(),
        isPeak: isPeak.value,
      );

      ToastUtil.showToast(
        result.message ?? (result.success ? 'Promotion request submitted for review.' : 'Failed to submit promotion request'),
      );
      return result.success;
    } finally {
      isSubmitting.value = false;
    }
  }
}
