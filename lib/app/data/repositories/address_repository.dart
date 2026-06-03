import 'package:book_store_app/app/modules/address/models/address_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:flutter/material.dart';

class AddressRepository {
  final BaseClient _baseClient = BaseClient();

  // ─── Get all addresses ────────────────────────────────────────────────────
  // GET /address/getMyAddresses

  Future<List<AddressModel>> fetchAddresses() async {
    try {
      debugPrint('📍 GET ${ApiConstants.getAdresses}');

      final res = await _baseClient.get(
        ApiConstants.getAdresses,
        requiresAuth: true,
      );

      debugPrint('📦 fetchAddresses: ${res.data}');

      if (res.data == null) return [];
      if (res.data is! Map<String, dynamic>) return [];

      final data = res.data['data'];
      if (data == null || data is! List) return [];

      return data
          .map<AddressModel>(
            (e) => AddressModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('❌ fetchAddresses: $e');
      return [];
    }
  }

  // ─── Get default address ──────────────────────────────────────────────────
  // GET /address/getDefaultAddress

  Future<AddressModel?> fetchDefaultAddress() async {
    try {
      debugPrint('📍 GET ${ApiConstants.getDefaultAddress}');

      final res = await _baseClient.get(
        ApiConstants.getDefaultAddress,
        requiresAuth: true,
      );

      debugPrint('📦 fetchDefaultA ddress: ${res.data}');

      final data = res.data?['data'];
      if (data is Map<String, dynamic>) {
        return AddressModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('❌ fetchDefaultAddress: $e');
      return null;
    }
  }

  // ─── Add address ──────────────────────────────────────────────────────────
  // POST /address/add-address
  // Body: { label, recipientName, phoneNumber, addressLine1, addressLine2,
  //         state, city, zipCode, isDefault }

  Future<AddressModel?> createAddress(AddressModel address) async {
    try {
      debugPrint('📍 POST ${ApiConstants.addAdresses}');
      debugPrint('Body: ${address.toJson()}');

      final res = await _baseClient.post(
        ApiConstants.addAdresses,

        data: address.toJson(),
      );

      debugPrint('✅ createAddress: ${res.data}');

      final data = res.data?['data'];
      if (data is Map<String, dynamic>) {
        return AddressModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('❌ createAddress: $e');
      rethrow;
    }
  }

  // ─── Update address ───────────────────────────────────────────────────────
  // PUT /address/update-address
  // Body: { addressId, label, recipientName, phoneNumber, addressLine1,
  //         addressLine2, state, city, zipCode, isDefault }
  // Note: addressId goes in the BODY, not the URL path

  Future<AddressModel?> updateAddress(AddressModel address) async {
    try {
      debugPrint('📍 PUT ${ApiConstants.updateAddress}');
      debugPrint('Body: ${address.toUpdateJson()}');

      final res = await _baseClient.post(
        ApiConstants.updateAddress,
        data: address.toUpdateJson(), // includes addressId
      );

      debugPrint('✅ updateAddress: ${res.data}');

      final data = res.data?['data'];
      if (data is Map<String, dynamic>) {
        return AddressModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('❌ updateAddress: $e');
      rethrow;
    }
  }

  // ─── Delete address ───────────────────────────────────────────────────────
  // DELETE /address/delete-address/:id

  Future<bool> deleteAddress(String id) async {
    try {
      debugPrint('📍 DELETE ${ApiConstants.deleteAddress(id)}');

      final res = await _baseClient.delete(ApiConstants.deleteAddress(id));

      debugPrint('✅ deleteAddress: ${res.data}');

      return res.data?['success'] == true;
    } catch (e) {
      debugPrint('❌ deleteAddress: $e');
      return false;
    }
  }

  // ─── Set default address ──────────────────────────────────────────────────
  // PUT /address/set-default/:id

  Future<bool> setDefault(String id) async {
    try {
      debugPrint('📍 PUT ${ApiConstants.setDefaultAddress(id)}');

      final res = await _baseClient.put(ApiConstants.setDefaultAddress(id));

      debugPrint('✅ setDefault: ${res.data}');

      return res.data?['success'] == true;
    } catch (e) {
      debugPrint('❌ setDefault: $e');
      return false;
    }
  }
}
