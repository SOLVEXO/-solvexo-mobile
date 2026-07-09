import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabHeader extends StatelessWidget {
  TabHeader({super.key});

  final c = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Scrollbar(
        scrollbarOrientation: ScrollbarOrientation.bottom,
        trackVisibility: true,
        interactive: true,
        thickness: 4,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: EdgeInsets.only(left: BaseSpacing.md - 1, right: BaseSpacing.md - 1),
          scrollDirection: Axis.horizontal,
          itemCount: c.tabs.length,
          separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.md),
          itemBuilder: (_, i) {
            return Obx(() {
              bool selected = c.tabIndex.value == i;

              return GestureDetector(
                // Was `c.tabIndex.value = i; c.filteredProducts;` — the
                // second statement just read an RxList reference and threw
                // it away; it never re-triggered filtering/fetching, so
                // tapping a tab changed its own highlighted state but never
                // actually updated the product list. `onTabChanged` is the
                // controller's own public method for this exact action.
                onTap: () => c.onTabChanged(i),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: BaseMotion.normal,
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(BaseRadius.md),
                        color: selected ? AppColors.primaryColor : AppColors.white,
                        border: Border.all(
                          width: 0.3,
                          color: selected ? AppColors.primaryColor : AppColors.textPrimary,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs - 2, horizontal: BaseSpacing.xs),
                      child: Text(
                        c.tabs[i],
                        style: BaseTypography.labelSmall(
                          color: selected ? AppColors.white : AppColors.textPrimary,
                        ).copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
