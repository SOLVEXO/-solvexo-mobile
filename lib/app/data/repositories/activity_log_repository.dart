import 'package:book_store_app/app/data/models/activity_log/activity_log_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

typedef ActivityLogPage = ({List<ActivityLogModel> items, int total, int totalPages, bool hasMore});

class ActivityLogRepository {
  final BaseClient _client = BaseClient();

  dynamic _data(Response response) {
    final raw = response.data;
    if (raw is Map<String, dynamic> && raw['success'] == true) return raw['data'];
    return null;
  }

  ActivityLogPage _emptyPage() => (items: <ActivityLogModel>[], total: 0, totalPages: 0, hasMore: false);

  void _logDioError(String tag, DioException e) {
    debugPrint('❌ $tag DioException: ${e.response?.statusCode}');
    debugPrint('   Response: ${e.response?.data}');
  }

  Future<ActivityLogPage> getLogs({
    required String storeId,
    int page = 1,
    int limit = 20,
    String? category,
    String? actorId,
    String? action,
    String? search,
    String? from,
    String? to,
  }) async {
    try {
      final res = await _client.get(
        ApiConstants.activityLog(storeId),
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null && category.isNotEmpty) 'category': category,
          if (actorId != null && actorId.isNotEmpty) 'actorId': actorId,
          if (action != null && action.isNotEmpty) 'action': action,
          if (search != null && search.isNotEmpty) 'search': search,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
        requiresAuth: true,
      );
      final data = _data(res) as Map<String, dynamic>?;
      if (data == null) return _emptyPage();
      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
      final currentPage = pagination['page'] as int? ?? 1;
      final totalPages = pagination['totalPages'] as int? ?? 1;
      final items = (data['logs'] as List<dynamic>?)
              ?.map((e) => ActivityLogModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <ActivityLogModel>[];
      return (
        items: items,
        total: pagination['total'] as int? ?? items.length,
        totalPages: totalPages,
        hasMore: currentPage < totalPages,
      );
    } on DioException catch (e) {
      _logDioError('getLogs', e);
      DioExceptionHandler.handleDioException(e);
      return _emptyPage();
    } catch (e) {
      debugPrint('❌ getLogs: $e');
      ToastUtil.showToast('Failed to load activity log.');
      return _emptyPage();
    }
  }

  Future<ActivityLogStatsModel?> getStats(String storeId) async {
    try {
      final res = await _client.get(ApiConstants.activityLogStats(storeId), requiresAuth: true);
      final data = _data(res) as Map<String, dynamic>?;
      return data != null ? ActivityLogStatsModel.fromJson(data) : null;
    } on DioException catch (e) {
      _logDioError('getStats', e);
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getStats: $e');
      return null;
    }
  }

  /// Raw CSV bytes for sharing/saving; null on failure. Mirrors
  /// `PosRepository.exportDailyReportCsv` (same raw, non-enveloped response).
  Future<List<int>?> exportCsv(
    String storeId, {
    String? category,
    String? from,
    String? to,
  }) async {
    try {
      final res = await _client.get(
        ApiConstants.activityLogExport(storeId),
        queryParameters: {
          if (category != null && category.isNotEmpty) 'category': category,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
        requiresAuth: true,
        responseType: ResponseType.bytes,
      );
      return res.data as List<int>;
    } on DioException catch (e) {
      _logDioError('exportCsv', e);
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ exportCsv: $e');
      ToastUtil.showToast('Failed to export activity log.');
      return null;
    }
  }
}
