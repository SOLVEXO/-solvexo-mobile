import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/base_empty_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/help_center_controller.dart';
import '../models/faq_model.dart';
import 'faq_tile.dart';

/// Shared FAQ list body — loading shimmer / empty state / result cards —
/// used by both the Help Centre home and the "all topics" list so the two
/// screens stay visually identical instead of hand-rolling this twice.
class FaqStatusList extends StatelessWidget {
  final void Function(FaqModel faq) onTapFaq;
  final Widget? footer;
  final EdgeInsetsGeometry padding;

  const FaqStatusList({
    super.key,
    required this.onTapFaq,
    this.footer,
    this.padding = const EdgeInsets.symmetric(horizontal: BaseSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaqController>();
    return Obx(() {
      if (controller.isLoading.value && controller.filteredFaqs.isEmpty) {
        return ListView.builder(
          padding: padding,
          itemCount: 5,
          itemBuilder: (_, __) => const _FaqTileSkeleton(),
        );
      }

      if (controller.filteredFaqs.isEmpty) {
        return ListView(
          padding: padding,
          children: [
            SizedBox(height: BaseSpacing.xxl),
            BaseEmptyView(
              icon: Icons.help_outline_rounded,
              title: controller.searchQuery.value.isNotEmpty
                  ? 'No matching FAQs'
                  : 'No FAQs available',
              subtitle: controller.searchQuery.value.isNotEmpty
                  ? "We couldn't find anything for \"${controller.searchQuery.value}\". Try a different search."
                  : 'Check back soon — help articles will appear here.',
            ),
          ],
        );
      }

      return ListView.builder(
        padding: padding,
        itemCount: controller.filteredFaqs.length + (footer != null ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == controller.filteredFaqs.length) return footer!;
          final faq = controller.filteredFaqs[i];
          return FaqTile(faq: faq, onTap: () => onTapFaq(faq));
        },
      );
    });
  }
}

class _FaqTileSkeleton extends StatelessWidget {
  const _FaqTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseSpacing.sm),
      child: Container(
        padding: EdgeInsets.all(BaseSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Row(
          children: [
            const Skeleton(width: 36, height: 36, cornerRadius: 18),
            SizedBox(width: BaseSpacing.sm + 2),
            const Expanded(child: Skeleton(height: 14, width: double.infinity)),
          ],
        ),
      ),
    );
  }
}
