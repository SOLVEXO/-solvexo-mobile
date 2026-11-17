import 'package:book_store_app/app/modules/seller/utils/seller_store_gate.dart';
import 'package:book_store_app/app/modules/seller_home/widgets/custom_action_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerQuickActions extends StatelessWidget {
  const SellerQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 140,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: CustomActionCard(
                icon: AppIcons.addIcon,
                label: 'Add Product',
                subtitle: 'List a new item',
                highlighted: true,
                onTap: openAddProductOrRequireVerification,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                    child: CustomActionCard(
                      icon: AppIcons.aiStudioIcon,
                      label: 'AI Studio',
                      subtitle: 'Create with AI',
                      onTap: () => Get.toNamed(Routes.sellerAiStudio),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: CustomActionCard(
                      icon: AppIcons.anylaticsIcon,
                      label: 'Analytics',
                      subtitle: 'Track sales',
                      onTap: () => Get.toNamed(Routes.sellerAnalytics),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
