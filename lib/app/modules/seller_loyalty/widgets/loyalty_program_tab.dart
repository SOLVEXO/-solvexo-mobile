import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/loyalty/loyalty_program_model.dart';
import 'package:book_store_app/app/modules/seller_loyalty/controllers/seller_loyalty_controller.dart';
import 'package:book_store_app/app/modules/seller_loyalty/widgets/loyalty_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoyaltyProgramTab extends StatefulWidget {
  final SellerLoyaltyController controller;
  const LoyaltyProgramTab({super.key, required this.controller});

  @override
  State<LoyaltyProgramTab> createState() => _LoyaltyProgramTabState();
}

class _LoyaltyProgramTabState extends State<LoyaltyProgramTab> {
  late final TextEditingController _perDollarCtrl;
  late final TextEditingController _perReviewCtrl;
  late final TextEditingController _perReferralCtrl;
  late final TextEditingController _birthdayCtrl;
  late final TextEditingController _expiryCtrl;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _perDollarCtrl = TextEditingController();
    _perReviewCtrl = TextEditingController();
    _perReferralCtrl = TextEditingController();
    _birthdayCtrl = TextEditingController();
    _expiryCtrl = TextEditingController();
  }

  void _seed(LoyaltyProgramModel p) {
    if (_seeded) return;
    _seeded = true;
    _perDollarCtrl.text = '${p.pointsPerDollar}';
    _perReviewCtrl.text = '${p.pointsPerReview}';
    _perReferralCtrl.text = '${p.pointsPerReferral}';
    _birthdayCtrl.text = '${p.birthdayBonusPoints}';
    _expiryCtrl.text = p.pointsExpiryMonths?.toString() ?? '';
  }

  @override
  void dispose() {
    _perDollarCtrl.dispose();
    _perReviewCtrl.dispose();
    _perReferralCtrl.dispose();
    _birthdayCtrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Obx(() {
      if (c.isLoadingProgram.value) return const LoyaltyShimmer();

      final program = c.program.value;
      _seed(program);

      return ListView(
        padding: EdgeInsets.all(BaseSpacing.md),
        children: [
          _SectionCard(
            title: 'Program Status',
            trailing: Switch(
              value: program.isEnabled,
              activeColor: AppColors.primaryColor,
              onChanged: c.isSavingProgram.value ? null : c.toggleEnabled,
            ),
            child: Text(
              program.isEnabled
                  ? 'Buyers can earn and redeem points at your store.'
                  : 'Enable to let buyers start earning points on purchases.',
              style: BaseTypography.labelSmall(color: AppColors.gray600),
            ),
          ),
          SizedBox(height: BaseSpacing.md),
          _SectionCard(
            title: 'Earning Rules',
            child: Column(
              children: [
                _NumberField(label: 'Points per \$1 spent', controller: _perDollarCtrl),
                SizedBox(height: BaseSpacing.sm),
                _NumberField(label: 'Points per review', controller: _perReviewCtrl),
                SizedBox(height: BaseSpacing.sm),
                _NumberField(label: 'Points per referral', controller: _perReferralCtrl),
                SizedBox(height: BaseSpacing.sm),
                _NumberField(label: 'Birthday bonus points', controller: _birthdayCtrl),
                SizedBox(height: BaseSpacing.sm),
                _NumberField(label: 'Points expiry (months, blank = never)', controller: _expiryCtrl),
                SizedBox(height: BaseSpacing.sm),
                _SaveButton(
                  isSaving: c.isSavingProgram.value,
                  label: 'Save Earning Rules',
                  onTap: () async {
                    await c.updateEarningRules(
                      pointsPerDollar: int.tryParse(_perDollarCtrl.text.trim()) ?? 0,
                      pointsPerReview: int.tryParse(_perReviewCtrl.text.trim()) ?? 0,
                      pointsPerReferral: int.tryParse(_perReferralCtrl.text.trim()) ?? 0,
                      birthdayBonusPoints: int.tryParse(_birthdayCtrl.text.trim()) ?? 0,
                    );
                    await c.updatePointsExpiry(int.tryParse(_expiryCtrl.text.trim()));
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: BaseSpacing.md),
          _TiersEditor(controller: c, tiers: program.tiers),
          SizedBox(height: BaseSpacing.xxl),
        ],
      );
    });
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _NumberField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      controller: controller,
      isborder: true,
      keyboardType: TextInputType.number,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final String label;
  final VoidCallback onTap;
  const _SaveButton({required this.isSaving, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 46),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(BaseRadius.md)),
        child: isSaving
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
            : Text(label, style: BaseTypography.bodySmall(color: AppColors.white).copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: BaseSpacing.sm),
          child,
        ],
      ),
    );
  }
}

