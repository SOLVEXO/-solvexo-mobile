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
      options: Options(extra: {'requiresAuth': requiresAuth}),
    );
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final dio = await DioService.getDio();
    debugPrint("POST → $url");

    // ✅ When data is FormData, Dio will automatically set
    // Content-Type: multipart/form-data with the correct boundary.
    // When data is a Map/JSON, Dio sets Content-Type: application/json.
    // We must NOT override contentType here — let Dio detect it.
    return dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        extra: {'requiresAuth': requiresAuth},
        // ✅ contentType is intentionally NOT set — Dio auto-detects from body
      ),
    );
  }

  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final dio = await DioService.getDio();
    debugPrint("PUT → $url");

    return dio.put(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(extra: {'requiresAuth': requiresAuth}),
    );
  }

  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final dio = await DioService.getDio();
    debugPrint("DELETE → $url");

    return dio.delete(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(extra: {'requiresAuth': requiresAuth}),
    );
  }

  /// Multipart upload helper — builds FormData from files + optional fields.
  Future<Response> postMultipart(
    String url, {
    required List<File> files,
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    bool requiresAuth = true,
  }) async {
    final dio = await DioService.getDio();
    final map = <String, dynamic>{};

    for (final file in files) {
      final name = file.path.split('/').last;
      final ext = name.split('.').last.toLowerCase();

      map[fieldName] = await MultipartFile.fromFile(
        file.path,
        filename: name,
        contentType: MediaType('image', ext),
      );
    }

    if (additionalData != null) map.addAll(additionalData);

    return dio.post(
      url,
      data: FormData.fromMap(map),
      options: Options(
        extra: {'requiresAuth': requiresAuth},
        // ✅ No contentType override — Dio sets multipart/form-data automatically
      ),
    );
  }

  /// Streaming POST — for SSE endpoints.
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
