import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabHeader extends StatelessWidget {
  TabHeader({super.key});

  final c = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 15, right: 15),
        scrollDirection: Axis.horizontal,
        itemCount: c.tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          return Obx(() {
            bool selected = c.tabIndex.value == i;

            return GestureDetector(
              onTap: () {
                c.tabIndex.value = i;
                c.filterProducts();
              },

              child: Column(
                children: [
                  /// --- tab label
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    child: CustomText(
                      text: c.tabs[i],
                      fontSize: AppFontSize.small,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? AppColors.primaryColor
                          : AppColors.textPrimary,
                    ),
                  ),

                  /// --- underline indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: selected ? 4 : 0,
                    width: selected ? 30 : 0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7a73ff),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}
