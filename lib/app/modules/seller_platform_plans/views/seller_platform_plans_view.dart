import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_platform_plans/controllers/seller_platform_plans_controller.dart';
import 'package:book_store_app/app/modules/seller_platform_plans/widgets/platform_plan_widgets.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
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

        final sub = controller.myPlan.value;
        final entitlements = controller.entitlements.value;

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
              if (sub != null) MyPlanCard(sub: sub),
              if (sub != null) SizedBox(height: BaseSpacing.sm),
              if (entitlements != null) UsageCard(data: entitlements),
              if (entitlements != null) SizedBox(height: BaseSpacing.sm),
              AddonsCard(controller: controller),
              SizedBox(height: BaseSpacing.sm),
              BillingHistoryCard(controller: controller),
              SizedBox(height: BaseSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: 'Compare Plans',
                      color: AppColors.black2,
                      fontSize: AppFontSize.small2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  BillingIntervalToggle(controller: controller),
                ],
              ),
              SizedBox(height: BaseSpacing.sm),
              Obx(() {
                if (controller.plans.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: BaseSpacing.xl),
                    child: Center(
                      child: CustomText(
                        text: 'No plans available right now',
                        color: AppColors.gray600,
                        fontSize: AppFontSize.tiny,
                      ),
                    ),
                  );
                }
                return Column(
                  children: controller.plans
                      .map(
                        (plan) => Padding(
                          padding: EdgeInsets.only(bottom: BaseSpacing.sm),
                          child: PlanCard(
                            plan: plan,
                            isCurrent: controller.isCurrentPlan(plan),
                            isYearly: controller.billingInterval.value == 'yearly',
                            controller: controller,
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
