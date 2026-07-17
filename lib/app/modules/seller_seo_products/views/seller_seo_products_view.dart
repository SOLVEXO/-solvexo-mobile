import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_seo_products/controllers/seller_seo_products_controller.dart';
import 'package:book_store_app/app/modules/seller_seo_products/widgets/seo_product_widgets.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerSeoProductsView extends GetView<SellerSeoProductsController> {
  const SellerSeoProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Product SEO'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        return CustomRefreshWrapper(
          onRefresh: controller.refresh,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => OutlineButton(
                          label: 'Bulk Template',
                          compact: true,
                          isLoading: controller.isApplyingTemplate.value,
                          onPressed: () => BulkTemplateFormSheet.show(context, controller),
                        ),
                      ),
                    ),
                    SizedBox(width: BaseSpacing.sm),
                    Expanded(
                      child: Obx(
                        () => OutlineButton(
                          label: 'Export CSV',
                          compact: true,
                          isLoading: controller.isExporting.value,
                          onPressed: controller.exportCsv,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.products.isEmpty) {
                    return Center(
                      child: CustomText(
                        text: 'No products found',
                        color: AppColors.gray600,
                        fontSize: AppFontSize.small2,
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
                    itemCount: controller.products.length + (controller.hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.products.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: BaseSpacing.md),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                          ),
                        );
                      }
                      final product = controller.products[index];
                      return SeoProductTile(product: product, controller: controller);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}
