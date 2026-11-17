import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart'
    show ProductPublishMode;
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shared "when should this product go live" control, used by both the
/// Add Product and Edit Product screens. A 3-way segmented picker
/// (Draft / Schedule / Publish now) that reveals a date & time field
/// when Schedule is selected.
class ProductPublishModeSelector extends StatelessWidget {
  final ProductPublishMode mode;
  final ValueChanged<ProductPublishMode> onModeChanged;
  final DateTime? scheduledAt;
  final ValueChanged<DateTime> onScheduledAtChanged;

  const ProductPublishModeSelector({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.scheduledAt,
    required this.onScheduledAtChanged,
  });

  static const _accent = {
    ProductPublishMode.now: AppColors.darkGreen,
    ProductPublishMode.scheduled: AppColors.orange,
    ProductPublishMode.draft: AppColors.grey,
  };

  static const _icon = {
    ProductPublishMode.now: Icons.bolt_rounded,
    ProductPublishMode.scheduled: Icons.schedule_rounded,
    ProductPublishMode.draft: Icons.edit_note_rounded,
  };

  static const _label = {
    ProductPublishMode.now: 'Publish now',
    ProductPublishMode.scheduled: 'Schedule',
    ProductPublishMode.draft: 'Save as draft',
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accent[mode]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: 'Availability',
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w700,
          color: AppColors.grey,
          letterSpacing: 0.6,
        ),
        const SizedBox(height: 10),

        // ── 3-way segmented control ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.textfldFillColor,
            borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
            border: Border.all(color: AppColors.lightGrey2),
          ),
          child: Row(
            children: ProductPublishMode.values
                .map((m) => _ModeSegment(
                      mode: m,
                      icon: _icon[m]!,
                      label: _label[m]!,
                      accent: _accent[m]!,
                      selected: mode == m,
                      onTap: () => onModeChanged(m),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),

        // ── Status summary line ──────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: mode == ProductPublishMode.scheduled
              ? _ScheduleField(
                  key: const ValueKey('schedule-field'),
                  value: scheduledAt,
                  accent: accent,
                  onChanged: onScheduledAtChanged,
                )
              : Padding(
                  key: const ValueKey('status-summary'),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        mode == ProductPublishMode.now
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 6),
                      CustomText(
                        text: mode == ProductPublishMode.now
                            ? 'Visible to buyers immediately after publishing'
                            : 'Hidden — only you can see it until you publish',
                        fontSize: AppFontSize.tiny,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _ModeSegment extends StatelessWidget {
  final ProductPublishMode mode;
  final IconData icon;
  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _ModeSegment({
    required this.mode,
    required this.icon,
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            border: Border.all(
              color: selected ? accent.withOpacity(0.4) : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: selected ? accent : AppColors.grey),
              const SizedBox(height: 4),
              CustomText(
                text: label,
                fontSize: AppFontSize.tiny,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? accent : AppColors.grey,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The date & time picker card shown when "Schedule" is selected.
class _ScheduleField extends StatelessWidget {
  final DateTime? value;
  final Color accent;
  final ValueChanged<DateTime> onChanged;

  const _ScheduleField({
    super.key,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final initial = (value != null && value!.isAfter(now))
        ? value!
        : now.add(const Duration(minutes: 30));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primaryColor,
                onPrimary: AppColors.white,
                surface: AppColors.white,
                onSurface: AppColors.black2,
              ),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primaryColor,
                onPrimary: AppColors.white,
                surface: AppColors.white,
                onSurface: AppColors.black2,
              ),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null) return;

    onChanged(DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    ));
  }

  String _relativeLabel(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'This time has already passed';
    if (diff.inMinutes < 60) return 'Goes live in ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Goes live in ${diff.inHours} hr';
    return 'Goes live in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(AppDimen.borderRadius),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.event_available_rounded, size: 19, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: hasValue
                        ? DateFormat('MMM d, y · h:mm a').format(value!)
                        : 'Choose a publish date & time',
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w600,
                    color: hasValue ? AppColors.black2 : AppColors.grey,
                  ),
                  CustomText(
                    text: hasValue ? _relativeLabel(value!) : 'Tap to pick when this goes live',
                    fontSize: AppFontSize.tiny,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: accent),
          ],
        ),
      ),
    );
  }
}
