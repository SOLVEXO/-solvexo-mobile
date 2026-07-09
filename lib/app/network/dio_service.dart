import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DioService {
  static Future<Dio> getDio({Map<String, dynamic>? headers}) async {
    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    // ✅ DO NOT set Content-Type here — Dio sets it automatically based on
    // the request body type (FormData → multipart/form-data, Map → application/json).
    // Hardcoding it here breaks multipart file uploads.
    dio.options.headers = {
      'Accept': 'application/json',
      'Platform': Util.deviceType(),
      if (headers != null) ...headers,
    };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] ?? false;

          if (requiresAuth) {
            final token = await AppPreferences.getAccessTokenAsync();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          // ✅ Let Dio manage Content-Type — only log, never override here.
          debugPrint("➡️ ${options.method} ${options.path}");
          debugPrint("   Content-Type: ${options.headers['Content-Type']}");
          debugPrint("   Auth Required: $requiresAuth");

          handler.next(options);
        },
        onError: (e, handler) async {
          debugPrint("❌ Dio Error: ${e.response?.statusCode}");
          debugPrint("❌ Response: ${e.response?.data}");

          // Only an expired/invalid *session token* should force a logout —
          // that's a 401 on a request that actually sent one
          // (`requiresAuth: true`). A 401 from an unauthenticated request
          // like login/register just means "wrong credentials" and must be
          // returned to the caller normally, not treated as a session drop.
          final requiresAuth = e.requestOptions.extra['requiresAuth'] ?? false;
          if (e.response?.statusCode == 401 && requiresAuth) {
            // Session expired or token invalid — clear local data and kick to welcome
            await AppPreferences.clearPreference();
            if (Get.currentRoute != Routes.welcome) {
              Get.offAllNamed(Routes.welcome);
            }
          }

          // Always hand the error back down the chain — swallowing it here
          // (via a bare `return`) leaves the original request's Future
          // pending forever, so the calling screen's `finally` block never
          // runs and `isLoading` gets stuck true across navigations.
          handler.next(e);
        },
      ),
    );

    return dio;
  }
}

// import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
// import 'package:book_store_app/utils/util.dart';

// import 'package:dio/dio.dart';
// import 'package:dio_smart_retry/dio_smart_retry.dart';
// import 'package:flutter/material.dart';

// class DioService {
//   static final Dio _dio = Dio();

//   static Future<Dio> getDio({Map? headers}) async {
//     var token = await AppPreferences.getAccessTokenAsync();

//     _dio.options.headers['Authorization'] = "Bearer $token";
//     // _dio.options.headers["x-access-token"] = token;

//     if (headers != null) {
//       if (headers.containsKey("Authorization")) {
//         _dio.options.headers["Authorization"] =
//             "Bearer ${headers["Authorization"]}";
//       }

//       if (headers.containsKey("x-access-token")) {
//         _dio.options.headers["x-access-token"] = headers["x-access-token"];
//       }

//       _dio.options.headers['Content-Type'] = headers["Content-Type"];
//       _dio.options.headers['Cache-Control'] = headers["Cache-Control"];
//     }

//     _dio.options.headers['Accept'] = "application/json";
//     _dio.options.headers['Platform'] = Util.deviceType();

//     _dio.options.connectTimeout = const Duration(seconds: 30);
//     _dio.options.receiveTimeout = const Duration(seconds: 30);

//     ///Basic interceptor
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onResponse: (response, handler) {
//           if (response.statusCode == 401 || response.statusCode == 423) {
//             debugPrint("401 or 423");
//             debugPrint("${response.data} 401 or 423");
//           } else {
//             handler.next(response);
//           }
//         },
//         onError: (error, errorInterceptorHandler) async {
//           if (error.response?.statusCode == 401 ||
//               error.response?.statusCode == 423) {
//             debugPrint("401 or 423");
//             debugPrint("${error.response?.data} 401 or 423");

//             return errorInterceptorHandler.next(error);

//             ///To check if user is already navigated to Login screen
//             // if (gt.Get.currentRoute != Routes.LOGIN) {
//             //   debugPrint("Navigating");
//             //
//             //   // Util.showToast("Session Expired");
//             //   // final MoreViewModel viewModel = Get.put(MoreViewModel());
//             //   //
//             //   // viewModel.logout();
//             //
//             //   var currentLanguage = AppPreferences.getCurrentLanguage();
//             //
//             //   await AppPreferences.clearPreference();
//             //
//             //   await AppPreferences.setCurrentLanguage(language: currentLanguage);
//             //
//             //   ///Updating to old language
//             //   await LocalizationService.updateLanguage(currentLanguage);
//             //
//             //   ///Unsubscribing to topics
//             //   await FcmService().unsubscribeToUserId();
//             //   await FcmService().unSubscribeToTopics();
//             //
//             //   // await _uaePassPlugin.signOut();
//             //
//             //   gt.Get.offAllNamed(Routes.LOGIN);
//             // }
//           } else {
//             errorInterceptorHandler.next(error);
//           }
//         },
//       ),
//     );

//     ///Retry interceptor
//     _dio.interceptors.add(
//       RetryInterceptor(
//         dio: _dio,
//         logPrint: (value) {
//           debugPrint("Retry --> $value");
//         },
//         retries: 0,
//         retryDelays: const [
//           // Duration(seconds: 1), // wait 1 sec before first retry
//           // Duration(seconds: 2), // wait 2 sec before second retry
//           // Duration(seconds: 3), // wait 3 sec before third retry
//         ],
//       ),
//     );

//     // _dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));

//     _dio.options;
//     return _dio;
//   }

//   // static Future<void> refreshToken(token) async {
//   //   NetworkUtil().post(url: NetworkEndpoints.refresh, hasHeader: true, token: token, formData: null).then((dynamic response) {
//   //     return response;
//   //   });
//   // }

//   // static Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
//   //   final options = Options(
//   //     method: requestOptions.method,
//   //     headers: requestOptions.headers,
//   //   );
//   //   return dio.request<dynamic>(requestOptions.path, data: requestOptions.data, queryParameters: requestOptions.queryParameters, options: options);
//   // }
// }
