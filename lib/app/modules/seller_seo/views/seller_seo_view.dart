import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_seo/controllers/seller_seo_controller.dart';
import 'package:book_store_app/app/modules/seller_seo/widgets/seo_overview_widgets.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerSeoView extends GetView<SellerSeoController> {
  const SellerSeoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'SEO'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        final dashboard = controller.dashboard.value;
        return CustomRefreshWrapper(
          onRefresh: controller.refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
            children: [
              if (dashboard != null) SeoCompletenessCard(data: dashboard),
              SizedBox(height: BaseSpacing.sm),
              SeoStoreMetaCard(controller: controller),
              SizedBox(height: BaseSpacing.sm),
              SeoChecklistCard(controller: controller),
              SizedBox(height: BaseSpacing.sm),
              _ManageProductsCard(onTap: () => Get.toNamed(Routes.sellerSeoProducts)),
            ],
          ),
        );
      }),
    );
  }
}

class _ManageProductsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ManageProductsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(BaseSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Product SEO',
                    color: AppColors.black2,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 2),
                  CustomText(
                    text: 'Edit per-product meta titles, apply a bulk template, or export a CSV',
                    color: AppColors.gray600,
                    fontSize: AppFontSize.tiny,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray600),
          ],
        ),
      ),
    );
  }
}
