import 'dart:io';
import 'package:book_store_app/app/network/dio_service.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';

class BaseClient {
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool requiresAuth = false,
  }) async {
    final dio = await DioService.getDio();

    debugPrint("GET → $url");

    return dio.get(
      url,
      queryParameters: queryParameters,
      data: data,
      options: Options(
        extra: {
          'requiresAuth': requiresAuth, // 🔥 pass to interceptor
        },
      ),
    );
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true, // ✅ NEW FLAG
  }) async {
    final dio = await DioService.getDio();

    debugPrint("POST → $url");

    return dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        extra: {
          'requiresAuth': requiresAuth, // 🔥 pass to interceptor
        },
      ),
    );
  }

  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = await DioService.getDio();

    debugPrint("PUT → $url");

    return dio.put(url, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = await DioService.getDio();

    debugPrint("DELETE → $url");

    return dio.delete(url, data: data, queryParameters: queryParameters);
  }

  /// multipart upload
  Future<Response> postMultipart(
    String url, {
    required List<File> files,
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
  }) async {
    final dio = await DioService.getDio(
      headers: {'Content-Type': 'multipart/form-data'},
    );

    final map = <String, dynamic>{};

    for (var file in files) {
      final name = file.path.split('/').last;
      final ext = name.split('.').last;

      map[fieldName] = await MultipartFile.fromFile(
        file.path,
        filename: name,
        contentType: MediaType("image", ext),
      );
    }

    if (additionalData != null) map.addAll(additionalData);

    return dio.post(url, data: FormData.fromMap(map));
  }

  /// Streaming POST — for SSE endpoints like Claude API
  Future<ResponseBody> postStream(
    String url, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
  }) async {
    final dio = await DioService.getDio(headers: headers);
    dio.options.responseType = ResponseType.stream;

    final response = await dio.post(url, data: data);
    return response.data as ResponseBody;
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:book_store_app/app/network/dio_service.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:http_parser/http_parser.dart';

// class BaseClient {
//   static final BaseClient _baseClient = BaseClient._internal();

//   factory BaseClient() {
//     return _baseClient;
//   }

//   BaseClient._internal();

//   /// GET request
//   Future<Response> get(
//     String url, {
//     Map<String, dynamic>? headers,
//     Map<String, dynamic>? queryParameters,
//     dynamic data,
//     Function(int value, int progress)? onReceiveProgress,
//     Function? onLoading,
//   }) async {
//     try {
//       debugPrint("URL GET --> $url");
//       debugPrint("Request param GET --> $data");
//       debugPrint("Query Param GET --> $queryParameters");
//       debugPrint("Headers GET --> $headers");

//       var dio = await DioService.getDio(headers: headers);

//       return dio.get(
//         url,
//         data: data,
//         queryParameters: queryParameters,
//         onReceiveProgress: onReceiveProgress,
//       );
//     } on DioException {
//       rethrow;
//     }
//   }

//   /// POST request
//   Future<Response> post(
//     String url, {
//     Map<String, dynamic>? headers,
//     Map<String, dynamic>? queryParameters,
//     Function(int total, int progress)? onSendProgress,
//     Function(int total, int progress)? onReceiveProgress,
//     Function? onLoading,
//     dynamic data,
//   }) async {
//     try {
//       debugPrint("URL POST --> $url");
//       debugPrint("Request param POST --> $data");
//       debugPrint("Headers POST --> $headers");

//       var dio = await DioService.getDio(headers: headers);

//       return dio.post(
//         url,
//         data: data,
//         onReceiveProgress: onReceiveProgress,
//         onSendProgress: onSendProgress,
//         queryParameters: queryParameters,
//       );
//     } on DioException {
//       rethrow;
//     }
//   }

//   /// POST multipart request for file upload
//   Future<Response> postMultipart(
//     String url, {
//     Map<String, dynamic>? queryParameters,
//     Function(int total, int progress)? onSendProgress,
//     Function(int total, int progress)? onReceiveProgress,
//     required List<File> files,
//     String fieldName =
//         'productImages', // Can be 'productImages', 'categoryImage', 'profileImage'
//     Map<String, dynamic>? additionalData,
//   }) async {
//     try {
//       Map<String, dynamic> formDataMap = {};

//       // Add files
//       if (fieldName == 'productImages') {
//         // Multiple files for products
//         List<MultipartFile> multipartFiles = [];
//         for (var file in files) {
//           String fileName = file.path.split('/').last;
//           var fileExt = fileName.split('.').last;
//           multipartFiles.add(
//             await MultipartFile.fromFile(
//               file.path,
//               filename: fileName,
//               contentType: MediaType("image", fileExt),
//             ),
//           );
//         }
//         formDataMap[fieldName] = multipartFiles;
//       } else {
//         // Single file for category or profile
//         if (files.isNotEmpty) {
//           String fileName = files.first.path.split('/').last;
//           var fileExt = fileName.split('.').last;
//           formDataMap[fieldName] = await MultipartFile.fromFile(
//             files.first.path,
//             filename: fileName,
//             contentType: MediaType("image", fileExt),
//           );
//         }
//       }

//       // Add additional data if any
//       if (additionalData != null) {
//         formDataMap.addAll(additionalData);
//       }

//       var formData = FormData.fromMap(formDataMap);

//       var dio = await DioService.getDio(
//         headers: {'Content-Type': 'multipart/form-data'},
//       );

//       debugPrint("URL POST Multipart --> $url");
//       debugPrint("Field name --> $fieldName");
//       debugPrint("Files count --> ${files.length}");

//       return dio.post(
//         url,
//         data: formData,
//         onReceiveProgress: onReceiveProgress,
//         onSendProgress: onSendProgress,
//         queryParameters: queryParameters,
//       );
//     } on DioException {
//       rethrow;
//     }
//   }

//   /// PUT request
//   Future<Response> put(
//     String url, {
//     Map<String, dynamic>? headers,
//     Map<String, dynamic>? queryParameters,
//     Function(int total, int progress)? onSendProgress,
//     Function(int total, int progress)? onReceiveProgress,
//     dynamic data,
//   }) async {
//     try {
//       debugPrint("URL PUT --> $url");
//       debugPrint("Request param PUT --> ${jsonEncode(data)}");
//       debugPrint("Headers PUT --> $headers");

//       var dio = await DioService.getDio(headers: headers);

//       return dio.put(
//         url,
//         queryParameters: queryParameters,
//         data: data,
//         onReceiveProgress: onReceiveProgress,
//         onSendProgress: onSendProgress,
//       );
//     } on DioException {
//       rethrow;
//     }
//   }

//   /// PATCH request
//   Future<Response> patch(
//     String url, {
//     Map<String, dynamic>? headers,
//     Map<String, dynamic>? queryParameters,
//     Function(int total, int progress)? onSendProgress,
//     Function(int total, int progress)? onReceiveProgress,
//     Function? onLoading,
//     dynamic data,
//   }) async {
//     try {
//       debugPrint("URL PATCH --> $url");
//       debugPrint("Request param PATCH --> ${jsonEncode(data)}");
//       debugPrint("Headers PATCH --> $headers");

//       if (headers != null) {
//         headers["Cache-Control"] = "no-cache";
//       } else {
//         headers = {"Cache-Control": "no-cache"};
//       }

//       var dio = await DioService.getDio(headers: headers);

//       return dio.patch(
//         url,
//         queryParameters: queryParameters,
//         data: data,
//         onReceiveProgress: onReceiveProgress,
//         onSendProgress: onSendProgress,
//       );
//     } on DioException {
//       rethrow;
//     }
//   }

//   /// DELETE request
//   Future<Response> delete(
//     String url, {
//     Map<String, dynamic>? headers,
//     Map<String, dynamic>? queryParameters,
//     dynamic data,
//   }) async {
//     try {
//       debugPrint("URL DELETE --> $url");
//       debugPrint("Request param DELETE --> ${jsonEncode(data)}");
//       debugPrint("Headers DELETE --> $headers");

//       var dio = await DioService.getDio(headers: headers);

//       return dio.delete(url, queryParameters: queryParameters, data: data);
//     } on DioException {
//       rethrow;
//     }
//   }
// }
