import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Generic bottom-sheet single-select list — used for the product/category
/// pickers across the AI Studio tool forms so those don't each hand-roll one.
class SimplePickerSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final String? Function(T)? itemSubtitle;

  const SimplePickerSheet({
    super.key,
    required this.title,
    required this.items,
    required this.itemLabel,
    this.itemSubtitle,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    String? Function(T)? itemSubtitle,
  }) {
    return Get.bottomSheet<T>(
      SimplePickerSheet<T>(title: title, items: items, itemLabel: itemLabel, itemSubtitle: itemSubtitle),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.sm),
              child: CustomText(text: title, color: AppColors.black2, fontSize: AppFontSize.medium, fontWeight: FontWeight.w700),
            ),
            const Divider(height: 1, color: AppColors.lightGrey2),
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.all(BaseSpacing.lg),
                child: CustomText(text: 'Nothing to show', color: AppColors.gray600, fontSize: AppFontSize.verySmall),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.lightGrey2),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    final subtitle = itemSubtitle?.call(item);
                    return ListTile(
                      title: CustomText(text: itemLabel(item), color: AppColors.black2, fontSize: AppFontSize.verySmall),
                      subtitle: subtitle != null
                          ? CustomText(text: subtitle, color: AppColors.gray600, fontSize: AppFontSize.tiny)
                          : null,
                      onTap: () => Get.back(result: item),
                    );
                  },
                ),
              ),
            SizedBox(height: BaseSpacing.sm),
          ],
        ),
      ),
    );
  }
}
