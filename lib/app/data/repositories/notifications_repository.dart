import 'package:book_store_app/app/data/models/common_models/notification_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Notification inbox + device-token registry + preferences —
/// `solvexo-api`'s `api/notifications/*` (`NotificationsController`).
class NotificationsRepository {
  final BaseClient _client = BaseClient();

  Future<({List<NotificationModel> items, int total, int unreadCount})> list({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.notifications,
        requiresAuth: true,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (unreadOnly) 'unreadOnly': 'true',
        },
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final items = (data['items'] as List? ?? [])
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return (
          items: items,
          total: data['total'] as int? ?? items.length,
          unreadCount: data['unreadCount'] as int? ?? 0,
        );
      }
      return (items: <NotificationModel>[], total: 0, unreadCount: 0);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (items: <NotificationModel>[], total: 0, unreadCount: 0);
    } catch (e) {
      debugPrint('❌ list notifications error: $e');
      return (items: <NotificationModel>[], total: 0, unreadCount: 0);
    }
  }

  Future<int> unreadCount() async {
    try {
      final response = await _client.get(
        ApiConstants.notificationsUnreadCount,
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return response.data['data']['unreadCount'] as int? ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return 0;
    } catch (e) {
      debugPrint('❌ unreadCount error: $e');
      return 0;
    }
  }

  Future<bool> markRead(String id) async {
    try {
      final response = await _client.patch(ApiConstants.notificationMarkRead(id));
      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ markRead error: $e');
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      final response = await _client.patch(ApiConstants.notificationsReadAll);
      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ markAllRead error: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      final response = await _client.delete(ApiConstants.deleteNotification(id));
      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ deleteNotification error: $e');
      return false;
    }
  }

  Future<bool> registerDeviceToken(String fcmToken, String platform) async {
    try {
      final response = await _client.post(
        ApiConstants.notificationDeviceToken,
        data: {'fcmToken': fcmToken, 'platform': platform},
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ registerDeviceToken error: $e');
      return false;
    }
  }

  Future<bool> removeDeviceToken(String fcmToken) async {
    try {
      final response = await _client.delete(
        ApiConstants.notificationDeviceToken,
        data: {'fcmToken': fcmToken},
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ removeDeviceToken error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPreferences() async {
    try {
      final response = await _client.get(
        ApiConstants.notificationPreferences,
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getPreferences error: $e');
      return null;
    }
  }

  Future<bool> updatePreferences(Map<String, dynamic> prefs) async {
    try {
      final response = await _client.patch(
        ApiConstants.notificationPreferences,
        data: prefs,
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ updatePreferences error: $e');
      return false;
    }
  }
}
