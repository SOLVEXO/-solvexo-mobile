import 'package:book_store_app/app/modules/address/models/address_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:flutter/material.dart';

class AddressRepository {
  final BaseClient _baseClient = BaseClient();
  Future<List<AddressModel>> fetchAddresses() async {
    try {
      final res = await _baseClient.get(ApiConstants.addresses);

      debugPrint("📦 Address API response: ${res.data}");

      // SAFE checks
      if (res.data == null) return [];

      if (res.data is! Map<String, dynamic>) {
        debugPrint("❌ Invalid response format");
        return [];
      }

      final data = res.data['data'];

      if (data == null || data is! List) {
        debugPrint("⚠️ No address list found");
        return [];
      }

      return data.map<AddressModel>((e) => AddressModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("❌ fetchAddresses error: $e");
      return [];
    }
  }

  Future<void> createAddress(AddressModel address) async {
    await _baseClient.post(ApiConstants.addresses, data: address.toJson());
  }

  Future<void> updateAddress(AddressModel address) async {
    await _baseClient.put(
      ApiConstants.updateAddress(address.id!),
      data: address.toJson(),
    );
  }

  Future<void> deleteAddress(String id) async {
    await _baseClient.delete(ApiConstants.deleteAddress(id));
  }

  Future<void> setDefault(String id) async {
    await _baseClient.put(ApiConstants.setDefaultAddress(id));
  }
}
