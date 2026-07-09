import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/app/modules/seller_home/widgets/custom_action_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerQuickActions extends StatelessWidget {
  const SellerQuickActions({super.key});

  void _onPosActionTap(SellerHomeController controller) {
    if (controller.hasPosSubscription.value) {
      Get.toNamed(Routes.sellerPosManagement);
    } else {
      _showPosOfferSheet(controller);
    }
  }

  void _showPosOfferSheet(SellerHomeController controller) {
    Get.bottomSheet(
      _PosOfferSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SellerHomeController>();
    List actions = [
      (
        icon: AppIcons.addIcon,
        label: 'Add Product',
        onTap: () => Get.toNamed(Routes.addSellerProduct),
      ),
      (
        icon: AppIcons.posIcon,
        label: 'Open POS',
        onTap: () => _onPosActionTap(controller),
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
  }
}

class _PosOfferSheet extends StatelessWidget {
  final SellerHomeController controller;
  const _PosOfferSheet({required this.controller});

  Future<void> _onSubscribeTap() async {
    if (!controller.posAddonEligible.value) {
      Get.back();
      Get.toNamed(Routes.sellerPlatformPlan);
      return;
    }
    final ok = await controller.subscribeToPosAddon();
    if (ok) {
      Get.back();
      Get.toNamed(Routes.sellerPosManagement);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _Header(),
          const SizedBox(height: 24),
          _FeaturesList(),
          const SizedBox(height: 24),
          _PricingCard(),
          const SizedBox(height: 20),
          Obx(() {
            if (!controller.posAddonEligible.value) {
              return Column(
                children: [
                  const CustomText(
                    text: 'Requires Basic tier or above to unlock the POS add-on.',
                    textAlign: TextAlign.center,
                    fontSize: 13,
                    color: AppColors.lightGrey5,
                  ),
                  const SizedBox(height: 12),
                  AppButton(label: 'Upgrade Plan', onPressed: _onSubscribeTap),
                ],
              );
            }
            return AppButton(
              label: controller.isPosActionLoading.value ? 'Subscribing...' : 'Subscribe Now',
              onPressed: controller.isPosActionLoading.value ? null : _onSubscribeTap,
            );
          }),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.appbarGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.point_of_sale_rounded,
            color: AppColors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const CustomText(
          text: 'Unlock POS System',
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.black2,
        ),
        const SizedBox(height: 8),
        const CustomText(
          text: 'Accept in-store payments, manage walk-in orders,\nand sync your inventory in real time.',
          textAlign: TextAlign.center,
          fontSize: 14,
          color: AppColors.lightGrey5,
          height: 1.5,
        ),
      ],
    );
  }
}

class _FeaturesList extends StatelessWidget {
  const _FeaturesList();

  static const _features = [
    (icon: Icons.receipt_long_rounded, text: 'Fast in-store checkout'),
    (icon: Icons.inventory_2_rounded, text: 'Real-time inventory sync'),
    (icon: Icons.bar_chart_rounded, text: 'Daily sales reports'),
    (icon: Icons.payments_rounded, text: 'Cash & card payment support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      f.icon,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomText(
                    text: f.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black2,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppColors.appbarGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'POS Add-on Plan',
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: 4),
              CustomText(
                text: 'Billed monthly · Cancel anytime',
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '\$29',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: '/mo',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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
