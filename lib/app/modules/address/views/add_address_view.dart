import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/address/controllers/address_controller.dart';
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
            customLableWithField(controller.nameCtrl, "Input Recipient Name", "Recipient's Name", true),
            customLableWithField(controller.phoneCtrl, "(+92) phone number", "Phone Number", true),
            customLableWithField(controller.addressCtrl1, "Street address or P.O.Box", "Address", true),
            customLableWithField(controller.stateCtrl, "Select state", "State", true),
            customLableWithField(controller.cityCtrl, "Input city", "City", true),
            customLableWithField(controller.zipCtrl, "Input Zip code", "Zip Code", true),
            customLableWithField(controller.countryCtrl, "Country code e.g. PK, US", "Country (optional)", false),
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

  Widget customLableWithField(
    TextEditingController controller,
    String hint,
    String label,
    bool islabel,
  ) {
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
          filled: true,
          fillColor: AppColors.background,
          isborder: true,
        ),
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
