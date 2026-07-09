import 'package:book_store_app/app/data/repositories/loyalty_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Compact banner shown on a store's storefront when it has an active
/// loyalty program (i.e. has published at least one reward) — taps through
/// to the buyer's points balance + redeemable rewards for that store. Hidden
/// entirely for stores that haven't set up rewards, so it never clutters a
/// storefront with an empty promise.
class StorefrontLoyaltyTeaser extends StatefulWidget {
  final String storeId;
  final String storeName;

  const StorefrontLoyaltyTeaser({super.key, required this.storeId, required this.storeName});

  @override
  State<StorefrontLoyaltyTeaser> createState() => _StorefrontLoyaltyTeaserState();
}

class _StorefrontLoyaltyTeaserState extends State<StorefrontLoyaltyTeaser> {
  final _repo = LoyaltyRepository();
  bool _hasRewards = false;

  @override
  void initState() {
    super.initState();
    if (widget.storeId.isNotEmpty) {
      _repo.getPublicRewards(widget.storeId).then((rewards) {
        if (mounted) setState(() => _hasRewards = rewards.isNotEmpty);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasRewards) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Get.toNamed(
          Routes.loyaltyRewards,
          arguments: {'storeId': widget.storeId, 'storeName': widget.storeName},
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md, vertical: BaseSpacing.sm + 2),
          decoration: BoxDecoration(
            gradient: AppColors.appbarGradient,
            borderRadius: BorderRadius.circular(BaseRadius.md),
          ),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard_rounded, color: AppColors.white, size: 20),
              SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: Text(
                  'Earn points on every order — view your rewards',
                  style: BaseTypography.labelSmall(color: AppColors.white).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