// ─── Tiers editor ────────────────────────────────────────────────────────────

class _TiersEditor extends StatelessWidget {
  final SellerLoyaltyController controller;
  final List<LoyaltyTierModel> tiers;
  const _TiersEditor({required this.controller, required this.tiers});

  void _openTierSheet(BuildContext context, {LoyaltyTierModel? existing, int? index}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final minPointsCtrl = TextEditingController(text: existing?.minPoints.toString() ?? '');
    final benefitsCtrl = TextEditingController(text: existing?.benefits.join(', ') ?? '');

    CustomConfirmDialog.show(
      context,
      title: existing != null ? 'Edit Tier' : 'Add Tier',
      confirmLabel: existing != null ? 'Save' : 'Add',
      contentBuilder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(hintText: 'Tier name (e.g. Gold)', controller: nameCtrl, isborder: true),
          SizedBox(height: BaseSpacing.sm),
          CustomTextField(hintText: 'Minimum lifetime points', controller: minPointsCtrl, isborder: true, keyboardType: TextInputType.number),
          SizedBox(height: BaseSpacing.sm),
          CustomTextField(hintText: 'Benefits, comma separated', controller: benefitsCtrl, isborder: true),
        ],
      ),
      onConfirm: () {
        final name = nameCtrl.text.trim();
        final minPoints = int.tryParse(minPointsCtrl.text.trim());
        if (name.isEmpty || minPoints == null) return;
        final benefits = benefitsCtrl.text.split(',').map((b) => b.trim()).where((b) => b.isNotEmpty).toList();

        final updated = List<LoyaltyTierModel>.from(tiers);
        final newTier = LoyaltyTierModel(name: name, minPoints: minPoints, benefits: benefits);
        if (index != null) {
          updated[index] = newTier;
        } else {
          updated.add(newTier);
        }
        controller.updateTiers(updated);
      },
    );
  }

  void _deleteTier(int index) {
    final updated = List<LoyaltyTierModel>.from(tiers)..removeAt(index);
    controller.updateTiers(updated);
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Loyalty Tiers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tiers.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.sm),
              child: Text('No tiers configured yet. Add one to reward your most loyal buyers.', style: BaseTypography.labelSmall(color: AppColors.gray600)),
            ),
          ...tiers.asMap().entries.map((entry) {
            final i = entry.key;
            final t = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: BaseSpacing.xs),
              padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs + 2),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(BaseRadius.md)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: BaseTypography.bodySmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
                        Text('${t.minPoints}+ lifetime points', style: BaseTypography.labelSmall(color: AppColors.gray600)),
                        if (t.benefits.isNotEmpty)
                          Text(t.benefits.join(' · '), style: BaseTypography.labelSmall(color: AppColors.gray600)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryColor),
                    onPressed: () => _openTierSheet(context, existing: t, index: i),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.red),
                    onPressed: () => _deleteTier(i),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: BaseSpacing.xs),
          GestureDetector(
            onTap: () => _openTierSheet(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.sm),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(BaseRadius.md),
              ),
              child: Text('+ Add Tier', style: BaseTypography.labelSmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
