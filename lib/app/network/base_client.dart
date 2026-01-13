import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:book_store_app/app/network/dio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

class BaseClient {
  static final BaseClient _baseClient = BaseClient._internal();

  factory BaseClient() {
    return _baseClient;
  }

  BaseClient._internal();

  // Future<bool> _checkInternetConnection() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile) {
  //     return true;
  //   } else if (connectivityResult == ConnectivityResult.wifi) {
  //     return true;
  //   }
  //   return false;
  // }

  /// GET request
  Future<Response> get(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Function(int value, int progress)? onReceiveProgress,
    Function? onLoading,
  }) async {
    try {
      debugPrint("URL GET --> $url");
      debugPrint("Request param GET --> $data");
      debugPrint("Query Param GET --> $queryParameters");
      debugPrint("Headers GET --> $headers");

      // if (await _checkInternetConnection()) {
      //   throw DioException(requestOptions: RequestOptions(), type: DioExceptionType.connectionError);
      // }

      var dio = await DioService.getDio(headers: headers);

      return dio.get(
        url,
        data: data,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException {
      rethrow;
    }
  }

  ///POST request
  Future<Response> post(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Function(int total, int progress)? onSendProgress,
    Function(int total, int progress)? onReceiveProgress,
    Function? onLoading,
    dynamic data,
  }) async {
    try {
      debugPrint("URL POST --> $url");
      debugPrint("Request param POST --> $data");
      debugPrint("Headers POST --> $headers");

      var dio = await DioService.getDio(headers: headers);

      return dio.post(
        url,
        data: data,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        queryParameters: queryParameters,
      );
    } on DioException {
      rethrow;
    }
  }

  /// POST multipart request
  Future<Response> postMultipart(
    String url, {
    Map<String, dynamic>? queryParameters,
    Function(int total, int progress)?
    onSendProgress, // while sending (uploading) progress
    Function(int total, int progress)?
    onReceiveProgress, // while receiving data(response)
    required File file,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      var fileExt = fileName.split('.').last;

      var formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType("image", fileExt),
        ),
      });

      var dio = await DioService.getDio(
        headers: {'Content-Type': 'multipart/form-data'},
      );

      debugPrint("URL POST Multipart --> $url");
      debugPrint("Request param POST Multipart --> $formData");
      debugPrint("File name POST Multipart --> $fileName");
      debugPrint("Extension --> $fileExt");

      return dio.post(
        url,
        data: formData,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        queryParameters: queryParameters,
      );
    } on DioException {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Function(int total, int progress)? onSendProgress,
    Function(int total, int progress)? onReceiveProgress,
    dynamic data,
  }) async {
    try {
      debugPrint("URL PUT --> $url");
      debugPrint("Request param PUT --> ${jsonEncode(data)}");
      debugPrint("Headers PUT --> $headers");

      var dio = await DioService.getDio(headers: headers);

      return dio.put(
        url,
        queryParameters: queryParameters,
        data: data,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      );
    } on DioException {
      rethrow;
    }
  }

  /// PATCH request
  Future<Response> patch(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Function(int total, int progress)? onSendProgress,
    Function(int total, int progress)? onReceiveProgress,
    Function? onLoading,
    dynamic data,
  }) async {
    try {
      debugPrint("URL PATCH --> $url");
      debugPrint("Request param PATCH --> ${jsonEncode(data)}");
      debugPrint("Headers PATCH --> $headers");

      if (headers != null) {
        headers["Cache-Control"] = "no-cache";
      } else {
        headers = {"Cache-Control": "no-cache"};
      }

      var dio = await DioService.getDio(headers: headers);

      return dio.patch(
        url,
        queryParameters: queryParameters,
        data: data,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      );
    } on DioException {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      debugPrint("URL DELETE --> $url");
      debugPrint("Request param DELETE --> ${jsonEncode(data)}");
      debugPrint("Headers DELETE --> $headers");

      var dio = await DioService.getDio(headers: headers);

      return dio.delete(url, queryParameters: queryParameters, data: data);
    } on DioException {
      rethrow;
    }
  }
}
