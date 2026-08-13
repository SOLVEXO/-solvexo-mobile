import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/store_verification_model.dart';
import 'package:book_store_app/app/modules/store_verification/controllers/store_verification_controller.dart';
import 'package:book_store_app/app/modules/store_verification/widgets/verification_form_widgets.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Small local dot + line timeline for the verification's `history[]` —
/// adapted from the visual language of `myorders/widgets/status_stepper.dart`
/// (that one is a fixed 4-step horizontal tracker; this is an open-ended
/// vertical activity log, so it's a separate, purpose-built widget).
class VerificationHistorySection extends StatelessWidget {
  final StoreVerificationController c;
  const VerificationHistorySection({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: verificationCardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VerificationSectionTitle('HISTORY'),
          const SizedBox(height: 14),
          Obx(() {
            final entries = c.history;
            if (entries.isEmpty) {
              return const CustomText(
                text: 'No activity yet.',
                fontSize: AppFontSize.tiny,
                color: AppColors.lightGrey5,
              );
            }
            return Column(
              children: [
                for (int i = 0; i < entries.length; i++)
                  _TimelineTile(
                    entry: entries[i],
                    isLast: i == entries.length - 1,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final VerificationHistoryEntryModel entry;
  final bool isLast;

  const _TimelineTile({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 3),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.lightGrey2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
            ],
          ),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : BaseSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: _actionLabel(entry.action),
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black2,
                  ),
                  if ((entry.note ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    CustomText(
                      text: entry.note!,
                      fontSize: AppFontSize.tiny,
                      color: AppColors.grey,
                      height: 1.35,
                    ),
                  ],
                  if (entry.at != null) ...[
                    const SizedBox(height: 2),
                    CustomText(
                      text: _formatDate(entry.at!),
                      fontSize: AppFontSize.tiny,
                      color: AppColors.lightGrey5,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _actionLabel(String action) {
    if (action.isEmpty) return 'Activity';
    return action
        .split('_')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$minute $period';
  }
}
