import 'dart:io';
import 'package:book_store_app/app/modules/refund_request/models/refund_request_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RefundRepository {
  final BaseClient _baseClient = BaseClient();

  /// Create Refund Request
  Future<RefundModel?> createRefund({
    required String orderId,
    required List<String> productIds, // added
    required String reason,
    required String description,
    required List<File> attachments,
  }) async {
    try {
      debugPrint('🔄 Creating refund for order: $orderId');
      final Map<String, dynamic> formMap = {
        "orderId": orderId,
        "reason": reason,
        "message": description,
        "images": await Future.wait(
          attachments.map(
            (file) => MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        ),
      };

      // Add productIds correctly
      for (int i = 0; i < productIds.length; i++) {
        formMap["productIds[$i]"] = productIds[i];
      }

      FormData formData = FormData.fromMap(formMap);

      // FormData formData = FormData.fromMap({
      //   "orderId": orderId,
      //   "productIds": productIds, // send all product IDs
      //   "reason": reason,
      //   "message": description,
      //   "images": await Future.wait(
      //     attachments.map(
      //       (file) => MultipartFile.fromFile(
      //         file.path,
      //         filename: file.path.split('/').last,
      //       ),
      //     ),
      //   ),
      // });

      final response = await _baseClient.post(
        ApiConstants.refunds,
        data: formData,
      );

      debugPrint('✅ Create Refund Response: ${response.data}');

      if (response.statusCode == 201 && response.data['success'] == true) {
        return RefundModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      debugPrint('❌ Status Code: ${e.response?.statusCode}');
      debugPrint('❌ Response Data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Create Refund error: $e');
      rethrow;
    }
  }

  /// Get My Refunds
  Future<List<RefundModel>> getMyRefunds() async {
    try {
      debugPrint('🔄 Fetching my refunds...');

      final response = await _baseClient.get(ApiConstants.myRefunds);

      debugPrint('✅ My Refunds Response: ${response.data}');

      if (response.data['success'] == true) {
        final List data = response.data['data'];
        return data.map((e) => RefundModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Get My Refunds error: $e');
      rethrow;
    }
  }

  /// Get Refund By ID
  Future<RefundModel?> getRefundById(String refundId) async {
    try {
      debugPrint('🔄 Fetching refund: $refundId');

      final response = await _baseClient.get(
        '${ApiConstants.refunds}/$refundId',
      );

      debugPrint('✅ Refund Details Response: ${response.data}');

      if (response.data['success'] == true) {
        return RefundModel.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Get Refund error: $e');
      rethrow;
    }
  }

  /// Cancel Refund Request
  Future<bool> cancelRefund(String refundId) async {
    try {
      debugPrint('🔄 Cancelling refund: $refundId');

      final response = await _baseClient.put(
        '${ApiConstants.refunds}/$refundId/cancel',
      );

      debugPrint('✅ Cancel Refund Response: ${response.data}');

      return response.data['success'] == true;
    } catch (e) {
      debugPrint('❌ Cancel Refund error: $e');
      rethrow;
    }
  }
}
