import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// `GET /api/exchange-rate/current` — public, no auth (see backend
/// `ExchangeRateController.getCurrent`). Returns each supported currency's
/// latest rate as "units of that currency per 1 USD".
class ExchangeRateRepository {
  final BaseClient _client = BaseClient();

  Future<Map<String, double>?> getCurrentRates() async {
    try {
      final response = await _client.get(ApiConstants.exchangeRateCurrent);

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final rates = <String, double>{};
        data.forEach((currency, value) {
          if (value is Map && value['ratePerUSD'] != null) {
            rates[currency] = (value['ratePerUSD'] as num).toDouble();
          }
        });
        // USD is the fixed pivot — always 1, even if the backend hasn't
        // seeded a USD row (it special-cases USD the same way, see
        // ExchangeRateService.requireCurrentRate).
        rates['USD'] = 1.0;
        return rates;
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getCurrentRates error: $e');
      return null;
    }
  }
}
