import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/subscriptions/subscription_plan_model.dart';
import 'package:book_store_app/app/modules/seller_subscriptions/controllers/seller_subscriptions_controller.dart';
import 'package:book_store_app/app/modules/seller_subscriptions/widgets/subscriptions_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionPlansTab extends StatelessWidget {
  final SellerSubscriptionsController controller;
  const SubscriptionPlansTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          if (controller.isLoadingPlans.value) return const SubscriptionsShimmer();

          if (controller.plans.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(BaseSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_outlined, size: 48, color: AppColors.lightGrey),
                    SizedBox(height: BaseSpacing.sm),
                    Text('No subscription plans yet', style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: BaseSpacing.xxs),
                    Text('Create a plan buyers can subscribe to for recurring revenue.', style: BaseTypography.labelSmall(color: AppColors.gray600), textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return CustomRefreshWrapper(
            onRefresh: controller.loadPlans,
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
              itemCount: controller.plans.length,
              separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
              itemBuilder: (_, i) {
                final plan = controller.plans[i];
                return _PlanCard(
                  plan: plan,
                  onEdit: () => _PlanFormSheet.show(context, controller, existing: plan),
                  onArchive: () => _confirmArchive(context, plan),
                );
              },
            ),
          );
        }),
        Positioned(
          right: BaseSpacing.md,
          bottom: BaseSpacing.md,
          child: FloatingActionButton.extended(
            heroTag: 'add_plan_fab',
            onPressed: () => _PlanFormSheet.show(context, controller),
            backgroundColor: AppColors.primaryColor,
            icon: const Icon(Icons.add_rounded, color: AppColors.white),
            label: Text('New Plan', style: BaseTypography.bodySmall(color: AppColors.white).copyWith(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  void _confirmArchive(BuildContext context, SubscriptionPlanModel plan) {
    CustomConfirmDialog.show(
      context,
      title: 'Archive "${plan.name}"?',
      message: plan.subscriberCount > 0
          ? '${plan.subscriberCount} buyer(s) are currently subscribed. They will keep their subscription until they cancel, but new subscribers can\'t join.'
          : 'This plan will no longer be available to new subscribers.',
      confirmLabel: 'Archive',
      confirmColor: AppColors.red,
      onConfirm: () => controller.archivePlan(plan, force: plan.subscriberCount > 0),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlanModel plan;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  const _PlanCard({required this.plan, required this.onEdit, required this.onArchive});

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
          border: Border.all(color: plan.isActive ? AppColors.primaryColor.withOpacity(0.15) : AppColors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(plan.name, style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
                ),
                if (!plan.isActive)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.gray600.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.pill)),
                    child: Text('Archived', style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(fontWeight: FontWeight.w700, fontSize: 10.5)),
                  ),
                IconButton(icon: Icon(Icons.archive_outlined, size: 18, color: AppColors.gray600), onPressed: onArchive),
              ],
            ),
            Text(
              '\$${plan.displayMonthlyPrice.toStringAsFixed(2)} ${plan.displayCurrency}/mo'
              '${plan.yearlyPriceUSD != null ? ' · \$${plan.yearlyPriceUSD!.toStringAsFixed(2)}/yr' : ''}',
              style: BaseTypography.bodySmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w700),
            ),
            if (plan.features.isNotEmpty) ...[
              SizedBox(height: BaseSpacing.xs),
              ...plan.features.take(3).map((f) => Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 13, color: AppColors.greenSuccess),
                        SizedBox(width: BaseSpacing.xxs),
                        Expanded(child: Text(f, style: BaseTypography.labelSmall(color: AppColors.gray600), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  )),
            ],
            SizedBox(height: BaseSpacing.xs),
            Row(
              children: [
                Icon(Icons.groups_outlined, size: 13, color: AppColors.gray600),
                SizedBox(width: BaseSpacing.xxs / 2),
                Text('${plan.subscriberCount} subscribers', style: BaseTypography.labelSmall(color: AppColors.gray600)),
                SizedBox(width: BaseSpacing.sm),
                Icon(Icons.trending_up_rounded, size: 13, color: AppColors.gray600),
                SizedBox(width: BaseSpacing.xxs / 2),
                Text('\$${plan.monthlyRecurringRevenueUSD.toStringAsFixed(0)}/mo MRR', style: BaseTypography.labelSmall(color: AppColors.gray600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanFormSheet extends StatefulWidget {
  final SellerSubscriptionsController controller;
  final SubscriptionPlanModel? existing;
  const _PlanFormSheet({required this.controller, this.existing});

  static void show(BuildContext context, SellerSubscriptionsController controller, {SubscriptionPlanModel? existing}) {
    Get.bottomSheet(
      _PlanFormSheet(controller: controller, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<_PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends State<_PlanFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _monthlyCtrl;
  late final TextEditingController _yearlyCtrl;
  late final TextEditingController _featuresCtrl;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _monthlyCtrl = TextEditingController(text: e?.monthlyPriceUSD.toString() ?? '');
    _yearlyCtrl = TextEditingController(text: e?.yearlyPriceUSD?.toString() ?? '');
    _featuresCtrl = TextEditingController(text: e?.features.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _monthlyCtrl.dispose();
    _yearlyCtrl.dispose();
    _featuresCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final monthly = double.tryParse(_monthlyCtrl.text.trim());
    if (name.isEmpty || monthly == null || monthly <= 0) return;

    final yearly = double.tryParse(_yearlyCtrl.text.trim());
    final features = _featuresCtrl.text.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList();
    final description = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();

    bool ok;
    if (_isEdit) {
      ok = await widget.controller.updatePlan(
        widget.existing!,
        name: name,
        description: description,
        monthlyPriceUSD: monthly,
        yearlyPriceUSD: yearly,
        features: features,
      );
    } else {
      ok = await widget.controller.createPlan(
        name: name,
        description: description,
        monthlyPriceUSD: monthly,
        yearlyPriceUSD: yearly,
        features: features,
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
                  Text(_isEdit ? 'Edit Plan' : 'Create Plan', style: BaseTypography.titleMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: BaseSpacing.md),
                  CustomTextField(label: 'Plan Name', hintText: 'e.g. Pro Plan', controller: _nameCtrl, isborder: true),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(label: 'Description (optional)', controller: _descCtrl, isborder: true, maxLines: 2),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(label: 'Monthly Price (USD)', controller: _monthlyCtrl, isborder: true, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(label: 'Yearly Price (USD, optional)', controller: _yearlyCtrl, isborder: true, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(label: 'Features, comma separated', hintText: 'Priority support, Advanced analytics', controller: _featuresCtrl, isborder: true, maxLines: 2),
                  SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => GestureDetector(
                      onTap: widget.controller.isSavingPlan.value ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(BaseRadius.md)),
                        child: widget.controller.isSavingPlan.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : Text(_isEdit ? 'Save Changes' : 'Create Plan', style: BaseTypography.bodyLarge(color: AppColors.white).copyWith(fontWeight: FontWeight.w700)),
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
}
