import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerStoreProfileView extends StatelessWidget {
  SellerStoreProfileView({super.key});

  final SellerStoreProfileController c = Get.put(SellerStoreProfileController());

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Store Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimen.allPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LogoSection(c: c),
            const SizedBox(height: 16),
            _FormCard(c: c),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _SaveBar(c: c, bottomInset: bottomInset),
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  final SellerStoreProfileController c;
  const _LogoSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: _cardDeco(),
      child: Row(
        children: [
          Obx(() => GestureDetector(
                onTap: c.pickLogo,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: c.hasLogo.value
                        ? AppColors.greenContainerInnerColor
                        : AppColors.background,
                    borderRadius:
                        BorderRadius.circular(AppDimen.serviceCountTileRadius),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    c.hasLogo.value
                        ? Icons.check_circle_rounded
                        : Icons.camera_alt_outlined,
                    size: 28,
                    color: c.hasLogo.value
                        ? AppColors.darkGreen
                        : AppColors.primaryColor,
                  ),
                ),
              )),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Store Logo',
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                const SizedBox(height: 4),
                const CustomText(
                  text: 'PNG or JPG · min 200×200px',
                  fontSize: AppFontSize.tiny,
                  color: AppColors.grey,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: c.pickLogo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const CustomText(
                      text: 'Upload Photo',
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final SellerStoreProfileController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Store Name', required: true),
          const SizedBox(height: 6),
          CustomTextField(
            controller: c.nameCtrl,
            onChanged: (v) => c.storeName.value = v,
            hintText: 'e.g. Creative Classroom Resources',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
          ),
          const SizedBox(height: 16),
          _label('Store Description', optional: true),
          const SizedBox(height: 6),
          CustomTextField(
            controller: c.descCtrl,
            onChanged: (v) => c.storeDescription.value = v,
            hintText: 'Tell buyers what makes your store special...',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _label('Category'),
          const SizedBox(height: 6),
          Obx(() => _Dropdown(
                value: c.storeCategory.value,
                options: kStoreCategories,
                onSelect: c.pickCategory,
              )),
          const SizedBox(height: 16),
          _label('Contact Email'),
          const SizedBox(height: 6),
          CustomTextField(
            controller: c.emailCtrl,
            onChanged: (v) => c.contactEmail.value = v,
            hintText: 'store@example.com',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _label('Phone', optional: true),
          const SizedBox(height: 6),
          CustomTextField(
            controller: c.phoneCtrl,
            onChanged: (v) => c.contactPhone.value = v,
            hintText: '+1 (555) 000-0000',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _label(String text, {bool required = false, bool optional = false}) {
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

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelect;
  const _Dropdown({required this.value, required this.options, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.bottomSheet(
        Container(
          decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2))),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, color: AppColors.lightGrey2),
                itemBuilder: (_, i) => ListTile(
                  title: Text(options[i], style: TextStyle(fontSize: 14, color: options[i] == value ? AppColors.primaryColor : AppColors.black, fontWeight: options[i] == value ? FontWeight.w600 : FontWeight.normal)),
                  trailing: options[i] == value ? const Icon(Icons.check_rounded, color: AppColors.primaryColor, size: 16) : null,
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
        decoration: BoxDecoration(color: AppColors.textfldFillColor, borderRadius: BorderRadius.circular(AppDimen.borderRadius), border: Border.all(color: AppColors.lightGrey, width: 0.3)),
        child: Row(children: [
          Expanded(child: CustomText(text: value, fontSize: AppFontSize.verySmall, color: AppColors.black)),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.grey),
        ]),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final SellerStoreProfileController c;
  final double bottomInset;
  const _SaveBar({required this.c, required this.bottomInset});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.fromLTRB(AppDimen.allPadding, 12, AppDimen.allPadding, 12 + bottomInset),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, -3))]),
      child: GestureDetector(
        onTap: c.canSave && !c.isSaving.value ? c.save : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(color: c.canSave ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.38), borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius)),
          alignment: Alignment.center,
          child: c.isSaving.value
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
              : const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_rounded, color: AppColors.white, size: 18),
                  SizedBox(width: 8),
                  CustomText(text: 'Save Changes', fontSize: AppFontSize.small2, fontWeight: FontWeight.w600, color: AppColors.white),
                ]),
        ),
      ),
    ));
  }
}
