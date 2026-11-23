import 'package:book_store_app/app/data/models/finance/earnings_models.dart';
import 'package:book_store_app/app/data/models/finance/finance_dashboard_model.dart';
import 'package:book_store_app/app/data/models/finance/finance_transaction_model.dart';
import 'package:book_store_app/app/data/models/finance/payout_method_model.dart';
import 'package:book_store_app/app/data/models/finance/payout_model.dart';
import 'package:book_store_app/app/data/models/finance/payout_schedule_model.dart';
import 'package:book_store_app/app/data/models/finance/tax_report_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// `src/finance` on the API returns the payload directly — unlike most other
/// modules it does NOT wrap responses in `{success, message, data}` — so every
/// method here parses `response.data` as the payload itself (errors still
/// throw a `DioException` and are handled the usual way).
class SellerFinanceRepository {
  SellerFinanceRepository({BaseClient? client}) : _client = client ?? BaseClient();

  final BaseClient _client;

  /// Hero tiles. Throws on failure so the screen can show error + Retry.
  Future<EarningsSummary> getEarningsSummary(String storeId) async {
    final res = await _client.get(ApiConstants.financeEarningsSummary(storeId), requiresAuth: true);
    return EarningsSummary.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Monthly statement, `month` = 'YYYY-MM'. Throws on failure.
  Future<EarningsStatement> getEarningsStatement(String storeId, String month) async {
    final res = await _client.get(
      ApiConstants.financeEarningsStatement(storeId),
      queryParameters: {'month': month},
      requiresAuth: true,
    );
    return EarningsStatement.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// CSV or PDF bytes + the server's file name
  /// (`attachment; filename="earnings-2026-11-PKR.csv"`).
  Future<({List<int> bytes, String fileName})> downloadEarningsStatement(
    String storeId, {
    required String month,
    required String format,
  }) async {
    final res = await _client.get(
      ApiConstants.financeEarningsStatementDownload(storeId),
      queryParameters: {'format': format, 'month': month},
      requiresAuth: true,
      responseType: ResponseType.bytes,
    );
    final disposition = res.headers.value('content-disposition') ?? '';
    final match = RegExp(r'filename="?([^";]+)"?').firstMatch(disposition);
    return (
      bytes: (res.data as List).cast<int>(),
      fileName: match?.group(1) ?? 'earnings-$month.$format',
    );
  }

  /// Server-side fee for a price (never computed on the device). With
  /// [premiumPercent] (1-50) the answer also has the earnings at the member
  /// price (`premium`). Throws.
  Future<FeeEstimate> getFeeEstimate(String storeId, {required num price, required String type, int? premiumPercent}) async {
    final res = await _client.get(
      ApiConstants.financeFeeEstimate(storeId),
      queryParameters: {'price': price, 'type': type, if (premiumPercent != null) 'premiumPercent': premiumPercent},
      requiresAuth: true,
    );
    return FeeEstimate.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Payout history: GET payouts -> {payouts, total, page, limit, pages}.
  Future<List<PayoutModel>> getPayouts(String storeId, {int page = 1}) async {
    final res = await _client.get(
      ApiConstants.financePayouts(storeId),
      queryParameters: {'page': page},
      requiresAuth: true,
    );
    final body = res.data;
    final list = body is Map ? body['payouts'] : body;
    return (list is List ? list : const [])
        .whereType<Map>()
        .map((m) => PayoutModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<FinanceDashboardModel> getDashboard(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.financeDashboard(storeId), requiresAuth: true);
      return FinanceDashboardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return FinanceDashboardModel.empty;
    } catch (e) {
      debugPrint('❌ getDashboard error: $e');
      return FinanceDashboardModel.empty;
    }
  }

  Future<({List<FinanceTransactionModel> transactions, int total, int page, int pages})> getTransactions(
    String storeId, {
    String? type,
    String? status,
    String? from,
    String? to,
    String? currency,
    int page = 1,
    int limit = 20,
  }) async {
    const empty = (transactions: <FinanceTransactionModel>[], total: 0, page: 1, pages: 1);
    try {
      final response = await _client.get(
        ApiConstants.financeTransactions(storeId),
        queryParameters: {
          if (type != null) 'type': type,
          if (status != null) 'status': status,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          if (currency != null && currency.isNotEmpty) 'currency': currency,
          'page': page,
          'limit': limit,
        },
        requiresAuth: true,
      );
      final data = response.data as Map<String, dynamic>;
      final transactions = (data['transactions'] as List).cast<Map<String, dynamic>>().map(FinanceTransactionModel.fromJson).toList();
      return (
        transactions: transactions,
        total: data['total'] as int? ?? transactions.length,
        page: data['page'] as int? ?? page,
        pages: data['pages'] as int? ?? 1,
      );
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return empty;
    } catch (e) {
      debugPrint('❌ getTransactions error: $e');
      return empty;
    }
  }

  /// Returns the raw CSV text, or null on failure.
  Future<String?> exportTransactionsCsv(String storeId, {String? type, String? status, String? from, String? to, String? currency}) async {
    try {
      final response = await _client.get(
        ApiConstants.financeTransactionsExport(storeId),
        queryParameters: {
          if (type != null) 'type': type,
          if (status != null) 'status': status,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          if (currency != null) 'currency': currency,
        },
        requiresAuth: true,
      );
      return response.data.toString();
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ exportTransactionsCsv error: $e');
      ToastUtil.showToast('Failed to export transactions.');
      return null;
    }
  }

  Future<PayoutModel?> requestPayout(String storeId, {required double amount, required String payoutMethodId, String? notes}) async {
    try {
      final response = await _client.post(
        ApiConstants.financePayoutRequest(storeId),
        data: {'amount': amount, 'payoutMethodId': payoutMethodId, if (notes != null && notes.isNotEmpty) 'notes': notes},
        requiresAuth: true,
      );
      return PayoutModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ requestPayout error: $e');
      ToastUtil.showToast('Failed to request payout.');
      return null;
    }
  }

  Future<List<PayoutMethodModel>> getPayoutMethods(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.financePayoutMethods(storeId), requiresAuth: true);
      return (response.data as List).cast<Map<String, dynamic>>().map(PayoutMethodModel.fromJson).toList();
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getPayoutMethods error: $e');
      return [];
    }
  }

  Future<PayoutMethodModel?> addPayoutMethod(
    String storeId, {
    required String type,
    String? currency,
    String? bankName,
    String? accountHolder,
    String? accountNumber,
    String? routingNumber,
    String? externalAccountId,
    bool setAsDefault = false,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.financePayoutMethods(storeId),
        data: {
          'type': type,
          if (currency != null && currency.isNotEmpty) 'currency': currency,
          if (bankName != null && bankName.isNotEmpty) 'bankName': bankName,
          if (accountHolder != null && accountHolder.isNotEmpty) 'accountHolder': accountHolder,
          if (accountNumber != null && accountNumber.isNotEmpty) 'accountNumber': accountNumber,
          if (routingNumber != null && routingNumber.isNotEmpty) 'routingNumber': routingNumber,
          if (externalAccountId != null && externalAccountId.isNotEmpty) 'externalAccountId': externalAccountId,
          'setAsDefault': setAsDefault,
        },
        requiresAuth: true,
      );
      return PayoutMethodModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ addPayoutMethod error: $e');
      ToastUtil.showToast('Failed to add payout method.');
      return null;
    }
  }

