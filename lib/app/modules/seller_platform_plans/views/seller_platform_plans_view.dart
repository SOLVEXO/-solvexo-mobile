import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_platform_plans/controllers/seller_platform_plans_controller.dart';
import 'package:book_store_app/app/modules/seller_platform_plans/widgets/platform_plan_widgets.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerPlatformPlansView extends GetView<SellerPlatformPlansController> {
  const SellerPlatformPlansView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Plan & Billing'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final plan = controller.myPlan.value;
        return CustomRefreshWrapper(
          onRefresh: controller.refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              BaseSpacing.md,
              BaseSpacing.md,
              BaseSpacing.md,
              BaseSpacing.xxl * 2,
            ),
            children: [
              if (plan != null) MyPlanCard(plan: plan, controller: controller),
              SizedBox(height: BaseSpacing.sm),
              if (plan != null)
                PosAddonCard(plan: plan, controller: controller),
              SizedBox(height: BaseSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: 'Compare Plans',
                      color: AppColors.black2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  BillingIntervalToggle(controller: controller),
                ],
              ),
              SizedBox(height: BaseSpacing.sm),
              Obx(
                () => Column(
                  children: controller.tiers
                      .map(
                        (tier) => Padding(
                          padding: EdgeInsets.only(bottom: BaseSpacing.sm),
                          child: TierCard(
                            tier: tier,
                            isCurrent: controller.isCurrentTier(tier.tier),
                            isYearly:
                                controller.billingInterval.value == 'yearly',
                            controller: controller,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
