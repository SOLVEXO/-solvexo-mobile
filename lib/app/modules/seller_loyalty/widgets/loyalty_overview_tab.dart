import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/data/models/loyalty/loyalty_overview_model.dart';
import 'package:book_store_app/app/modules/seller_loyalty/controllers/seller_loyalty_controller.dart';
import 'package:book_store_app/app/modules/seller_loyalty/widgets/loyalty_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoyaltyOverviewTab extends StatelessWidget {
  final SellerLoyaltyController controller;
  const LoyaltyOverviewTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingOverview.value) return const LoyaltyShimmer();

      final o = controller.overview.value;

      return CustomRefreshWrapper(
        onRefresh: controller.loadOverview,
        child: ListView(
          padding: EdgeInsets.all(BaseSpacing.md),
          children: [
            if (!o.programEnabled) _DisabledBanner(),
            if (!o.programEnabled) SizedBox(height: BaseSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: BaseSpacing.sm,
              mainAxisSpacing: BaseSpacing.sm,
              childAspectRatio: 1.7,
              children: [
                _StatCard(icon: Icons.groups_rounded, label: 'Members', value: '${o.programMembers}', color: AppColors.primaryColor),
                _StatCard(icon: Icons.bolt_rounded, label: 'Points Issued (30d)', value: _fmt(o.pointsIssuedLast30Days), color: AppColors.accentColor),
                _StatCard(icon: Icons.redeem_rounded, label: 'Points Redeemed', value: _fmt(o.pointsRedeemedTotal), color: AppColors.seaGreen),
                _StatCard(icon: Icons.attach_money_rounded, label: 'Revenue (30d)', value: '\$${o.revenueFromMembersLast30Days.toStringAsFixed(0)}', color: AppColors.darkGreen),
              ],
            ),
            if (o.memberDistribution.isNotEmpty) ...[
              SizedBox(height: BaseSpacing.md),
              _SectionCard(
                title: 'Tier Distribution',
                child: Column(
                  children: o.memberDistribution
                      .map((t) => Padding(
                            padding: EdgeInsets.only(bottom: BaseSpacing.sm),
                            child: _TierBar(tier: t),
                          ))
                      .toList(),
                ),
              ),
            ],
            if (o.pointsActivityLast30Days.isNotEmpty) ...[
              SizedBox(height: BaseSpacing.md),
              _SectionCard(
                title: 'Activity Breakdown (30d)',
                child: Column(
                  children: o.pointsActivityLast30Days.entries
                      .map((e) => _ActivityRow(type: e.key, points: e.value))
                      .toList(),
                ),
              ),
            ],
            SizedBox(height: BaseSpacing.xxl),
          ],
        ),
      );
    });
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _DisabledBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(BaseRadius.md),
        border: Border.all(color: AppColors.orange.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.orange),
          SizedBox(width: BaseSpacing.xs),
          Expanded(
            child: Text(
              'Loyalty program is disabled — buyers can\'t earn or redeem points. Enable it from the Program tab.',
              style: BaseTypography.labelSmall(color: AppColors.orange).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.sm)),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: color),
          ),
          SizedBox(height: BaseSpacing.xs),
          Text(value, style: BaseTypography.titleMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w800)),
          Text(label, style: BaseTypography.labelSmall(color: AppColors.gray600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

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
          Text(title, style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: BaseSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _TierBar extends StatelessWidget {
  final LoyaltyTierDistribution tier;
  const _TierBar({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(tier.tier, style: BaseTypography.labelSmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w600)),
            Text('${tier.members} · ${tier.percent}%', style: BaseTypography.labelSmall(color: AppColors.gray600)),
          ],
        ),
        SizedBox(height: BaseSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(BaseRadius.pill),
          child: LinearProgressIndicator(
            value: tier.percent / 100,
            minHeight: 6,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String type;
  final int points;
  const _ActivityRow({required this.type, required this.points});

  String get _label => switch (type) {
        'purchase' => 'Earned from purchases',
        'review' => 'Earned from reviews',
        'referral' => 'Earned from referrals',
        'birthday' => 'Birthday bonuses',
        'redeem' => 'Redeemed for rewards',
        'expire' => 'Expired',
        'adjustment' => 'Manual adjustments',
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    final positive = points >= 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxs + 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_label, style: BaseTypography.labelSmall(color: AppColors.black2)),
          Text(
            '${positive ? '+' : ''}$points',
            style: BaseTypography.labelSmall(color: positive ? AppColors.greenSuccess : AppColors.red).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
