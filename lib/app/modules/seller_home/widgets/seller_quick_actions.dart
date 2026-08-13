import 'package:book_store_app/app/modules/seller/utils/seller_store_gate.dart';
import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/app/modules/seller_home/widgets/custom_action_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// POS opens directly — in the merged platform-plans system POS access is an
/// entitlement (`maxPosLocations`, ≥1 on every plan), not a paid add-on, so
/// the old "$29/mo POS Add-on" paywall sheet was removed. "Open POS" itself
/// is only shown for stores that opted into `in_person_pos` when created
/// (or via Edit Store) — digital-only stores never see it.
class SellerQuickActions extends StatelessWidget {
  const SellerQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<SellerHomeController>();

    return Obx(() {
      List actions = [
        (
          icon: AppIcons.addIcon,
          label: 'Add Product',
          onTap: openAddProductOrRequireVerification,
        ),
        if (homeController.posEnabled.value)
          (
            icon: AppIcons.posIcon,
            label: 'Open POS',
            onTap: () => Get.toNamed(Routes.sellerPosManagement),
          ),
        (
          icon: AppIcons.aiStudioIcon,
          label: 'AI Studio',
          onTap: () => Get.toNamed(Routes.sellerAiStudio),
        ),
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
    });
  }
}
