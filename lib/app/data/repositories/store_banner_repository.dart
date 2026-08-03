import 'dart:io';

import 'package:book_store_app/app/data/models/activity_log/activity_log_model.dart';
import 'package:book_store_app/app/data/models/store_banner/store_banner_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A seller's free, self-managed storefront hero carousel — `solvexo-api`'s
/// `src/store-banner` (`StoreBannerController` + `PublicStoreBannerController`).
/// Distinct from [PromotionsRepository]'s paid, shared placements.
class StoreBannerRepository {
  final BaseClient _client = BaseClient();

  // ─── GET /api/store-banner/:storeId — seller, all statuses ─────────────────

  Future<List<StoreBannerModel>> list(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.storeBanners(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List? ?? [];
        return list.map((e) => StoreBannerModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return const [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return const [];
    } catch (e) {
      debugPrint('❌ store banner list error: $e');
      return const [];
    }
  }

  // ─── POST /api/store-banner/:storeId (multipart) ───────────────────────────

  Future<({bool success, StoreBannerModel? data, String? message})> create({
    required String storeId,
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
    try {
      final formData = FormData.fromMap({
        'type': type,
        'linkType': linkType,
        if (ctaLabel != null && ctaLabel.isNotEmpty) 'ctaLabel': ctaLabel,
        if (linkTarget != null && linkTarget.isNotEmpty) 'linkTarget': linkTarget,
        if (order != null) 'order': order.toString(),
        if (priority != null) 'priority': priority.toString(),
        if (startAt != null) 'startAt': startAt.toIso8601String(),
        if (endAt != null) 'endAt': endAt.toIso8601String(),
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        if (mobileFile != null)
          'mobileFile': await MultipartFile.fromFile(mobileFile.path, filename: mobileFile.path.split('/').last),
      });

      final response = await _client.post(ApiConstants.storeBanners(storeId), data: formData, requiresAuth: true);

      if (response.data['success'] == true) {
        return (
          success: true,
          data: StoreBannerModel.fromJson(response.data['data'] as Map<String, dynamic>),
          message: response.data['message'] as String?,
        );
      }
      return (success: false, data: null, message: response.data['message'] as String?);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? data['message'] as String? : null;
      return (success: false, data: null, message: msg ?? 'Failed to create store banner');
    } catch (e) {
      debugPrint('❌ store banner create error: $e');
      return (success: false, data: null, message: 'Failed to create store banner');
    }
  }

  // ─── PATCH /api/store-banner/:storeId/:bannerId ────────────────────────────
  // JSON-only update (no new image) — re-uploading a creative isn't supported
  // by this endpoint server-side; sellers delete + recreate for that.

  Future<({bool success, StoreBannerModel? data, String? message})> update({
    required String storeId,
    required String bannerId,
    String? type,
    String? ctaLabel,
    String? linkType,
    String? linkTarget,
    int? order,
    int? priority,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.storeBannerById(storeId, bannerId),
        data: {
          if (type != null) 'type': type,
          if (ctaLabel != null) 'ctaLabel': ctaLabel,
          if (linkType != null) 'linkType': linkType,
          if (linkTarget != null) 'linkTarget': linkTarget,
          if (order != null) 'order': order,
          if (priority != null) 'priority': priority,
          if (startAt != null) 'startAt': startAt.toIso8601String(),
          if (endAt != null) 'endAt': endAt.toIso8601String(),
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return (
          success: true,
          data: StoreBannerModel.fromJson(response.data['data'] as Map<String, dynamic>),
          message: response.data['message'] as String?,
        );
      }
      return (success: false, data: null, message: response.data['message'] as String?);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? data['message'] as String? : null;
      return (success: false, data: null, message: msg ?? 'Failed to update store banner');
    } catch (e) {
      debugPrint('❌ store banner update error: $e');
      return (success: false, data: null, message: 'Failed to update store banner');
    }
  }

  // ─── PATCH .../pause & .../resume ───────────────────────────────────────────

  Future<bool> pause(String storeId, String bannerId) => _patchStatus(ApiConstants.storeBannerPause(storeId, bannerId));
  Future<bool> resume(String storeId, String bannerId) => _patchStatus(ApiConstants.storeBannerResume(storeId, bannerId));

  Future<bool> _patchStatus(String url) async {
    try {
      final response = await _client.patch(url, requiresAuth: true);
      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ store banner status change error: $e');
      return false;
    }
  }

  // ─── DELETE /api/store-banner/:storeId/:bannerId ───────────────────────────

  Future<bool> delete(String storeId, String bannerId) async {
    try {
      final response = await _client.delete(ApiConstants.storeBannerById(storeId, bannerId), requiresAuth: true);
      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ store banner delete error: $e');
      return false;
    }
  }

  // ─── GET /api/store-banner/:storeId/:bannerId/timeline ─────────────────────

  Future<List<ActivityLogModel>> timeline(String storeId, String bannerId) async {
    try {
      final response = await _client.get(ApiConstants.storeBannerTimeline(storeId, bannerId), requiresAuth: true);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List? ?? [];
        return list.map((e) => ActivityLogModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return const [];
    } catch (e) {
      debugPrint('❌ store banner timeline error: $e');
      return const [];
    }
  }

  // ─── GET /api/public/store-banners/:storeId — buyer, active only ───────────

  Future<List<StoreBannerModel>> getPublicBanners(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.publicStoreBanners(storeId));
      if (response.data['success'] == true) {
        final list = response.data['data'] as List? ?? [];
        return list.map((e) => StoreBannerModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return const [];
    } catch (e) {
      debugPrint('❌ public store banners error: $e');
      return const [];
    }
  }
}
