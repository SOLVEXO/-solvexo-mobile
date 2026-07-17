import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/repositories/platform_plans_repository.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shown whenever a generate call comes back `402 INSUFFICIENT_AI_CREDITS`.
/// Reuses the existing platform add-on purchase flow (`extra_ai_credits`,
/// 500 credits/unit) — no separate AI Studio payment path.
class InsufficientCreditsSheet extends StatefulWidget {
  final String storeId;
  final int? required;
  final int? balance;
  final String? message;

  const InsufficientCreditsSheet({
    super.key,
    required this.storeId,
    this.required,
    this.balance,
    this.message,
  });

  /// Returns true if the seller successfully bought more credits.
  static Future<bool> show({
    required String storeId,
    int? required,
    int? balance,
    String? message,
  }) async {
    final result = await Get.bottomSheet<bool>(
      InsufficientCreditsSheet(storeId: storeId, required: required, balance: balance, message: message),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    return result ?? false;
  }

  @override
  State<InsufficientCreditsSheet> createState() => _InsufficientCreditsSheetState();
}

class _InsufficientCreditsSheetState extends State<InsufficientCreditsSheet> {
  final _repo = PlatformPlansRepository();
  bool _purchasing = false;

  Future<void> _buy() async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    final ok = await _repo.purchaseAddon(widget.storeId, addonType: 'extra_ai_credits');
    if (!mounted) return;
    setState(() => _purchasing = false);
    if (ok) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.lg, BaseSpacing.md, BaseSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: '💳', fontSize: AppFontSize.veryLarge2),
            SizedBox(height: BaseSpacing.sm),
            CustomText(
              text: 'Not enough AI credits',
              color: AppColors.black2,
              fontSize: AppFontSize.medium,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: BaseSpacing.xs),
            CustomText(
              text: widget.message ??
                  (widget.required != null && widget.balance != null
                      ? 'This generation costs ${widget.required} credits — you have ${widget.balance}.'
                      : 'You need more AI credits to run this generation.'),
              color: AppColors.gray600,
              fontSize: AppFontSize.verySmall,
            ),
            SizedBox(height: BaseSpacing.lg),
            PrimaryButton(
              label: 'Buy 500 credits',
              isLoading: _purchasing,
              onPressed: _buy,
            ),
            SizedBox(height: BaseSpacing.xs),
            GhostButton(label: 'Cancel', onPressed: () => Get.back(result: false)),
          ],
        ),
      ),
    );
  }
}
