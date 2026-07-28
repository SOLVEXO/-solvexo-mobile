import 'package:book_store_app/app/data/models/storefront/store_list_item_model.dart';
import 'package:book_store_app/app/data/models/store/platform_stats_model.dart';
import 'package:book_store_app/app/data/models/store/testimonial_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Buyer-facing store discovery — browse/sort all public stores, top stores
/// for the home row, and keyword store search (`solvexo-api`'s
/// `api/store/public*` + `api/search/stores`). Distinct from
/// [StorefrontRepository], which is a single store's own profile/products.
class StoresRepository {
  final BaseClient _client = BaseClient();

  // ─── GET /api/store/public ──────────────────────────────────────────────

  Future<({List<StoreListItemModel> stores, int total, int totalPages, bool hasMore})>
      listStores({
    int page = 1,
    int limit = 20,
    String sort = 'followers', // followers | rating | newest
    String? category,
    String? q,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.publicStores,
        queryParameters: {
          'page': page,
          'limit': limit,
          'sort': sort,
          if (category != null && category != 'all') 'categoryId': category,
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );
      return _parseListResponse(response, page);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (stores: <StoreListItemModel>[], total: 0, totalPages: 0, hasMore: false);
    } catch (e) {
      debugPrint('❌ listStores error: $e');
      return (stores: <StoreListItemModel>[], total: 0, totalPages: 0, hasMore: false);
    }
  }

  // ─── GET /api/search/stores ──────────────────────────────────────────────

  Future<({List<StoreListItemModel> stores, int total, int totalPages, bool hasMore})>
      searchStores({
    required String q,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.searchStores,
        queryParameters: {'q': q, 'page': page, 'limit': limit},
      );
      return _parseListResponse(response, page);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (stores: <StoreListItemModel>[], total: 0, totalPages: 0, hasMore: false);
    } catch (e) {
      debugPrint('❌ searchStores error: $e');
      return (stores: <StoreListItemModel>[], total: 0, totalPages: 0, hasMore: false);
    }
  }

  ({List<StoreListItemModel> stores, int total, int totalPages, bool hasMore})
      _parseListResponse(Response response, int requestedPage) {
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
      final stores = (data['stores'] as List? ?? [])
          .map((s) => StoreListItemModel.fromJson(s as Map<String, dynamic>))
          .toList();
      final currentPage = pagination['page'] as int? ?? requestedPage;
      final totalPages = pagination['totalPages'] as int? ?? 1;
      return (
        stores: stores,
        total: pagination['total'] as int? ?? stores.length,
        totalPages: totalPages,
        hasMore: currentPage < totalPages,
      );
    }
    return (stores: <StoreListItemModel>[], total: 0, totalPages: 0, hasMore: false);
  }

  // ─── GET /api/store/public/top ───────────────────────────────────────────

  Future<List<StoreListItemModel>?> getTopStores({int limit = 10}) async {
    try {
      final response = await _client.get(
        ApiConstants.topStores,
        queryParameters: {'limit': limit},
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return (data['stores'] as List? ?? [])
            .map((s) => StoreListItemModel.fromJson(s as Map<String, dynamic>))
            .toList();
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getTopStores error: $e');
      return null;
    }
  }

  // ─── GET /api/store/public/platform-stats ────────────────────────────────
  // Unauthenticated, server-cached (600s) homepage trust stats. Non-critical
  // content — swallow all errors and return null, matching
  // `BannersRepository`'s philosophy (never a toast, never a crash).

  Future<PlatformStatsModel?> getPlatformStats() async {
    try {
      final response = await _client.get(ApiConstants.publicPlatformStats);
      if (response.data['success'] == true) {
        return PlatformStatsModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ getPlatformStats error: $e');
      return null;
    }
  }

  // ─── GET /api/store/public/testimonials ──────────────────────────────────
  // Unauthenticated, server-cached (600s). Non-critical content — same
  // swallow-all-errors philosophy as above.

  Future<List<TestimonialModel>> getTestimonials({int limit = 6}) async {
    try {
      final response = await _client.get(
        ApiConstants.publicTestimonials(limit: limit),
      );
      final list = response.data['data'] as List? ?? [];
      return List<TestimonialModel>.from(
        list.map((e) => TestimonialModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('❌ getTestimonials error: $e');
      return [];
    }
  }
}
