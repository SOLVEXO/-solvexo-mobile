import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_language/controllers/seller_language_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerLanguageView extends StatelessWidget {
  SellerLanguageView({super.key});
  final SellerLanguageController c = Get.put(SellerLanguageController());

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Language'),
      body: Column(children: [
        Expanded(
          child: Obx(() {
            final currentSelected = c.selected.value; // register dependency
            return ListView(
            padding: const EdgeInsets.all(AppDimen.allPadding),
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: CustomText(text: 'SELECT LANGUAGE', fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700, color: AppColors.grey, letterSpacing: 0.8),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
                  boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: SellerLanguageController.languages.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 62, color: AppColors.lightGrey2),
                  itemBuilder: (_, i) {
                    final lang = SellerLanguageController.languages[i];
                    final isSelected = currentSelected == lang['name'];
                    return GestureDetector(
                      onTap: () => c.select(lang['name']!),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding, vertical: 14),
                        child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppDimen.borderRadius)),
                            alignment: Alignment.center,
                            child: Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            CustomText(text: lang['name']!, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w500, color: isSelected ? AppColors.primaryColor : AppColors.black),
                            const SizedBox(height: 2),
                            CustomText(text: lang['native']!, fontSize: AppFontSize.tiny, color: AppColors.grey),
                          ])),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primaryColor : AppColors.white,
                              border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.lightGrey2, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: isSelected ? const Icon(Icons.check_rounded, size: 12, color: AppColors.white) : null,
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ); }),
        ),
        Obx(() => Container(
          padding: EdgeInsets.fromLTRB(AppDimen.allPadding, 12, AppDimen.allPadding, 12 + bottomInset),
          decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, -3))]),
          child: GestureDetector(
            onTap: c.isSaving.value ? null : c.save,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius)),
              alignment: Alignment.center,
              child: c.isSaving.value
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
                  : const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_rounded, color: AppColors.white, size: 18),
                      SizedBox(width: 8),
                      CustomText(text: 'Apply Language', fontSize: AppFontSize.small2, fontWeight: FontWeight.w600, color: AppColors.white),
                    ]),
            ),
          ),
        )),
      ]),
    );
  }
}
