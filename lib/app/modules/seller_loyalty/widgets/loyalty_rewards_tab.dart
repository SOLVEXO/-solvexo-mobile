import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/loyalty/reward_model.dart';
import 'package:book_store_app/app/modules/seller_loyalty/controllers/seller_loyalty_controller.dart';
import 'package:book_store_app/app/modules/seller_loyalty/widgets/loyalty_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoyaltyRewardsTab extends StatelessWidget {
  final SellerLoyaltyController controller;
  const LoyaltyRewardsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          if (controller.isLoadingRewards.value) return const LoyaltyShimmer();

          if (controller.rewards.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(BaseSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.card_giftcard_outlined, size: 48, color: AppColors.lightGrey),
                    SizedBox(height: BaseSpacing.sm),
                    Text('No rewards yet', style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: BaseSpacing.xxs),
                    Text('Add a reward buyers can redeem their points for.', style: BaseTypography.labelSmall(color: AppColors.gray600), textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return CustomRefreshWrapper(
            onRefresh: controller.loadRewards,
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
              itemCount: controller.rewards.length,
              separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
              itemBuilder: (_, i) {
                final reward = controller.rewards[i];
                return _RewardCard(
                  reward: reward,
                  onEdit: () => _RewardFormSheet.show(context, controller, existing: reward),
                  onToggleActive: () => controller.toggleRewardActive(reward),
                  onDelete: () => _confirmDelete(context, reward),
                );
              },
            ),
          );
        }),
        Positioned(
          right: BaseSpacing.md,
          bottom: BaseSpacing.md,
          child: FloatingActionButton.extended(
            heroTag: 'add_reward_fab',
            onPressed: () => _RewardFormSheet.show(context, controller),
            backgroundColor: AppColors.primaryColor,
            icon: const Icon(Icons.add_rounded, color: AppColors.white),
            label: Text('New Reward', style: BaseTypography.bodySmall(color: AppColors.white).copyWith(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, RewardModel reward) {
    CustomConfirmDialog.show(
      context,
      title: 'Delete "${reward.name}"?',
      message: 'Buyers will no longer be able to redeem this reward.',
      confirmLabel: 'Delete',
      confirmColor: AppColors.red,
      onConfirm: () => controller.deleteReward(reward),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  const _RewardCard({required this.reward, required this.onEdit, required this.onToggleActive, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onEdit,
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
              decoration: BoxDecoration(color: AppColors.accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.md)),
              alignment: Alignment.center,
              child: Icon(
                reward.isFixedDiscount ? Icons.local_offer_outlined : Icons.card_giftcard_outlined,
                color: AppColors.accentColor,
                size: 20,
              ),
            ),
            SizedBox(width: BaseSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reward.name, style: BaseTypography.bodySmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    '${reward.pointsCost} points'
                    '${reward.stockLimit != null ? ' · ${reward.redeemedCount}/${reward.stockLimit} redeemed' : ''}'
                    '${reward.isOutOfStock ? ' · Out of stock' : ''}',
                    style: BaseTypography.labelSmall(color: reward.isOutOfStock ? AppColors.red : AppColors.gray600),
                  ),
                ],
              ),
            ),
            Switch(value: reward.isActive, activeColor: AppColors.primaryColor, onChanged: (_) => onToggleActive()),
            IconButton(icon: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _RewardFormSheet extends StatefulWidget {
  final SellerLoyaltyController controller;
  final RewardModel? existing;
  const _RewardFormSheet({required this.controller, this.existing});

  static void show(BuildContext context, SellerLoyaltyController controller, {RewardModel? existing}) {
    Get.bottomSheet(
      _RewardFormSheet(controller: controller, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<_RewardFormSheet> createState() => _RewardFormSheetState();
}

class _RewardFormSheetState extends State<_RewardFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _pointsCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _productIdCtrl;
  late final TextEditingController _stockCtrl;
  String _type = 'fixed_discount';

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _pointsCtrl = TextEditingController(text: e?.pointsCost.toString() ?? '');
    _discountCtrl = TextEditingController(text: e?.discountValue?.toString() ?? '');
    _productIdCtrl = TextEditingController(text: e?.productId ?? '');
    _stockCtrl = TextEditingController(text: e?.stockLimit?.toString() ?? '');
    _type = e?.type ?? 'fixed_discount';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    _discountCtrl.dispose();
    _productIdCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final points = int.tryParse(_pointsCtrl.text.trim());
    if (name.isEmpty || points == null || points <= 0) return;

    final discount = double.tryParse(_discountCtrl.text.trim());
    final productId = _productIdCtrl.text.trim();
    final stock = int.tryParse(_stockCtrl.text.trim());

    bool ok;
    if (_isEdit) {
      ok = await widget.controller.updateReward(
        widget.existing!,
        name: name,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        pointsCost: points,
        type: _type,
        discountValue: _type == 'fixed_discount' ? discount : null,
        productId: _type == 'free_product' ? productId : null,
        stockLimit: stock,
      );
    } else {
      ok = await widget.controller.createReward(
        name: name,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        pointsCost: points,
        type: _type,
        discountValue: _type == 'fixed_discount' ? discount : null,
        productId: _type == 'free_product' ? productId : null,
        stockLimit: stock,
      );
    }
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.sm, BaseSpacing.lg, BaseSpacing.lg),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: EdgeInsets.only(bottom: BaseSpacing.md),
                      decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Text(_isEdit ? 'Edit Reward' : 'Create Reward', style: BaseTypography.titleMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: BaseSpacing.md),
                  CustomTextField(label: 'Reward Name', controller: _nameCtrl, isborder: true),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(label: 'Description (optional)', controller: _descCtrl, isborder: true, maxLines: 2),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(label: 'Points Cost', controller: _pointsCtrl, isborder: true, keyboardType: TextInputType.number),
                  SizedBox(height: BaseSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: _typeChip('fixed_discount', 'Discount')),
                      SizedBox(width: BaseSpacing.xs),
                      Expanded(child: _typeChip('free_product', 'Free Product')),
                    ],
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  if (_type == 'fixed_discount')
                    CustomTextField(label: 'Discount Value (\$)', controller: _discountCtrl, isborder: true, keyboardType: const TextInputType.numberWithOptions(decimal: true))
                  else
                    CustomTextField(label: 'Product ID', hintText: 'ID of the free product', controller: _productIdCtrl, isborder: true),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(label: 'Stock Limit (optional)', controller: _stockCtrl, isborder: true, keyboardType: TextInputType.number),
                  SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => GestureDetector(
                      onTap: widget.controller.isSavingReward.value ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(BaseRadius.md)),
                        child: widget.controller.isSavingReward.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : Text(_isEdit ? 'Save Changes' : 'Create Reward', style: BaseTypography.bodyLarge(color: AppColors.white).copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: AnimatedContainer(
        duration: BaseMotion.normal,
        padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs + 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : AppColors.background,
          borderRadius: BorderRadius.circular(BaseRadius.md),
        ),
        child: Text(label, style: BaseTypography.labelSmall(color: selected ? AppColors.white : AppColors.gray600).copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
