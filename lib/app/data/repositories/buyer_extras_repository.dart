import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';

/// GET /api/checkout/delivery-info (public, read-only). All values are the
/// server's; null means "not known yet" (no zone / no store setting).
class DeliveryInfo {
  DeliveryInfo(Map j)
      : kind = '${j['kind'] ?? 'physical'}',
        currency = j['currency'] as String?,
        fee = j['fee'] as num?,
        freeShipping = j['freeShipping'] == true,
        cod = j['cod'] == true,
        dispatchDays = j['dispatchDays'] as int?,
        routeDays = j['routeDays'] is Map ? j['routeDays'] as Map : null,
        estimate = j['estimate'];
  final String kind;
  final String? currency;
  final num? fee;
  final bool freeShipping, cod;
  final int? dispatchDays;
  final Map? routeDays;
  final Object? estimate;
  bool get isDigital => kind == 'digital';
}

/// Buy Now line (GET /api/cart/buy-now): one store, server prices; the cart
/// is not touched.
class BuyNowLine {
  BuyNowLine(Map j)
      : name = '${(j['items'] as List?)?.whereType<Map>().firstOrNull?['name'] ?? ''}',
        quantity = ((j['items'] as List?)?.whereType<Map>().firstOrNull?['quantity'] as num?)?.toInt() ?? 1,
        type = '${(j['items'] as List?)?.whereType<Map>().firstOrNull?['type'] ?? 'physical'}',
        storeName = (j['store'] is Map ? j['store']['name'] : null) as String?,
        total = (j['totalAfterDiscount'] ?? j['totalPrice']) as num?,
        currency = j['currency'] as String?;
  final String name, type;
  final int quantity;
  final String? storeName, currency;
  final num? total;
  bool get isPhysical => type != 'digital';
}

class BuyerExtrasRepository {
  BuyerExtrasRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  /// Throws a message string on 4xx (e.g. "Invalid Buy Now selection").
  Future<BuyNowLine> buyNow({required String productId, required String variantId, int quantity = 1}) async {
    try {
      final r = await _client.get(ApiConstants.buyNow,
          queryParameters: {'productId': productId, 'variantId': variantId, 'quantity': '$quantity'}, requiresAuth: true);
      final list = (r.data as Map)['data'] as List;
      return BuyNowLine(list.first as Map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        DioExceptionHandler.handleDioException(e); // seller -> "Switch to your buyer account"
        rethrow;
      }
      throw ApiError.fromDio(e) ?? 'Could not start Buy Now';
    }
  }

  Future<DeliveryInfo> deliveryInfo({required String productId, String? variantId, String? currency, int quantity = 1}) async {
    final r = await _client.get(ApiConstants.deliveryInfo, queryParameters: {
      'productId': productId,
      if (variantId != null && variantId.isNotEmpty) 'variantId': variantId,
      if (currency != null) 'currency': currency,
      'quantity': '$quantity',
    });
    return DeliveryInfo((r.data as Map)['data'] as Map);
  }

  /// Popular terms (GET /api/search/trending) -> [{query, searches}].
  Future<List<String>> trending({int limit = 8}) async {
    final r = await _client.get(ApiConstants.searchTrending, queryParameters: {'limit': limit});
    return ((r.data as Map)['data'] as List? ?? []).whereType<Map>().map((m) => '${m['query'] ?? ''}').where((q) => q.isNotEmpty).toList();
  }

  /// Step 1 of the ZIP flow: a 10-minute token; returns the full download
  /// URL (step 2, `download-zip-file?token=`), or throws the server message.
  Future<String> zipLink(String orderId, String productId) async {
    try {
      final r = await _client.get(ApiConstants.downloadZipLink(orderId, productId), requiresAuth: true);
      final d = (r.data as Map)['data'] as Map;
      final endpoint = '${d['endpoint'] ?? '/api/orders/download-zip-file'}';
      return Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(queryParameters: {'token': '${d['token']}'}).toString();
    } on DioException catch (e) {
      throw ApiError.fromDio(e) ?? 'Could not prepare the ZIP file';
    }
  }
}
