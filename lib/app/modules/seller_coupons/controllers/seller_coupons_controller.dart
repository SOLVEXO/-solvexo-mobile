import 'package:book_store_app/app/data/models/marketing/coupon_model.dart';
import 'package:book_store_app/app/data/repositories/coupons_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum CouponFilter { all, active, expired }

class SellerCouponsController extends GetxController {
  final CouponsRepository _repo = CouponsRepository();

  String storeId = '';
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxList<CouponModel> coupons = <CouponModel>[].obs;
  final Rx<CouponFilter> filter = CouponFilter.all.obs;

  List<CouponModel> get filteredCoupons {
    switch (filter.value) {
      case CouponFilter.active:
        return coupons.where((c) => c.isActive && !c.isExpired).toList();
      case CouponFilter.expired:
        return coupons.where((c) => c.isExpired || !c.isActive).toList();
      case CouponFilter.all:
        return coupons;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      storeId = await AppPreferences.getStoreId() ?? '';
      if (storeId.isEmpty) {
        debugPrint('⚠️ SellerCouponsController: no storeId in prefs');
        return;
      }
      final result = await _repo.getCoupons(storeId: storeId, limit: 100);
      coupons.assignAll(result.coupons);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => _load();

  void setFilter(CouponFilter value) => filter.value = value;

  Future<bool> createCoupon({
    required String code,
    required String discountType,
    required double discountValue,
    double? minOrderAmount,
    int? usageLimit,
    String? expiresAt,
  }) async {
    if (storeId.isEmpty) return false;
    isSaving.value = true;
    try {
      final created = await _repo.createCoupon(
        storeId: storeId,
        code: code,
        discountType: discountType,
        discountValue: discountValue,
        minOrderAmount: minOrderAmount,
        usageLimit: usageLimit,
        expiresAt: expiresAt,
      );
      if (created != null) {
        coupons.insert(0, created);
        return true;
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateCoupon(
    CouponModel existing, {
    String? code,
    String? discountType,
    double? discountValue,
    double? minOrderAmount,
    int? usageLimit,
    String? expiresAt,
    bool? isActive,
  }) async {
    isSaving.value = true;
    try {
      final updated = await _repo.updateCoupon(
        storeId: storeId,
        couponId: existing.id,
        code: code,
        discountType: discountType,
        discountValue: discountValue,
        minOrderAmount: minOrderAmount,
        usageLimit: usageLimit,
        expiresAt: expiresAt,
        isActive: isActive,
      );
      if (updated != null) {
        final index = coupons.indexWhere((c) => c.id == existing.id);
        if (index != -1) coupons[index] = updated;
        return true;
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleActive(CouponModel coupon) async {
    await updateCoupon(coupon, isActive: !coupon.isActive);
  }

  Future<void> deleteCoupon(CouponModel coupon) async {
    final ok = await _repo.deleteCoupon(storeId: storeId, couponId: coupon.id);
    if (ok) coupons.removeWhere((c) => c.id == coupon.id);
  }
}
