import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/ai_studio/ai_tool_meta.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/ai_studio_hub_controller.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/ai_credits_card.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/ai_tool_grid_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiStudioHubView extends GetView<AiStudioHubController> {
  const AiStudioHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'AI Studio'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        final credits = controller.credits.value;

        return CustomRefreshWrapper(
          onRefresh: controller.refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
            children: [
              if (credits != null)
                AiCreditsCard(
                  credits: credits,
                  onBuyCredits: controller.buyCredits,
                  onViewHistory: controller.openHistory,
                ),
              SizedBox(height: BaseSpacing.lg),
              CustomText(
                text: 'Tools',
                color: AppColors.black2,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: BaseSpacing.sm),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: BaseSpacing.sm,
                crossAxisSpacing: BaseSpacing.sm,
                childAspectRatio: 0.92,
                children: AiToolMeta.all
                    .map(
                      (meta) => AiToolGridCard(
                        meta: meta,
                        costCredits: credits?.costFor(meta.toolType),
                        onTap: () => Get.toNamed(meta.route),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      }),
    );
  }
}
