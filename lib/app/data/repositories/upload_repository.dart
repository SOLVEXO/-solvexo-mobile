import 'dart:io';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:book_store_app/app/network/api_constaints.dart';

class UploadRepository {
  final BaseClient _client = BaseClient();
  final ImagePicker _picker = ImagePicker();

  // ============================================================
  // IMAGE PICKER (GLOBAL)
  // ============================================================

  Future<File?> pickImage({
    required ImageSource source,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );

      if (picked == null) return null;

      debugPrint("📷 Image selected: ${picked.path}");
      return File(picked.path);
    } catch (e) {
      debugPrint("❌ Pick image error: $e");
      return null;
    }
  }

  // ============================================================
  // UPLOAD IMAGE (GLOBAL REUSABLE)
  // ============================================================

  Future<String?> uploadImage(File file) async {
    try {
      debugPrint("🔄 Uploading image...");

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: "upload_${DateTime.now().millisecondsSinceEpoch}.jpg",
        ),
      });

      final response = await _client.post(
        ApiConstants.uploadImage,
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final url = response.data['data']['url'];

        debugPrint("✅ Uploaded URL → $url");
        return url;
      }

      debugPrint("❌ Upload failed: ${response.data}");
      return null;
    } on DioException catch (e) {
      debugPrint("❌ Upload Dio error: ${e.response?.data}");
      return null;
    } catch (e) {
      debugPrint("❌ Upload error: $e");
      return null;
    }
  }

  // ============================================================
  // PICK + UPLOAD (MOST USED METHOD)
  // ============================================================

  Future<String?> pickAndUpload({required ImageSource source}) async {
    final file = await pickImage(source: source);
    if (file == null) return null;

    return await uploadImage(file);
  }

  // ============================================================
  // OPTIONAL HELPER → PROFILE IMAGE UPDATE
  // ============================================================

  Future<bool> updateProfileImage(String imageUrl) async {
    try {
      final response = await _client.put(
        ApiConstants.updateUserProfile,
        data: {"profileImage": imageUrl},
      );

      return response.statusCode == 200 && response.data["success"] == true;
    } catch (e) {
      debugPrint("❌ Profile update error: $e");
      return false;
    }
  }

  // ============================================================
  // ONE CALL PROFILE FLOW
  // ============================================================

  Future<String?> pickUploadAndUpdateProfile({
    required ImageSource source,
  }) async {
    final url = await pickAndUpload(source: source);

    if (url == null) return null;

    await updateProfileImage(url);

    return url;
  }
}
