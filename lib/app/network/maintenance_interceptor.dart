import 'package:book_store_app/app/services/maintenance_service.dart';
import 'package:dio/dio.dart';

/// Any call can answer 503 `{maintenanceMode, scope, title, message, endsAt}`
/// (docs §3). Record it app-wide, then pass the error on so the calling screen
/// still leaves its loading state.
class MaintenanceInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final res = err.response;
    if (res?.statusCode == 503 && res?.data is Map<String, dynamic>) {
      final body = res!.data as Map<String, dynamic>;
      if (body['maintenanceMode'] == true) {
        MaintenanceService.to.reportFrom503(body);
      }
    }
    handler.next(err);
  }
}
