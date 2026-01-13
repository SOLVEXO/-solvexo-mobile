import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioExceptionHandler {
  static void handleDioException(
    DioException dioException, {
    bool showToast = true,
  }) {
    ///Need to do all network exception handling here
    String errorMessage = "An error occurred";

    debugPrint("Status code --> ${dioException.response?.statusCode}");

    switch (dioException.type) {
      case DioExceptionType.cancel:
        errorMessage = "Request was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage = "Connection timeout";
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = "Receive timeout";
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = "Send timeout";
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleResponseError(dioException.response!);
        break;
      case DioExceptionType.badCertificate:
        errorMessage = "Bad certificate error";
        break;
      case DioExceptionType.connectionError:
        errorMessage = "No Internet";
        break;
      case DioExceptionType.unknown:
        errorMessage = "An unexpected error occurred";
        break;
    }

    if (showToast) {
      ToastUtil.showToast(errorMessage);
    }

    debugPrint("Error --> $errorMessage");
  }

  static String _handleResponseError(Response<dynamic> response) {
    // Customize this method based on your application's needs

    String errorMessage;
    try {
      errorMessage = response.data["message"];
    } catch (e) {
      errorMessage = "Something went wrong";
    }

    // You can add more detailed error handling based on status codes or response data

    return errorMessage;
  }
}
