import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/stores/controllers/stores_controller.dart';
import 'package:book_store_app/app/modules/stores/widgets/store_card.dart';
import 'package:book_store_app/app/modules/stores/widgets/store_sort_chips.dart';
import 'package:book_store_app/app/modules/stores/widgets/stores_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoresView extends StatelessWidget {
  StoresView({super.key});

  final StoresController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        title: CustomText(
          text: 'Stores',
          color: AppColors.textPrimary,
          fontSize: AppFontSize.small2,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: BaseSpacing.sm),
            StoreSortChips(),
            SizedBox(height: BaseSpacing.sm),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const StoresShimmer();

                if (controller.stores.isEmpty) return _EmptyState();

                return CustomRefreshWrapper(
                  onRefresh: controller.refreshStores,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200) {
                        controller.loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimen.allPadding,
                        vertical: BaseSpacing.sm,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.stores.length + (controller.hasMore.value ? 1 : 0),
                      separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
                      itemBuilder: (_, i) {
                        if (i >= controller.stores.length) {
                          return Obx(
                            () => controller.isFetchingMore.value
                                ? Padding(
                                    padding: EdgeInsets.all(BaseSpacing.md),
                                    child: const Center(child: CircularProgressIndicator()),
                                  )
                                : const SizedBox.shrink(),
                          );
                        }
                        return StoreCard(store: controller.stores[i]);
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(BaseSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(assetName: AppIcons.shoppingBag, size: 64, color: AppColors.greySwatch400),
            SizedBox(height: BaseSpacing.sm),
            CustomText(
              text: 'No stores found',
              color: AppColors.gray600,
              fontSize: AppFontSize.tiny,
            ),
          ],
        ),
      ),
    );
  }
}
