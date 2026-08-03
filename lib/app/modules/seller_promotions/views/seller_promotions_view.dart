import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_promotions/controllers/seller_promotions_controller.dart';
import 'package:book_store_app/app/modules/seller_promotions/views/promotion_create_view.dart';
import 'package:book_store_app/app/modules/seller_promotions/widgets/promotion_analytics_section.dart';
import 'package:book_store_app/app/modules/seller_promotions/widgets/promotion_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Seller-facing entry point for paid ad-placement requests
/// (`solvexo-api`'s `src/promotions`) — analytics rollup, list of the
/// store's requests with pay/cancel actions, and the "+ New Promotion" CTA
/// that pushes [PromotionCreateView].
class SellerPromotionsView extends GetView<SellerPromotionsController> {
  const SellerPromotionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Promotions'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        return CustomRefreshWrapper(
          onRefresh: controller.refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
            children: [
              PrimaryButton(label: '+ New Promotion', onPressed: () => _openCreate(context)),
              SizedBox(height: BaseSpacing.md),
              PromotionAnalyticsSection(data: controller.analytics.value),
              SizedBox(height: BaseSpacing.lg),
              CustomText(
                text: 'Your Requests',
                color: AppColors.black2,
                fontSize: AppFontSize.small2,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: BaseSpacing.sm),
              if (controller.requests.isEmpty)
                const _EmptyState()
              else
                ...controller.requests.map((r) => PromotionCard(request: r, controller: controller)),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final created = await Get.to<bool>(() => PromotionCreateView());
    if (created == true) controller.refresh();
  }
}

/// Deliberately gentle copy — a store with no requests yet and a store
/// whose plan doesn't include promotions (backend returns an empty list
/// either way, see `PromotionsRepository.list`'s error-swallowing) look
/// identical from here, so this never reads as an alarming error state.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxl),
      child: Column(
        children: [
          const Icon(Icons.campaign_outlined, size: 40, color: AppColors.lightGrey7),
          SizedBox(height: BaseSpacing.sm),
          CustomText(
            text: 'No promotions yet',
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.w700,
            color: AppColors.black2,
          ),
          SizedBox(height: BaseSpacing.xxs),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.lg),
            child: CustomText(
              text:
                  'Get your store featured in a shared homepage or marketplace placement. If this isn\'t available on your plan yet, you\'ll see a note when you submit a request.',
              fontSize: AppFontSize.tiny,
              color: AppColors.gray600,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
