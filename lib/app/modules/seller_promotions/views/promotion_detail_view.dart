import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/promotions/promotion_request_model.dart';
import 'package:book_store_app/app/modules/seller_activity_log/widgets/activity_log_tile.dart';
import 'package:book_store_app/app/modules/seller_promotions/controllers/promotion_detail_controller.dart';
import 'package:book_store_app/app/modules/seller_promotions/widgets/promotion_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Read-only detail screen for a single promotion request — header info
/// pulled straight from the [PromotionRequestModel] already held by the list
/// screen (no re-fetch needed), plus its activity timeline
/// (`PromotionsRepository.timeline`) rendered with the same
/// [ActivityLogTile] the seller activity-log screen uses.
class PromotionDetailView extends StatelessWidget {
  final PromotionRequestModel request;

  // Per-screen controller, intentionally re-put on each visit (same
  // convention as ProductDetail/Checkout) — GetX overwrites the previous
  // singleton for this type, so re-opening a different request's detail
  // page just replaces it.
  late final PromotionDetailController c;

  PromotionDetailView({super.key, required this.request}) {
    c = Get.put(PromotionDetailController(requestId: request.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: kPromotionPlacementLabels[request.placement] ?? request.placement),
      body: ListView(
        padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
        children: [
          _HeaderCard(request: request),
          SizedBox(height: BaseSpacing.lg),
          CustomText(
            text: 'Timeline',
            color: AppColors.black2,
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: BaseSpacing.sm),
          Obx(() {
            if (c.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
              );
            }
            if (c.logs.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: BaseSpacing.xl),
                child: Center(
                  child: CustomText(
                    text: 'No activity recorded yet.',
                    fontSize: AppFontSize.tiny,
                    color: AppColors.gray600,
                  ),
                ),
              );
            }
            return Column(children: c.logs.map((log) => ActivityLogTile(log: log)).toList());
          }),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final PromotionRequestModel request;
  const _HeaderCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(BaseRadius.md),
            child: CommonImageView(
              url: request.creativeUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: BaseSpacing.sm),
          Row(
            children: [
              Expanded(
                child: CustomText(
                  text: kPromotionPlacementLabels[request.placement] ?? request.placement,
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black2,
                ),
              ),
              CustomText(
                text: '\$${request.priceUSD.toStringAsFixed(2)}',
                fontSize: AppFontSize.medium,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryColor,
                fontFamily: AppTextStyles.monoFontFamily,
              ),
            ],
          ),
          SizedBox(height: BaseSpacing.xxs),
          Wrap(
            spacing: BaseSpacing.xxs,
            runSpacing: BaseSpacing.xxs,
            children: [
              _InfoPill(text: promotionStatusLabel(request.status), color: promotionStatusColor(request.status)),
              _InfoPill(
                text: request.isPaid ? 'Paid' : 'Payment ${request.paymentStatus}',
                color: request.isPaid ? AppColors.greenSuccess : AppColors.amberDark,
              ),
            ],
          ),
          SizedBox(height: BaseSpacing.sm),
          CustomText(
            text:
                '${DateFormat('MMM d, yyyy · h:mm a').format(request.startAt.toLocal())} — ${DateFormat('MMM d, yyyy · h:mm a').format(request.endAt.toLocal())}',
            fontSize: AppFontSize.tiny,
            color: AppColors.gray600,
          ),
          if (request.ctaLabel != null && request.ctaLabel!.isNotEmpty) ...[
            SizedBox(height: BaseSpacing.xs),
            CustomText(text: 'CTA: ${request.ctaLabel}', fontSize: AppFontSize.tiny, color: AppColors.gray600),
          ],
          if (request.linkTarget != null && request.linkTarget!.isNotEmpty) ...[
            SizedBox(height: 2),
            CustomText(
              text: 'Links to (${request.linkType}): ${request.linkTarget}',
              fontSize: AppFontSize.tiny,
              color: AppColors.gray600,
            ),
          ],
          if (request.message != null && request.message!.isNotEmpty) ...[
            SizedBox(height: BaseSpacing.xs),
            CustomText(text: 'Note to reviewer: ${request.message}', fontSize: AppFontSize.tiny, color: AppColors.gray600),
          ],
          if (request.isRejected && (request.rejectionReason?.isNotEmpty ?? false)) ...[
            SizedBox(height: BaseSpacing.xs),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: BaseSpacing.xxs),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(BaseRadius.sm),
              ),
              child: CustomText(
                text: 'Rejected: ${request.rejectionReason}',
                fontSize: AppFontSize.tiny,
                color: AppColors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  final Color color;
  const _InfoPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxs + 3, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(BaseRadius.pill)),
      child: CustomText(text: text, fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
    );
  }
}
