import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/repositories/address_repository.dart';
import 'package:book_store_app/app/modules/address/utils/address_rules.dart';
import 'package:book_store_app/app/modules/map_picker/models/picked_address_model.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:dio/dio.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/address_model.dart';

class AddressController extends GetxController {
  final AddressRepository _repo = AddressRepository();

  // ─── State ────────────────────────────────────────────────────────────────
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> defaultAddress = Rx<AddressModel?>(null);
  final RxBool loading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUpdating = false.obs;

  // ─── Form state ───────────────────────────────────────────────────────────
  final RxString selectedLabel = 'Home'.obs;
  final RxBool makeDefault = false.obs;

  /// Inline errors by API field name (phoneNumber, zipCode, city,
  /// addressLine1, addressLine2, state, recipientName, country).
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  /// Selected province (one of AddressRules.provinces).
  final RxString province = ''.obs;

  void setProvince(String p) {
    province.value = p;
    stateCtrl.text = p;
    fieldErrors.remove('state');
  }

  // ─── Form controllers ─────────────────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl1 = TextEditingController();
  final addressCtrl2 = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final zipCtrl = TextEditingController();
  final countryCtrl = TextEditingController();

  /// Coordinates from the map picker, if the location fields were filled
  /// that way rather than typed manually. Cleared whenever the location
  /// fields are edited by hand afterwards, so a stale pin never gets
  /// attached to a manually-corrected address.
  double? _pickedLatitude;
  double? _pickedLongitude;
  bool _isApplyingPickedAddress = false;

