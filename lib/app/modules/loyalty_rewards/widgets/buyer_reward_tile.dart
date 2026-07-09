import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/loyalty/reward_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class BuyerRewardTile extends StatelessWidget {
  final RewardModel reward;
  final bool canAfford;
  final bool isRedeeming;
  final VoidCallback onRedeem;

  const BuyerRewardTile({
    super.key,
    required this.reward,
    required this.canAfford,
    required this.isRedeeming,
    required this.onRedeem,
  });

  bool get _disabled => !canAfford || reward.isOutOfStock || isRedeeming;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.md)),
            alignment: Alignment.center,
            child: Icon(
              reward.isFixedDiscount ? Icons.local_offer_outlined : Icons.card_giftcard_outlined,
              color: AppColors.accentColor,
              size: 22,
            ),
          ),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: reward.name, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                if (reward.description != null && reward.description!.isNotEmpty)
                  CustomText(text: reward.description!, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600, maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: BaseSpacing.xxs),
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 13, color: AppColors.primaryColor),
                    CustomText(text: '${reward.pointsCost} points', color: AppColors.primaryColor, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                    if (reward.isOutOfStock) ...[
                      SizedBox(width: BaseSpacing.xs),
                      CustomText(text: 'Out of stock', color: AppColors.red, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: BaseSpacing.xs),
          GestureDetector(
            onTap: _disabled ? null : onRedeem,
            child: Container(
              constraints: const BoxConstraints(minWidth: 76, minHeight: 36),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm),
              decoration: BoxDecoration(
                color: _disabled ? AppColors.lightGrey.withOpacity(0.5) : AppColors.primaryColor,
                borderRadius: BorderRadius.circular(BaseRadius.md),
              ),
              child: isRedeeming
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                  : CustomText(
                      text: 'Redeem',
                      color: _disabled ? AppColors.gray600 : AppColors.white,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w700,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
