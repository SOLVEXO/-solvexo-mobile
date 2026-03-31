import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/address/controllers/address_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAddressView extends StatelessWidget {
  AddAddressView({super.key});
  final controller = Get.find<AddressController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBarTwo(title: "Add Address"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            field(
              "Label Address",
              controller.selectedLabel,
              onTap: () => controller.labelSheet(size),
            ),
            customLableWithField(
              controller.nameCtrl,
              "Input Recipient Name",
              "Recipient's Name",
              true,
            ),
            customLableWithField(
              controller.phoneCtrl,
              "(+92) phone number",
              "Phone Number",
              true,
            ),
            customLableWithField(
              controller.addressCtrl1,
              "Street address or P.O.Box",
              "Address",
              true,
            ),

            customLableWithField(
              controller.stateCtrl,
              "Select state",
              "State",
              true,
            ),
            customLableWithField(
              controller.cityCtrl,
              "Input city",
              "City",
              true,
            ),
            customLableWithField(
              controller.zipCtrl,
              "Input Zip code",
              "Zip Code",
              true,
            ),
            customLableWithField(
              controller.countryCtrl,
              "Country",
              "Country",
              true,
            ),
            Obx(
              () => CheckboxListTile(
                value: controller.makeDefault.value,
                onChanged: (v) => controller.makeDefault.value = v!,
                title: CustomText(
                  text: "Make this as default address",
                  fontSize: AppFontSize.regular,
                ),
              ),
            ),
            AppButton(
              label: "Add Address",
              onPressed: () {
                controller.saveAddress();
              },
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
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        islabel
            ? CustomText(
                text: label,
                fontSize: AppFontSize.small,
                fontWeight: FontWeight.w700,
              )
            : SizedBox(),
        CustomTextField(
          controller: controller,
          hintText: hint,
          onChanged: (v) => controller.text = v,
          filled: true,
          fillColor: AppColors.background,
          isborder: true,
        ),
      ],
    );
  }

  Widget field(String title, RxString value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
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
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.w700,
                    ),

                    const SizedBox(height: 4),
                    CustomText(text: value.value, fontSize: AppFontSize.small),
                  ],
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 30),
          ],
        ),
      ),
    );
  }
}
