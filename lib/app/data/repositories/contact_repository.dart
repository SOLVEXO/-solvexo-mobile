import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ContactRepository {
  final BaseClient _client = BaseClient();

  /// Public — no auth. Backend: POST api/contact.
  Future<bool> submit({
    required String name,
    required String email,
    required String topic,
    required String message,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.contactUs,
        data: {
          'name': name,
          'email': email,
          'topic': topic,
          'message': message,
        },
        requiresAuth: false,
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ Contact submit error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }
}
