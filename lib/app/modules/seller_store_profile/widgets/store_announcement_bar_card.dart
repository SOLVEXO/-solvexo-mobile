import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/store/store_announcement_bar_model.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Always-visible card (independent of the profile's global isEditing
/// toggle) — message, type, CTA, active switch and an optional scheduling
/// window for the storefront announcement bar, with its own inline Save.
class StoreAnnouncementBarCard extends StatefulWidget {
  final SellerStoreProfileController c;
  const StoreAnnouncementBarCard({super.key, required this.c});

  @override
  State<StoreAnnouncementBarCard> createState() => _StoreAnnouncementBarCardState();
}

class _StoreAnnouncementBarCardState extends State<StoreAnnouncementBarCard> {
  late final TextEditingController _messageCtrl;
  late final TextEditingController _ctaLabelCtrl;
  late final TextEditingController _ctaLinkCtrl;
  late String _type;
  late bool _isActive;
  DateTime? _startAt;
  DateTime? _endAt;

  @override
  void initState() {
    super.initState();
    final bar = widget.c.store.value?.announcementBar ?? const StoreAnnouncementBarModel();
    _messageCtrl = TextEditingController(text: bar.message ?? '');
    _ctaLabelCtrl = TextEditingController(text: bar.ctaLabel ?? '');
    _ctaLinkCtrl = TextEditingController(text: bar.ctaLink ?? '');
    _type = kAnnouncementTypeLabels.containsKey(bar.type) ? bar.type : 'info';
    _isActive = bar.isActive;
    _startAt = bar.startAt;
    _endAt = bar.endAt;
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _ctaLabelCtrl.dispose();
    _ctaLinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startAt : _endAt) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startAt = picked;
      } else {
        _endAt = picked;
      }
    });
  }

  Future<void> _save() async {
    final bar = StoreAnnouncementBarModel(
      message: _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
      type: _type,
      ctaLabel: _ctaLabelCtrl.text.trim().isEmpty ? null : _ctaLabelCtrl.text.trim(),
      ctaLink: _ctaLinkCtrl.text.trim().isEmpty ? null : _ctaLinkCtrl.text.trim(),
      isActive: _isActive,
      startAt: _startAt,
      endAt: _endAt,
    );
    await widget.c.saveAnnouncementBar(bar);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimen.allPadding),
        decoration: _cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: CustomText(
                    text: 'ANNOUNCEMENT BAR',
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey,
                    letterSpacing: 0.8,
                  ),
                ),
                Switch(
                  value: _isActive,
                  activeColor: AppColors.primaryColor,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
            SizedBox(height: BaseSpacing.xs),
            CustomTextField(label: 'Message', hintText: 'e.g. Free shipping this week!', controller: _messageCtrl, isborder: true, maxLines: 2),
            SizedBox(height: BaseSpacing.sm),
            _TypeDropdown(value: _type, onChanged: (v) => setState(() => _type = v)),
            SizedBox(height: BaseSpacing.sm),
            Row(
              children: [
                Expanded(child: CustomTextField(label: 'CTA Label (optional)', controller: _ctaLabelCtrl, isborder: true)),
                SizedBox(width: BaseSpacing.sm),
                Expanded(child: CustomTextField(label: 'CTA Link (optional)', controller: _ctaLinkCtrl, isborder: true)),
              ],
            ),
            SizedBox(height: BaseSpacing.sm),
            Row(
              children: [
                Expanded(child: _DateField(label: 'Starts', value: _startAt, onTap: () => _pickDate(isStart: true), onClear: () => setState(() => _startAt = null))),
                SizedBox(width: BaseSpacing.sm),
                Expanded(child: _DateField(label: 'Ends', value: _endAt, onTap: () => _pickDate(isStart: false), onClear: () => setState(() => _endAt = null))),
              ],
            ),
            SizedBox(height: BaseSpacing.md),
            Obx(
              () => GestureDetector(
                onTap: widget.c.isSavingAnnouncementBar.value ? null : _save,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 46),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(BaseRadius.md)),
                  child: widget.c.isSavingAnnouncementBar.value
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                      : const CustomText(text: 'Save Announcement Bar', color: AppColors.white, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _TypeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: 'Type', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
        SizedBox(height: BaseSpacing.xxs),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm),
          decoration: BoxDecoration(border: Border.all(color: AppColors.lightGrey2), borderRadius: BorderRadius.circular(BaseRadius.md)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gray600),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              items: kAnnouncementTypeLabels.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: CustomText(text: e.value, fontSize: AppFontSize.verySmall, color: AppColors.black2)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const _DateField({required this.label, required this.value, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
        SizedBox(height: BaseSpacing.xxs),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.sm),
            decoration: BoxDecoration(border: Border.all(color: AppColors.lightGrey2), borderRadius: BorderRadius.circular(BaseRadius.md)),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: value != null ? DateFormat('MMM d, y').format(value!) : '—',
                    color: value != null ? AppColors.black2 : AppColors.lightGrey7,
                    fontSize: AppFontSize.tiny,
                  ),
                ),
                if (value != null) GestureDetector(onTap: onClear, child: const Icon(Icons.close_rounded, size: 15, color: AppColors.gray600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
      boxShadow: [
        BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
      ],
    );
