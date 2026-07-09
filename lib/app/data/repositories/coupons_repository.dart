import 'package:book_store_app/app/data/models/marketing/coupon_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CouponsRepository {
  final BaseClient _client = BaseClient();

  // ─── GET /api/marketing/:storeId/coupons ──────────────────────────────────

  Future<({List<CouponModel> coupons, int total, int totalPages})> getCoupons({
    required String storeId,
    int page = 1,
    int limit = 20,
    bool? isActive,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.coupons(storeId),
        queryParameters: {
          'page': page,
          'limit': limit,
          if (isActive != null) 'isActive': isActive,
        },
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        final coupons = (data['coupons'] as List)
            .cast<Map<String, dynamic>>()
            .map(CouponModel.fromJson)
            .toList();

        return (
          coupons: coupons,
          total: pagination['total'] as int? ?? 0,
          totalPages: pagination['totalPages'] as int? ?? 1,
        );
      }

      return (coupons: <CouponModel>[], total: 0, totalPages: 1);
    } on DioException catch (e) {
      debugPrint('❌ getCoupons DioException: ${e.response?.statusCode}');
      DioExceptionHandler.handleDioException(e);
      return (coupons: <CouponModel>[], total: 0, totalPages: 1);
    } catch (e) {
      debugPrint('❌ getCoupons error: $e');
      ToastUtil.showToast('Failed to load coupons. Please try again.');
      return (coupons: <CouponModel>[], total: 0, totalPages: 1);
    }
  }

  // ─── POST /api/marketing/:storeId/coupons ─────────────────────────────────

  Future<CouponModel?> createCoupon({
    required String storeId,
    required String code,
    required String discountType,
    required double discountValue,
    double? minOrderAmount,
    int? usageLimit,
    String? expiresAt,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.coupons(storeId),
        data: {
          'code': code,
          'discountType': discountType,
          'discountValue': discountValue,
          if (minOrderAmount != null) 'minOrderAmount': minOrderAmount,
          if (usageLimit != null) 'usageLimit': usageLimit,
          if (expiresAt != null) 'expiresAt': expiresAt,
        },
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Coupon created');
        return CouponModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to create coupon');
      return null;
    } on DioException catch (e) {
      debugPrint('❌ createCoupon DioException: ${e.response?.statusCode}');
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ createCoupon error: $e');
      ToastUtil.showToast('Failed to create coupon. Please try again.');
      return null;
    }
  }

  // ─── PATCH /api/marketing/:storeId/coupons/:couponId ──────────────────────

  Future<CouponModel?> updateCoupon({
    required String storeId,
    required String couponId,
    String? code,
    String? discountType,
    double? discountValue,
    double? minOrderAmount,
    int? usageLimit,
    String? expiresAt,
    bool? isActive,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.couponById(storeId, couponId),
        data: {
          if (code != null) 'code': code,
          if (discountType != null) 'discountType': discountType,
          if (discountValue != null) 'discountValue': discountValue,
          if (minOrderAmount != null) 'minOrderAmount': minOrderAmount,
          if (usageLimit != null) 'usageLimit': usageLimit,
          if (expiresAt != null) 'expiresAt': expiresAt,
          if (isActive != null) 'isActive': isActive,
        },
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Coupon updated');
        return CouponModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to update coupon');
      return null;
    } on DioException catch (e) {
      debugPrint('❌ updateCoupon DioException: ${e.response?.statusCode}');
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateCoupon error: $e');
      ToastUtil.showToast('Failed to update coupon. Please try again.');
      return null;
    }
  }

  // ─── DELETE /api/marketing/:storeId/coupons/:couponId ─────────────────────

  Future<bool> deleteCoupon({required String storeId, required String couponId}) async {
    try {
      final response = await _client.delete(
        ApiConstants.couponById(storeId, couponId),
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Coupon deleted');
        return true;
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to delete coupon');
      return false;
    } on DioException catch (e) {
      debugPrint('❌ deleteCoupon DioException: ${e.response?.statusCode}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ deleteCoupon error: $e');
      ToastUtil.showToast('Failed to delete coupon. Please try again.');
      return false;
    }
  }
}
