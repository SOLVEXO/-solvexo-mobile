import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/address/controllers/address_controller.dart';
import 'package:book_store_app/app/modules/address/utils/address_rules.dart';
import 'package:book_store_app/app/modules/map_picker/models/picked_address_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAddressView extends StatelessWidget {
  AddAddressView({super.key});
  final controller = Get.find<AddressController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseViewScreen(
      backgroundColor: AppColors.white,
      screenName: "Add Address",
      showCustomAppBar: true,
      resizeToAvoidBottomInset: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            field("Label Address", controller.selectedLabel, onTap: () => controller.labelSheet(size)),
            customLableWithField(controller.nameCtrl, "Input Recipient Name".tr, "Recipient's Name".tr, true, field: 'recipientName'),
            customLableWithField(controller.phoneCtrl, "03XXXXXXXXX".tr, "Mobile number".tr, true,
                field: 'phoneNumber', keyboard: TextInputType.phone),
            Padding(
              padding: EdgeInsets.only(bottom: BaseSpacing.md),
              child: OutlineButton(
                label: 'Pick location on map',
                icon: const Icon(Icons.map_outlined),
                onPressed: () => _pickFromMap(),
              ),
            ),
            customLableWithField(controller.addressCtrl1, "House, street and area".tr, "Address".tr, true, field: 'addressLine1'),
            _provinceField(context),
            customLableWithField(controller.cityCtrl, "Input city".tr, "City".tr, true, field: 'city'),
            customLableWithField(controller.zipCtrl, "5-digit postal code".tr, "Postal code".tr, true,
                field: 'zipCode', keyboard: TextInputType.number),
            customLableWithField(controller.countryCtrl, "Country code e.g. PK, US", "Country (optional)", false, field: 'country'),
            Obx(
              () => CheckboxListTile(
                value: controller.makeDefault.value,
                onChanged: (v) => controller.makeDefault.value = v!,
                title: CustomText(
                  text: "Make this as default address",
                  color: AppColors.black,
                  fontSize: AppFontSize.extraSmall,
                ),
              ),
            ),
            Obx(
              () => PrimaryButton(
                label: controller.isSaving.value ? "Loading..." : "Add Address",
                isLoading: controller.isSaving.value,
                onPressed: controller.isSaving.value ? null : controller.saveAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromMap() async {
    final result = await Get.toNamed(Routes.mapPickerView);
    if (result is PickedAddress) {
      controller.applyPickedAddress(result);
      if (!result.hasUsableDetail) {
        CustomAppSnackbar.warning(
          'Location pinned, but please double-check city/state — they could not be detected automatically.',
        );
      }
    }
  }

  /// Province: one of the exact names the API accepts.
  Widget _provinceField(BuildContext context) {
    return Obx(() {
      final error = controller.fieldErrors['state'];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomText(text: "Province".tr, color: AppColors.black, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w700),
        SizedBox(height: BaseSpacing.xxs / 2),
        InkWell(
          key: const Key('provinceField'),
          onTap: () => _pickProvince(),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm + 2),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(BaseRadius.md),
              border: Border.all(color: error != null ? Theme.of(context).colorScheme.error : AppColors.lightGrey),
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                  controller.province.value.isEmpty ? "Select province".tr : controller.province.value,
                  style: TextStyle(color: controller.province.value.isEmpty ? AppColors.grey : AppColors.black),
                ),
              ),
              const Icon(Icons.expand_more_rounded),
            ]),
          ),
        ),
        _errorText(context, error),
        SizedBox(height: BaseSpacing.sm),
      ]);
    });
  }

  Future<void> _pickProvince() async {
    final picked = await Get.bottomSheet<String>(
      SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final p in AddressRules.provinces)
            ListTile(
              key: Key('province_$p'),
              minTileHeight: 48,
              title: Text(p),
              trailing: controller.province.value == p ? const Icon(Icons.check_rounded) : null,
              onTap: () => Get.back(result: p),
            ),
        ]),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
      isScrollControlled: true,
    );
    if (picked != null) controller.setProvince(picked);
  }

  Widget _errorText(BuildContext context, String? error) => error == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
        );

  Widget customLableWithField(
    TextEditingController controller,
    String hint,
    String label,
    bool islabel, {
    String? field,
    TextInputType? keyboard,
  }) {
    return Column(
      spacing: BaseSpacing.xxs / 2,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        islabel
            ? CustomText(
                text: label,
                color: AppColors.black,
                fontSize: AppFontSize.extraSmall,
                fontWeight: FontWeight.w700,
              )
            : const SizedBox(),
        CustomTextField(
          // Was `onChanged: (v) => controller.text = v` — reassigning
          // `.text` on every keystroke while the field is already bound to
          // this same controller is redundant and can reset the cursor to
          // the start of the field while typing. The TextField's own
          // binding to `controller` already keeps `.text` current.
          controller: controller,
          hintText: hint,
          keyboardType: keyboard,
          onChanged: field == null ? null : (_) => this.controller.fieldErrors.remove(field),
          filled: true,
          fillColor: AppColors.background,
          isborder: true,
        ),
        if (field != null) Obx(() => _errorText(Get.context!, this.controller.fieldErrors[field])),
      ],
    );
  }

  Widget field(String title, RxString value, {VoidCallback? onTap}) {
    return Semantics(
      button: true,
      label: '$title: ${value.value}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          margin: EdgeInsets.only(bottom: BaseSpacing.sm),
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm + 2, vertical: BaseSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(BaseRadius.md),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: title,
                        color: AppColors.black,
                        fontSize: AppFontSize.extraSmall,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: BaseSpacing.xxs),
                      CustomText(
                        text: value.value,
                        color: AppColors.black,
                        fontSize: AppFontSize.extraSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
