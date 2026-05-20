import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/repositories/address_repository.dart';
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

  // ─── Form controllers ─────────────────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl1 = TextEditingController();
  final addressCtrl2 = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final zipCtrl = TextEditingController();

  AddressModel? _editingAddress;
  bool get isEditMode => _editingAddress != null;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl1.dispose();
    addressCtrl2.dispose();
    stateCtrl.dispose();
    cityCtrl.dispose();
    zipCtrl.dispose();
    super.onClose();
  }

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

  Future<void> fetchDefaultAddress() async {
    try {
      final result = await _repo.fetchDefaultAddress();
      defaultAddress.value = result;
    } catch (e) {
      debugPrint('❌ fetchDefaultAddress error: $e');
    }
  }

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
    } catch (e) {
      debugPrint('❌ saveAddress error: $e');
      ToastUtil.showToast('Failed to save address');
    } finally {
      isSaving.value = false;
    }
  }

  // ─── 3. Edit ──────────────────────────────────────────────────────────────

  void startEditing(AddressModel address) {
    _editingAddress = address;
    selectedLabel.value = address.label;
    nameCtrl.text = address.recipientName;
    phoneCtrl.text = address.phoneNumber;
    addressCtrl1.text = address.addressLine1;
    addressCtrl2.text = address.addressLine2 ?? '';
    cityCtrl.text = address.city;
    stateCtrl.text = address.state;
    zipCtrl.text = address.zipCode;
    makeDefault.value = address.isDefault;
  }

  // ─── 4. Delete ────────────────────────────────────────────────────────────

  Future<void> deleteAddress(String id) async {
    try {
      loading.value = true;
      final success = await _repo.deleteAddress(id);
      if (success) {
        addresses.removeWhere((a) => a.id == id);
        syncDefaultAddress();
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
    cityCtrl.clear();
    zipCtrl.clear();
    selectedLabel.value = 'Home';
    makeDefault.value = false;
  }

  bool _validateForm() {
    if (nameCtrl.text.trim().isEmpty) {
      ToastUtil.showToast('Recipient name is required');
      return false;
    }
    if (phoneCtrl.text.trim().isEmpty) {
      ToastUtil.showToast('Phone number is required');
      return false;
    }
    if (addressCtrl1.text.trim().isEmpty) {
      ToastUtil.showToast('Address line 1 is required');
      return false;
    }
    if (cityCtrl.text.trim().isEmpty) {
      ToastUtil.showToast('City is required');
      return false;
    }
    if (stateCtrl.text.trim().isEmpty) {
      ToastUtil.showToast('State is required');
      return false;
    }
    if (zipCtrl.text.trim().isEmpty) {
      ToastUtil.showToast('Zip code is required');
      return false;
    }
    return true;
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
