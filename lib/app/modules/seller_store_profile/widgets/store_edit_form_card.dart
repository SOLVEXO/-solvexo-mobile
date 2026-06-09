import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreEditFormCard extends StatelessWidget {
  final SellerStoreProfileController c;
  const StoreEditFormCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('Store Name', required: true),
        const SizedBox(height: 6),
        CustomTextField(
          controller: c.nameCtrl,
          hintText: 'e.g. Creative Classroom Resources',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
        ),
        const SizedBox(height: 16),
        _fieldLabel('Store Description', optional: true),
        const SizedBox(height: 6),
        CustomTextField(
          controller: c.descCtrl,
          hintText: 'Tell buyers what makes your store special...',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        _fieldLabel('Category'),
        const SizedBox(height: 6),
        Obx(() => StoreDropdown(
          value: c.editCategory.value,
          options: kStoreCategories,
          onSelect: c.pickCategory,
        )),
      ]),
    );
  }
}

Widget _fieldLabel(String text, {bool required = false, bool optional = false}) {
  return Row(children: [
    CustomText(text: text, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w600, color: AppColors.black2),
    if (required) const CustomText(text: ' *', fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w600, color: AppColors.red),
    if (optional) const CustomText(text: ' (optional)', fontSize: AppFontSize.tiny, color: AppColors.grey),
  ]);
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
  boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
);

class StoreDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelect;

  const StoreDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.bottomSheet(
        Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, color: AppColors.lightGrey2),
                itemBuilder: (_, i) => ListTile(
                  title: Text(
                    options[i],
                    style: TextStyle(
                      fontSize: 14,
                      color: options[i] == value ? AppColors.primaryColor : AppColors.black,
                      fontWeight: options[i] == value ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: options[i] == value
                      ? const Icon(Icons.check_rounded, color: AppColors.primaryColor, size: 16)
                      : null,
                  onTap: () { onSelect(options[i]); Get.back(); },
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ]),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.textfldFillColor,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(color: AppColors.lightGrey, width: 0.3),
        ),
        child: Row(children: [
          Expanded(child: CustomText(
            text: value.isEmpty ? 'Select a category' : value,
            fontSize: AppFontSize.verySmall,
            color: value.isEmpty ? AppColors.grey : AppColors.black,
          )),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.grey),
        ]),
      ),
    );
  }
}
