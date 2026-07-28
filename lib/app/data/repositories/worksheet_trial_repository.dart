import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Standalone, unauthenticated worksheet-builder trial — deliberately
/// separate from the seller-only `AiStudioRepository` (no storeId/credits/
/// accept flow here). Backend: `POST /api/public/worksheet-builder/try-free`,
/// rate-limited to 3/hour server-side; failures come back as
/// `{success:false, errorCode, message}` at 503/422 — [message] is surfaced
/// as-is, no special handling per error code.
class WorksheetTrialRepository {
  final BaseClient _client = BaseClient();

  Future<({bool success, Map<String, dynamic>? output, String? message})> tryFree({
    required String subject,
    required String gradeLevel,
    required List<String> topics,
    required int questionCount,
    required bool includeAnswerKey,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.publicWorksheetTrial,
        data: {
          'subject': subject,
          'gradeLevel': gradeLevel,
          'topics': topics,
          'questionCount': questionCount,
          'includeAnswerKey': includeAnswerKey,
        },
        requiresAuth: false,
      );

      if (response.data['success'] == true) {
        return (
          success: true,
          output: response.data['data'] as Map<String, dynamic>,
          message: null,
        );
      }
      return (
        success: false,
        output: null,
        message: response.data['message'] as String?,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] as String? : null;
      return (
        success: false,
        output: null,
        message: message ?? 'Something went wrong. Please try again.',
      );
    } catch (e) {
      debugPrint('❌ WorksheetTrialRepository.tryFree error: $e');
      return (
        success: false,
        output: null,
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
