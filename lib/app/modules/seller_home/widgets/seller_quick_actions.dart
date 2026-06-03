import 'package:book_store_app/app/modules/seller_home/widgets/custom_action_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerQuickActions extends StatelessWidget {
  const SellerQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    List actions = [
      (
        icon: AppIcons.addIcon,
        label: 'Add Product',
        onTap: () => Get.toNamed(Routes.addSellerProduct),
      ),
      (
        icon: AppIcons.posIcon,
        label: 'Open POS',
        onTap: () {
          Get.toNamed(Routes.posHome);
        },
      ),
      (icon: AppIcons.aiStudioIcon, label: 'AI Studio', onTap: () {}),
      (
        icon: AppIcons.anylaticsIcon,
        label: 'Analytics',
        onTap: () => Get.toNamed(Routes.sellerAnalytics),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: actions
            .map(
              (a) => CustomActionCard(
                icon: a.icon,
                label: a.label,
                onTap: a.onTap,
              ),
            )
            .toList(),
      ),
    );
  }
}
