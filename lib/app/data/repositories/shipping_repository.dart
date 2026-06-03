import 'package:book_store_app/app/modules/checkout/models/shipping_options_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ShippingRepository {
  final BaseClient _baseClient = BaseClient();

  Future<List<ShippingZoneModel>> getShippingZones() async {
    try {
      debugPrint('═══════════════════════════════════');
      debugPrint(
        '🚚 GETTING SHIPPING ZONES — ${ApiConstants.getShippingZones}',
      );
      debugPrint('═══════════════════════════════════');

      final response = await _baseClient.get(ApiConstants.getShippingZones);

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      final List<dynamic> data = response.data?['data'] ?? [];
      return data
          .map((e) => ShippingZoneModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('❌ DioException in getShippingZones: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error in getShippingZones: $e');
      rethrow;
    }
  }
}
