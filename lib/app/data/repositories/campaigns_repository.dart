import 'package:book_store_app/app/data/models/marketing/campaign_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CampaignsRepository {
  final BaseClient _client = BaseClient();

  // ─── GET /api/marketing/:storeId/campaigns ────────────────────────────────

  Future<List<CampaignModel>> getJoinableCampaigns({required String storeId}) async {
    try {
      final response = await _client.get(
        ApiConstants.joinableCampaigns(storeId),
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .cast<Map<String, dynamic>>()
            .map(CampaignModel.fromJson)
            .toList();
      }

      return <CampaignModel>[];
    } on DioException catch (e) {
      debugPrint('❌ getJoinableCampaigns DioException: ${e.response?.statusCode}');
      DioExceptionHandler.handleDioException(e);
      return <CampaignModel>[];
    } catch (e) {
      debugPrint('❌ getJoinableCampaigns error: $e');
      ToastUtil.showToast('Failed to load campaigns. Please try again.');
      return <CampaignModel>[];
    }
  }

  // ─── POST /api/marketing/:storeId/campaigns/:campaignId/join ──────────────

  Future<bool> joinCampaign({required String storeId, required String campaignId}) async {
    try {
      final response = await _client.post(
        ApiConstants.joinCampaign(storeId, campaignId),
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Joined campaign');
        return true;
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to join campaign');
      return false;
    } on DioException catch (e) {
      debugPrint('❌ joinCampaign DioException: ${e.response?.statusCode}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ joinCampaign error: $e');
      ToastUtil.showToast('Failed to join campaign. Please try again.');
      return false;
    }
  }

  // ─── DELETE /api/marketing/:storeId/campaigns/:campaignId/leave ───────────

  Future<bool> leaveCampaign({required String storeId, required String campaignId}) async {
    try {
      final response = await _client.delete(
        ApiConstants.leaveCampaign(storeId, campaignId),
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Left campaign');
        return true;
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to leave campaign');
      return false;
    } on DioException catch (e) {
      debugPrint('❌ leaveCampaign DioException: ${e.response?.statusCode}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ leaveCampaign error: $e');
      ToastUtil.showToast('Failed to leave campaign. Please try again.');
      return false;
    }
  }
}
