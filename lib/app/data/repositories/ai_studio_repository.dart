import 'package:book_store_app/app/data/models/ai_studio/ai_credits_overview_model.dart';
import 'package:book_store_app/app/data/models/ai_studio/ai_generate_response.dart';
import 'package:book_store_app/app/data/models/ai_studio/ai_generation_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Seller-only AI Studio — six generate tools + credits/history, backed by
/// `src/ai-studio` on the API. Every mutating call sends an Idempotency-Key
/// (same pattern as [PlatformPlansRepository]) so a retry never double-charges
/// credits.
class AiStudioRepository {
  final BaseClient _client = BaseClient();
  static const _uuid = Uuid();

  Map<String, dynamic> get _idempotencyHeader => {'Idempotency-Key': _uuid.v4()};

  // ── credits & history ─────────────────────────────────────────────────────

  Future<AiCreditsOverviewModel?> getCredits(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.aiStudioCredits(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return AiCreditsOverviewModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getCredits error: $e');
      return null;
    }
  }

  Future<({List<AiGenerationModel> items, int total})> getGenerations(
    String storeId, {
    String? toolType,
    String? sessionId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.aiStudioGenerations(storeId),
        requiresAuth: true,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (toolType != null) 'toolType': toolType,
          if (sessionId != null) 'sessionId': sessionId,
        },
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return (
          items: (data['items'] as List? ?? [])
              .map((e) => AiGenerationModel.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: (data['total'] as num?)?.toInt() ?? 0,
        );
      }
      return (items: <AiGenerationModel>[], total: 0);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (items: <AiGenerationModel>[], total: 0);
    } catch (e) {
      debugPrint('❌ getGenerations error: $e');
      return (items: <AiGenerationModel>[], total: 0);
    }
  }

  Future<AiGenerationModel?> getGeneration(String storeId, String generationId) async {
    try {
      final response = await _client.get(
        ApiConstants.aiStudioGeneration(storeId, generationId),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return AiGenerationModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getGeneration error: $e');
      return null;
    }
  }

  /// "Use This" — accept the generation, optionally writing its output onto
  /// the linked product.
  Future<AiGenerationModel?> acceptGeneration(
    String storeId,
    String generationId, {
    bool applyToProduct = false,
    String? productId,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.aiStudioAcceptGeneration(storeId, generationId),
        data: {
          if (applyToProduct) 'applyToProduct': true,
          if (productId != null) 'productId': productId,
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return AiGenerationModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ acceptGeneration error: $e');
      return null;
    }
  }

  // ── the 6 tools ────────────────────────────────────────────────────────────

  Future<AiGenerateOutcome<AiGenerateResponse>> generateListing(
    String storeId, {
    required String productType,
    required List<String> keywords,
    required String tone,
    String? productId,
    String? regenerateFromId,
  }) {
    return _generate(
      ApiConstants.aiStudioListingWriter(storeId),
      {
        'productType': productType,
        'keywords': keywords,
        'tone': tone,
        if (productId != null) 'productId': productId,
        if (regenerateFromId != null) 'regenerateFromId': regenerateFromId,
      },
    );
  }

  Future<AiGenerateOutcome<AiGenerateResponse>> generateSeo(
    String storeId, {
    String? productId,
    String? title,
    String? description,
    List<String>? currentTags,
    String? regenerateFromId,
  }) {
    return _generate(
      ApiConstants.aiStudioSeoBooster(storeId),
      {
        if (productId != null) 'productId': productId,
        if (title != null) 'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        if (currentTags != null) 'currentTags': currentTags,
        if (regenerateFromId != null) 'regenerateFromId': regenerateFromId,
      },
    );
  }

  Future<AiGenerateOutcome<AiGenerateResponse>> generateEmail(
    String storeId, {
    required String campaignGoal,
    required String tone,
    List<String>? productIds,
    String? regenerateFromId,
  }) {
    return _generate(
      ApiConstants.aiStudioEmailCampaigns(storeId),
      {
        'campaignGoal': campaignGoal,
        'tone': tone,
        if (productIds != null && productIds.isNotEmpty) 'productIds': productIds,
        if (regenerateFromId != null) 'regenerateFromId': regenerateFromId,
      },
    );
  }

  Future<AiGenerateOutcome<AiGenerateResponse>> generateWorksheet(
    String storeId, {
    required String subject,
    required String gradeLevel,
    required List<String> topics,
    required int questionCount,
    required bool includeAnswerKey,
    String? regenerateFromId,
  }) {
    return _generate(
      ApiConstants.aiStudioWorksheetBuilder(storeId),
      {
        'subject': subject,
        'gradeLevel': gradeLevel,
        'topics': topics,
        'questionCount': questionCount,
        'includeAnswerKey': includeAnswerKey,
        if (regenerateFromId != null) 'regenerateFromId': regenerateFromId,
      },
    );
  }

  Future<AiGenerateOutcome<AiGenerateResponse>> generatePrice(
    String storeId, {
    String? productId,
    String? categoryId,
    String? attributes,
    String? regenerateFromId,
  }) {
    return _generate(
      ApiConstants.aiStudioPriceOptimizer(storeId),
      {
        if (productId != null) 'productId': productId,
        if (categoryId != null) 'categoryId': categoryId,
        if (attributes != null && attributes.isNotEmpty) 'attributes': attributes,
        if (regenerateFromId != null) 'regenerateFromId': regenerateFromId,
      },
    );
  }

  /// Async — returns a jobId immediately; poll [getImageJob] for the result.
  Future<AiGenerateOutcome<AiImageJobStart>> startImageEnhance(
    String storeId, {
    required String imageUrl,
    required String enhancementType,
    String? regenerateFromId,
  }) {
    return _post<AiImageJobStart>(
      ApiConstants.aiStudioImageEnhancerGenerate(storeId),
      {
        'imageUrl': imageUrl,
        'enhancementType': enhancementType,
        if (regenerateFromId != null) 'regenerateFromId': regenerateFromId,
      },
      AiImageJobStart.fromJson,
    );
  }

  Future<AiImageJobModel?> getImageJob(String storeId, String jobId) async {
    try {
      final response = await _client.get(
        ApiConstants.aiStudioImageEnhancerJob(storeId, jobId),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return AiImageJobModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e, showToast: false);
      return null;
    } catch (e) {
      debugPrint('❌ getImageJob error: $e');
      return null;
    }
  }

  // ── internals ──────────────────────────────────────────────────────────────

  Future<AiGenerateOutcome<AiGenerateResponse>> _generate(String url, Map<String, dynamic> data) {
    return _post<AiGenerateResponse>(url, data, AiGenerateResponse.fromJson);
  }

  /// Shared POST + error-shape handling for every generate/start-job call.
  /// Maps the backend's `402 INSUFFICIENT_AI_CREDITS` and `503`/`422` error
  /// envelopes onto [AiGenerateOutcome] instead of showing a generic toast —
  /// callers decide what "insufficient credits" or "retryable" means in UI.
  Future<AiGenerateOutcome<T>> _post<T>(
    String url,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) parse,
  ) async {
    try {
      final response = await _client.post(
        url,
        data: data,
        requiresAuth: true,
        headers: _idempotencyHeader,
      );
      if (response.data['success'] == true) {
        return AiGenerateOutcome(data: parse(response.data['data'] as Map<String, dynamic>));
      }
      return AiGenerateOutcome(message: response.data['message'] as String? ?? 'Generation failed.');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final errorCode = body is Map ? body['errorCode'] as String? : null;
      final message = body is Map ? body['message'] as String? : null;
      final innerData = body is Map ? body['data'] as Map? : null;

      if (status == 402 || errorCode == 'INSUFFICIENT_AI_CREDITS') {
        return AiGenerateOutcome(
          insufficientCredits: true,
          requiredCredits: (innerData?['required'] as num?)?.toInt(),
          currentBalance: (innerData?['balance'] as num?)?.toInt(),
          message: message ?? 'Not enough AI credits for this generation.',
        );
      }

      final retryable = status == 503 || innerData?['retryable'] == true;
      // Insufficient-credits already has its own dedicated UI — everything
      // else still shows the generic toast so failures are never silent.
      DioExceptionHandler.handleDioException(e);
      return AiGenerateOutcome(retryable: retryable, message: message);
    } catch (e) {
      debugPrint('❌ AI Studio generate error: $e');
      return const AiGenerateOutcome(message: 'Something went wrong. Please try again.');
    }
  }
}