  AddressModel? _editingAddress;
  bool get isEditMode => _editingAddress != null;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
    addressCtrl1.addListener(_clearPickedCoordsIfManualEdit);
    cityCtrl.addListener(_clearPickedCoordsIfManualEdit);
    stateCtrl.addListener(_clearPickedCoordsIfManualEdit);
    zipCtrl.addListener(_clearPickedCoordsIfManualEdit);
    countryCtrl.addListener(_clearPickedCoordsIfManualEdit);
  }

  void _clearPickedCoordsIfManualEdit() {
    if (_isApplyingPickedAddress) return;
    _pickedLatitude = null;
    _pickedLongitude = null;
  }

  /// Fills the location fields from a map-picker result, leaving
  /// recipient/phone/label untouched since those aren't location data.
  void applyPickedAddress(PickedAddress picked) {
    _isApplyingPickedAddress = true;
    addressCtrl1.text = picked.addressLine1;
    addressCtrl2.text = picked.addressLine2 ?? '';
    cityCtrl.text = picked.city;
    // Only an exact province name is accepted by the API.
    final match = AddressRules.matchProvince(picked.state);
    stateCtrl.text = match ?? '';
    province.value = match ?? '';
    zipCtrl.text = picked.zipCode;
    countryCtrl.text = picked.countryCode ?? '';
    _isApplyingPickedAddress = false;

    _pickedLatitude = picked.latitude;
    _pickedLongitude = picked.longitude;
  }

  @override
  void onClose() {
    addressCtrl1.removeListener(_clearPickedCoordsIfManualEdit);
    cityCtrl.removeListener(_clearPickedCoordsIfManualEdit);
    stateCtrl.removeListener(_clearPickedCoordsIfManualEdit);
    zipCtrl.removeListener(_clearPickedCoordsIfManualEdit);
    countryCtrl.removeListener(_clearPickedCoordsIfManualEdit);
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl1.dispose();
    addressCtrl2.dispose();
    stateCtrl.dispose();
    cityCtrl.dispose();
    zipCtrl.dispose();
    countryCtrl.dispose();
    super.onClose();
  }

  Future<void> refreshaddress() => fetchAddresses();
  // ─── 1. Fetch ─────────────────────────────────────────────────────────────

  Future<void> fetchAddresses() async {
    try {
      loading.value = true;
      final result = await _repo.fetchAddresses();
      debugPrint('📍 Addresses fetched: $result');
      addresses.assignAll(result);
      syncDefaultAddress();
      debugPrint('✅ Addresses loaded: ${result.length}');
    } catch (e) {
      debugPrint('❌ fetchAddresses error: $e');
      ToastUtil.showToast('Failed to load addresses');
    } finally {
      loading.value = false;
    }
  }

  /// Backend only flags `isDefault` on an address if the buyer explicitly
  /// chose one — most addresses are created without it, so fall back to
  /// the first address rather than showing "no address" when one exists.
  void syncDefaultAddress() {
    try {
      defaultAddress.value = addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      defaultAddress.value = addresses.isNotEmpty ? addresses.first : null;
    }
  }

  // ─── 2. Save — handles both create and update ─────────────────────────────

  Future<void> saveAddress() async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;

      final model = AddressModel(
        id: _editingAddress?.id, // null = create, set = update
        label: selectedLabel.value,
        recipientName: nameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
        addressLine1: addressCtrl1.text.trim(),
        addressLine2: addressCtrl2.text.trim().isEmpty
            ? null
            : addressCtrl2.text.trim(),
        city: cityCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        zipCode: zipCtrl.text.trim(),
        country: countryCtrl.text.trim().isEmpty
            ? null
            : countryCtrl.text.trim().toUpperCase(),
        latitude: _pickedLatitude,
        longitude: _pickedLongitude,
        isDefault: makeDefault.value,
      );

      if (_editingAddress == null) {
        // ── Create ────────────────────────────────────────────────────
        await _repo.createAddress(model);
        ToastUtil.showToast('Address added successfully');
      } else {
        // ── Update — passes addressId in body via toUpdateJson ────────
        await _repo.updateAddress(model);
        ToastUtil.showToast('Address updated successfully');
      }

      await fetchAddresses();
      clearForm();

      // Go back to address list
      Get.back();
    } on DioException catch (e) {
      // 400 {message, errors: {field: message}}: show each under its field
      // and the server's message as the toast.
      final data = e.response?.data;
      if (data is Map && data['errors'] is Map) {
        fieldErrors.assignAll({
          for (final en in (data['errors'] as Map).entries) '${en.key}': '${en.value}',
        });
      }
      ToastUtil.showToast(ApiError.fromDio(e) ?? 'Failed to save address'.tr);
    } catch (e) {
      debugPrint('❌ saveAddress error: $e');
      ToastUtil.showToast('Failed to save address'.tr);
    } finally {
      isSaving.value = false;
    }
  }

  // ─── 3. Edit ──────────────────────────────────────────────────────────────

  final RxBool isFetchingForEdit = false.obs;

  /// Fetches the latest copy of [address] by id before opening the edit
  /// form, rather than trusting the (possibly stale) row from the list —
  /// falls back to the passed-in [address] if the fetch fails.
  Future<void> startEditing(AddressModel address) async {
    var toEdit = address;
    if (address.id != null) {
      isFetchingForEdit.value = true;
      final fresh = await _repo.getAddressById(address.id!);
      isFetchingForEdit.value = false;
      if (fresh != null) toEdit = fresh;
    }
    _populateForm(toEdit);
  }

  void _populateForm(AddressModel address) {
    _editingAddress = address;
    _isApplyingPickedAddress = true;
    selectedLabel.value = address.label;
    nameCtrl.text = address.recipientName;
    phoneCtrl.text = address.phoneNumber;
    addressCtrl1.text = address.addressLine1;
    addressCtrl2.text = address.addressLine2 ?? '';
    cityCtrl.text = address.city;
    stateCtrl.text = address.state;
    // An address saved before the province list may need a new choice.
    province.value = AddressRules.provinces.contains(address.state) ? address.state : '';
    fieldErrors.clear();
    zipCtrl.text = address.zipCode;
    countryCtrl.text = address.country ?? '';
    makeDefault.value = address.isDefault;
    _isApplyingPickedAddress = false;
    _pickedLatitude = address.latitude;
    _pickedLongitude = address.longitude;
  }

  // ─── 4. Delete ────────────────────────────────────────────────────────────

  Future<void> deleteAddress(String id) async {
    try {
      loading.value = true;
      final success = await _repo.deleteAddress(id);
      if (success) {
        // Refetch rather than splice locally: deleting the default address
        // promotes another one server-side, and only a refetch picks up
        // which address that ended up being.
        await fetchAddresses();
        ToastUtil.showToast('Address deleted');
      }
    } catch (e) {
      debugPrint('❌ deleteAddress error: $e');
      ToastUtil.showToast('Failed to delete address');
    } finally {
      loading.value = false;
    }
  }

  // ─── 5. Set default ───────────────────────────────────────────────────────

  Future<void> setDefault(String id) async {
    try {
      loading.value = true;
      final success = await _repo.setDefault(id);
      if (success) {
        await fetchAddresses(); // refresh so isDefault flags update
      } else {
        ToastUtil.showToast('Failed to set default');
      }
    } catch (e) {
      debugPrint('❌ setDefault error: $e');
      ToastUtil.showToast('Failed to set default address');
    } finally {
      loading.value = false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void clearForm() {
    _editingAddress = null;
    nameCtrl.clear();
    phoneCtrl.clear();
    addressCtrl1.clear();
    addressCtrl2.clear();
    stateCtrl.clear();
    province.value = '';
    fieldErrors.clear();
    cityCtrl.clear();
    zipCtrl.clear();
    countryCtrl.clear();
    selectedLabel.value = 'Home';
    makeDefault.value = false;
    _pickedLatitude = null;
    _pickedLongitude = null;
  }

  /// The API's Pakistani address rules (AddressRules); errors inline,
  /// the first one also as a toast.
  bool _validateForm() {
    final e = <String, String?>{
      'recipientName': AddressRules.recipient(nameCtrl.text),
      'phoneNumber': AddressRules.phone(phoneCtrl.text),
      'addressLine1': AddressRules.line1(addressCtrl1.text),
      'addressLine2': AddressRules.line2(addressCtrl2.text),
      'state': AddressRules.state(stateCtrl.text),
      'city': AddressRules.city(cityCtrl.text),
      'zipCode': AddressRules.zip(zipCtrl.text),
      'country': AddressRules.country(countryCtrl.text),
    }..removeWhere((_, v) => v == null);
    fieldErrors.assignAll(e.cast<String, String>());
    if (e.isEmpty) return true;
    ToastUtil.showToast(e.values.first!);
    return false;
  }

  // ─── Label bottom sheet ───────────────────────────────────────────────────

  void labelSheet(Size size) {
    Get.bottomSheet(
      CustomBottomSheet(
        height: size.height / 2.7,
        title: 'Label Address',
        widget: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Home', 'Office', 'Apartment', 'Other'].map((e) {
            return ListTile(
              title: CustomText(text: e, fontSize: AppFontSize.regular),
              trailing: Obx(
                () => Radio<String>(
                  value: e,
                  groupValue: selectedLabel.value,
                  onChanged: (_) {
                    selectedLabel.value = e;
                    Get.back();
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
