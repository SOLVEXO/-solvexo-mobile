import 'package:book_store_app/app/data/models/store_verification_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Seller business/KYC verification — `api/store/:storeId/verification*`.
class StoreVerificationRepository {
  final BaseClient _client = BaseClient();

  // ─── GET /api/store/:storeId/verification ─────────────────────────────────

  Future<StoreVerificationModel?> getVerification(String storeId) async {
    try {
      final response = await _client.get(
        ApiConstants.storeVerification(storeId),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return StoreVerificationModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getVerification error: $e');
      return null;
    }
  }

  // ─── PATCH /api/store/:storeId/verification ───────────────────────────────
  // Draft save — only allowed while verificationStatus is
  // 'not_started'/'rejected'; otherwise the backend 400s with its own
  // "can no longer be edited" message, which we surface here verbatim via toast.

  Future<StoreVerificationModel?> updateVerification(
    String storeId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.patch(
        ApiConstants.storeVerification(storeId),
        data: body,
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return StoreVerificationModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      ToastUtil.showToast(
        response.data['message'] as String? ??
            'Failed to save verification details.',
      );
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateVerification error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return null;
    }
  }

  // ─── POST /api/store/:storeId/verification/documents ──────────────────────
  // Thin wrapper — attaches/replaces a single document by type.

  Future<bool> attachDocument(
    String storeId, {
    required String type,
    required String publicId,
    required String resourceType,
    required String fileName,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.storeVerificationDocuments(storeId),
        data: {
          'type': type,
          'publicId': publicId,
          'resourceType': resourceType,
          'fileName': fileName,
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) return true;
      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to attach document.',
      );
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ attachDocument error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }

  // ─── POST /api/store/:storeId/verification/submit ─────────────────────────
  // Surfaces the backend's exact validation messages (missing fields / docs).

  Future<bool> submitVerification(String storeId) async {
    try {
      final response = await _client.post(
        ApiConstants.storeVerificationSubmit(storeId),
        requiresAuth: true,
      );
      if (response.data['success'] == true) return true;
      ToastUtil.showToast(
        response.data['message'] as String? ??
            'Failed to submit for review.',
      );
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ submitVerification error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }
}
