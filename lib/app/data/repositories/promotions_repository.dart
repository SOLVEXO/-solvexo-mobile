import 'dart:io';

import 'package:book_store_app/app/data/models/promotions/promotion_analytics_model.dart';
import 'package:book_store_app/app/data/models/promotions/promotion_price_breakdown_model.dart';
import 'package:book_store_app/app/data/models/promotions/promotion_request_model.dart';
import 'package:book_store_app/app/data/models/activity_log/activity_log_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Seller-paid ad-placement requests — `solvexo-api`'s `src/promotions`
/// (`PromotionsController` + `PublicPromotionsController`). Gated server-side
/// behind the `promotions` feature flag and `maxActivePromotions` entitlement
/// — both surface as backend error messages rather than being duplicated
/// client-side (see `PromotionsRepository.create`'s error passthrough).
class PromotionsRepository {
  final BaseClient _client = BaseClient();
  static const _uuid = Uuid();

  Map<String, dynamic> get _idempotencyHeader => {'Idempotency-Key': _uuid.v4()};

  // ─── GET /api/promotions/preview-price ─────────────────────────────────────

  Future<PromotionPriceBreakdownModel?> previewPrice({
    required String storeId,
    required String placement,
    required DateTime startAt,
    required DateTime endAt,
    bool isPeak = false,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.promotionsPreviewPrice,
        queryParameters: {
          'storeId': storeId,
          'placement': placement,
          'startAt': startAt.toIso8601String(),
          'endAt': endAt.toIso8601String(),
          'isPeak': isPeak.toString(),
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return PromotionPriceBreakdownModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ previewPrice error: $e');
      return null;
    }
  }

  // ─── GET /api/promotions/:storeId ───────────────────────────────────────────

  Future<List<PromotionRequestModel>> list(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.promotionsList(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List? ?? [];
        return list.map((e) => PromotionRequestModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return const [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return const [];
    } catch (e) {
      debugPrint('❌ promotions list error: $e');
      return const [];
    }
  }

  // ─── GET /api/promotions/:storeId/analytics ────────────────────────────────

  Future<PromotionAnalyticsModel> getAnalytics(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.promotionsAnalytics(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return PromotionAnalyticsModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return PromotionAnalyticsModel.empty;
    } catch (e) {
      debugPrint('❌ promotions analytics error: $e');
      return PromotionAnalyticsModel.empty;
    }
  }

  // ─── POST /api/promotions/:storeId (multipart) ─────────────────────────────

  Future<({bool success, PromotionRequestModel? data, String? message})> create({
    required String storeId,
    required String placement,
    required DateTime startAt,
    required DateTime endAt,
    required File file,
    File? mobileFile,
    String? ctaLabel,
    String linkType = 'external',
    String? linkTarget,
    String? message,
    bool isPeak = false,
  }) async {
    try {
      final formData = FormData.fromMap({
        'placement': placement,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'isPeak': isPeak.toString(),
        'linkType': linkType,
        if (ctaLabel != null && ctaLabel.isNotEmpty) 'ctaLabel': ctaLabel,
        if (linkTarget != null && linkTarget.isNotEmpty) 'linkTarget': linkTarget,
        if (message != null && message.isNotEmpty) 'message': message,
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        if (mobileFile != null)
          'mobileFile': await MultipartFile.fromFile(mobileFile.path, filename: mobileFile.path.split('/').last),
      });

      final response = await _client.post(
        ApiConstants.promotionsCreate(storeId),
        data: formData,
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        return (
          success: true,
          data: PromotionRequestModel.fromJson(response.data['data'] as Map<String, dynamic>),
          message: response.data['message'] as String?,
        );
      }
      return (success: false, data: null, message: response.data['message'] as String?);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? data['message'] as String? : null;
      return (success: false, data: null, message: msg ?? 'Failed to submit promotion request');
    } catch (e) {
      debugPrint('❌ promotions create error: $e');
      return (success: false, data: null, message: 'Failed to submit promotion request');
    }
  }

  // ─── POST /api/promotions/:id/pay ──────────────────────────────────────────

  Future<({bool success, String? clientSecret, double amount, String? message})> pay(String id) async {
    try {
      final response = await _client.post(
        ApiConstants.promotionsPay(id),
        requiresAuth: true,
        headers: _idempotencyHeader,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return (
          success: true,
          clientSecret: data['clientSecret'] as String?,
          amount: (data['amount'] as num?)?.toDouble() ?? 0,
          message: null,
        );
      }
      return (success: false, clientSecret: null, amount: 0.0, message: response.data['message'] as String?);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? data['message'] as String? : null;
      return (success: false, clientSecret: null, amount: 0.0, message: msg ?? 'Failed to start payment');
    } catch (e) {
      debugPrint('❌ promotions pay error: $e');
      return (success: false, clientSecret: null, amount: 0.0, message: 'Failed to start payment');
    }
  }

  // ─── POST /api/promotions/:id/confirm ──────────────────────────────────────

  Future<bool> confirm(String id) async {
    try {
      final response = await _client.post(ApiConstants.promotionsConfirm(id), requiresAuth: true);
      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ promotions confirm error: $e');
      return false;
    }
  }

  // ─── PATCH /api/promotions/:id/cancel ──────────────────────────────────────

  Future<bool> cancel(String id) async {
    try {
      final response = await _client.patch(ApiConstants.promotionsCancel(id), requiresAuth: true);
      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ promotions cancel error: $e');
      return false;
    }
  }

  // ─── GET /api/promotions/:id/timeline ──────────────────────────────────────

  Future<List<ActivityLogModel>> timeline(String id) async {
    try {
      final response = await _client.get(ApiConstants.promotionsTimeline(id), requiresAuth: true);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List? ?? [];
        return list.map((e) => ActivityLogModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return const [];
    } catch (e) {
      debugPrint('❌ promotions timeline error: $e');
      return const [];
    }
  }

  // ─── Public tracking beacons — fire-and-forget, never surfaced to the user ──

  Future<void> trackImpression({required String entityType, required String entityId, String? device}) async {
    try {
      await _client.post(
        ApiConstants.promotionTrackImpression,
        data: {'entityType': entityType, 'entityId': entityId, if (device != null) 'device': device},
        // `OptionalJwtAuthGuard` on the backend — attaching the token when a
        // buyer happens to be logged in costs nothing and never forces a
        // logout (that only fires on a genuine 401 with `requiresAuth`), but
        // still works for guests since the header is simply omitted then.
        requiresAuth: true,
      );
    } catch (_) {
      // Best-effort — impressions are never worth surfacing an error for.
    }
  }

  Future<void> trackClick({required String entityType, required String entityId, String? device}) async {
    try {
      await _client.post(
        ApiConstants.promotionTrackClick,
        data: {'entityType': entityType, 'entityId': entityId, if (device != null) 'device': device},
        requiresAuth: true,
      );
    } catch (_) {
      // Best-effort — a failed click beacon must never block navigation.
    }
  }
}