  Future<PayoutMethodModel?> updatePayoutMethod(
    String storeId,
    String methodId, {
    required String type,
    String? currency,
    String? bankName,
    String? accountHolder,
    String? accountNumber,
    String? routingNumber,
    String? externalAccountId,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.financePayoutMethodById(storeId, methodId),
        // Backend 5adba44 validates this PATCH with the full add DTO, so
        // `type` is required (400 "type must be one of the following
        // values: ") even though the service keeps the method's own type.
        data: {
          'type': type,
          if (currency != null) 'currency': currency,
          if (bankName != null) 'bankName': bankName,
          if (accountHolder != null) 'accountHolder': accountHolder,
          if (accountNumber != null && accountNumber.isNotEmpty) 'accountNumber': accountNumber,
          if (routingNumber != null) 'routingNumber': routingNumber,
          if (externalAccountId != null) 'externalAccountId': externalAccountId,
        },
        requiresAuth: true,
      );
      return PayoutMethodModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updatePayoutMethod error: $e');
      ToastUtil.showToast('Failed to update payout method.');
      return null;
    }
  }

  Future<bool> deletePayoutMethod(String storeId, String methodId) async {
    try {
      await _client.delete(ApiConstants.financePayoutMethodById(storeId, methodId), requiresAuth: true);
      return true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ deletePayoutMethod error: $e');
      ToastUtil.showToast('Failed to delete payout method.');
      return false;
    }
  }

  Future<bool> setDefaultPayoutMethod(String storeId, String methodId) async {
    try {
      await _client.patch(ApiConstants.financeSetDefaultPayoutMethod(storeId, methodId), requiresAuth: true);
      return true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ setDefaultPayoutMethod error: $e');
      ToastUtil.showToast('Failed to set default payout method.');
      return false;
    }
  }

  Future<PayoutScheduleModel> getPayoutSchedule(String storeId, {required String currency}) async {
    try {
      final response = await _client.get(
        ApiConstants.financePayoutSchedule(storeId),
        // No currency = the store's own currency on the server (backend fix #11).
        queryParameters: {if (currency.isNotEmpty) 'currency': currency},
        requiresAuth: true,
      );
      return PayoutScheduleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return PayoutScheduleModel.empty;
    } catch (e) {
      debugPrint('❌ getPayoutSchedule error: $e');
      return PayoutScheduleModel.empty;
    }
  }

  Future<PayoutScheduleModel?> updatePayoutSchedule(
    String storeId, {
    String? currency,
    String? frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    double? minimumAmount,
    bool? isEnabled,
    String? defaultPayoutMethodId,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.financePayoutSchedule(storeId),
        data: {
          if (currency != null) 'currency': currency,
          if (frequency != null) 'frequency': frequency,
          if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
          if (dayOfMonth != null) 'dayOfMonth': dayOfMonth,
          if (minimumAmount != null) 'minimumAmount': minimumAmount,
          if (isEnabled != null) 'isEnabled': isEnabled,
          if (defaultPayoutMethodId != null) 'defaultPayoutMethodId': defaultPayoutMethodId,
        },
        requiresAuth: true,
      );
      return PayoutScheduleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updatePayoutSchedule error: $e');
      ToastUtil.showToast('Failed to update payout schedule.');
      return null;
    }
  }

  Future<List<TaxReportModel>> getTaxReports(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.financeTaxReports(storeId), requiresAuth: true);
      return (response.data as List).cast<Map<String, dynamic>>().map(TaxReportModel.fromJson).toList();
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getTaxReports error: $e');
      return [];
    }
  }

  Future<TaxReportModel?> generateTaxReport(String storeId, {required int year, required String period, String? currency}) async {
    try {
      final response = await _client.post(
        ApiConstants.financeTaxReportsGenerate(storeId),
        queryParameters: {'year': year, 'period': period, if (currency != null) 'currency': currency},
        requiresAuth: true,
      );
      return TaxReportModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ generateTaxReport error: $e');
      ToastUtil.showToast('Failed to generate tax report.');
      return null;
    }
  }
}
