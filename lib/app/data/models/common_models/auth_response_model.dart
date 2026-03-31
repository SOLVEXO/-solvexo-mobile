import 'package:book_store_app/app/data/models/common_models/token_pair.dart';
import 'package:book_store_app/app/data/models/common_models/user_model.dart';
import 'package:flutter/material.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final UserModel user;
  final TokenPair token;

  AuthResponseModel({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint("🔍 Parsing AuthResponseModel");

      return AuthResponseModel(
        success: json['success'] as bool,
        message: json['message'] as String,
        // ✅ CRITICAL: Parse from json['data']['user']
        user: UserModel.fromJson(json['data']['user'] as Map<String, dynamic>),
        // ✅ CRITICAL: Parse from json['data']['token']
        token: TokenPair.fromJson(
          json['data']['token'] as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      debugPrint("❌ AuthResponseModel parsing error: $e");
      debugPrint("JSON: $json");
      rethrow;
    }
  }
}
