import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/loyalty/loyalty_member_model.dart';
import 'package:book_store_app/app/modules/seller_loyalty/controllers/seller_loyalty_controller.dart';
import 'package:book_store_app/app/modules/seller_loyalty/widgets/loyalty_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LoyaltyMembersTab extends StatelessWidget {
  final SellerLoyaltyController controller;
  const LoyaltyMembersTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMembers.value) return const LoyaltyShimmer();

      if (controller.members.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(BaseSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups_outlined, size: 48, color: AppColors.lightGrey),
                SizedBox(height: BaseSpacing.sm),
                Text('No loyalty members yet', style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: BaseSpacing.xxs),
                Text('Members appear automatically once buyers start earning points.', style: BaseTypography.labelSmall(color: AppColors.gray600), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }

      return CustomRefreshWrapper(
        onRefresh: controller.loadMembers,
        child: ListView.separated(
          padding: EdgeInsets.all(BaseSpacing.md),
          itemCount: controller.members.length,
          separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
          itemBuilder: (_, i) {
            final member = controller.members[i];
            return _MemberCard(
              member: member,
              onTap: () => _openMemberSheet(context, member),
            );
          },
        ),
      );
    });
  }

  void _openMemberSheet(BuildContext context, LoyaltyMemberModel member) {
    Get.bottomSheet(
      _MemberDetailSheet(controller: controller, member: member),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _MemberCard extends StatelessWidget {
  final LoyaltyMemberModel member;
  final VoidCallback onTap;
  const _MemberCard({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = member.userName.trim().isNotEmpty ? member.userName.trim()[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(BaseSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(initials, style: BaseTypography.bodyMedium(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: BaseSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.userName, style: BaseTypography.bodySmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
                  if (member.currentTier != null)
                    Text(member.currentTier!, style: BaseTypography.labelSmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${member.pointsBalance}', style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w800)),
                Text('points', style: BaseTypography.labelSmall(color: AppColors.gray600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberDetailSheet extends StatefulWidget {
  final SellerLoyaltyController controller;
  final LoyaltyMemberModel member;
  const _MemberDetailSheet({required this.controller, required this.member});

  @override
  State<_MemberDetailSheet> createState() => _MemberDetailSheetState();
}

class _MemberDetailSheetState extends State<_MemberDetailSheet> {
  List<LoyaltyTransactionModel>? _transactions;

  @override
  void initState() {
    super.initState();
    widget.controller.getMemberTransactions(widget.member.id).then((t) {
      if (mounted) setState(() => _transactions = t);
    });
  }

  void _showAwardDialog() {
    final pointsCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String type = 'adjustment';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.md, BaseSpacing.lg, MediaQuery.of(context).viewInsets.bottom + BaseSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Award or Deduct Points', style: BaseTypography.titleSmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: BaseSpacing.md),
              CustomTextField(label: 'Points (negative to deduct)', controller: pointsCtrl, isborder: true, keyboardType: const TextInputType.numberWithOptions(signed: true)),
              SizedBox(height: BaseSpacing.sm),
              CustomTextField(label: 'Reason', controller: descCtrl, isborder: true),
              SizedBox(height: BaseSpacing.sm),
              Wrap(
                spacing: BaseSpacing.xs,
                children: ['adjustment', 'birthday', 'referral'].map((t) {
                  final selected = type == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: selected,
                    onSelected: (_) => setSheetState(() => type = t),
                    selectedColor: AppColors.primaryColor.withOpacity(0.15),
                  );
                }).toList(),
              ),
              SizedBox(height: BaseSpacing.md),
              GestureDetector(
                onTap: () async {
                  final points = int.tryParse(pointsCtrl.text.trim());
                  final desc = descCtrl.text.trim();
                  if (points == null || points == 0 || desc.isEmpty) return;
                  final ok = await widget.controller.awardPoints(widget.member.id, points: points, type: type, description: desc);
                  if (ok) Get.back();
                },
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(BaseRadius.md)),
                  child: Text('Apply', style: BaseTypography.bodySmall(color: AppColors.white).copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: BaseSpacing.sm),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: EdgeInsets.all(BaseSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.member.userName, style: BaseTypography.titleMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.bold)),
                      Text('${widget.member.pointsBalance} points · ${widget.member.lifetimePoints} lifetime', style: BaseTypography.labelSmall(color: AppColors.gray600)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _showAwardDialog,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
                    decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.pill)),
                    child: Text('Award Points', style: BaseTypography.labelSmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _transactions == null
                ? const Center(child: CircularProgressIndicator())
                : _transactions!.isEmpty
                    ? Center(child: Text('No transaction history yet', style: BaseTypography.labelSmall(color: AppColors.gray600)))
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.lg),
                        itemCount: _transactions!.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.lightGrey3),
                        itemBuilder: (_, i) {
                          final tx = _transactions![i];
                          final positive = tx.points >= 0;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: BaseSpacing.sm),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tx.description ?? tx.type, style: BaseTypography.bodySmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w600)),
                                      if (tx.createdAt != null)
                                        Text(DateFormat('MMM d, yyyy · h:mm a').format(tx.createdAt!.toLocal()), style: BaseTypography.labelSmall(color: AppColors.gray600)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${positive ? '+' : ''}${tx.points}',
                                  style: BaseTypography.bodyMedium(color: positive ? AppColors.greenSuccess : AppColors.red).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
