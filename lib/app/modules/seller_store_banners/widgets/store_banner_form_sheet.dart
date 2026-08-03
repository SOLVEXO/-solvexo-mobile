import 'dart:io';

import 'package:book_store_app/app/components/app_image_picker.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/store_banner/store_banner_model.dart';
import 'package:book_store_app/app/modules/seller_store_banners/controllers/seller_store_banners_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const List<String> kBannerTypes = ['hero', 'promotion', 'season', 'collection', 'video'];
const List<String> kBannerLinkTypes = ['external', 'product', 'category', 'collection'];

/// Create/edit bottom sheet for a store banner — reused for both flows;
/// when [existing] is null this is "Create Banner". Editing is JSON-only
/// server-side (no re-upload), so the image pickers become a read-only
/// preview once a banner already exists.
class StoreBannerFormSheet extends StatefulWidget {
  final SellerStoreBannersController controller;
  final StoreBannerModel? existing;

  const StoreBannerFormSheet({super.key, required this.controller, this.existing});

  static void show(BuildContext context, SellerStoreBannersController controller, {StoreBannerModel? existing}) {
    Get.bottomSheet(
      StoreBannerFormSheet(controller: controller, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<StoreBannerFormSheet> createState() => _StoreBannerFormSheetState();
}

class _StoreBannerFormSheetState extends State<StoreBannerFormSheet> {
  late final TextEditingController _ctaLabelCtrl;
  late final TextEditingController _linkTargetCtrl;
  late final TextEditingController _orderCtrl;
  late final TextEditingController _priorityCtrl;

  String _type = 'hero';
  String _linkType = 'external';
  DateTime? _startAt;
  DateTime? _endAt;

  File? _mainFile;
  File? _mobileFile;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _ctaLabelCtrl = TextEditingController(text: e?.ctaLabel ?? '');
    _linkTargetCtrl = TextEditingController(text: e?.linkTarget ?? '');
    _orderCtrl = TextEditingController(text: e?.order.toString() ?? '');
    _priorityCtrl = TextEditingController(text: e?.priority.toString() ?? '');
    _type = e?.type ?? 'hero';
    _linkType = e?.linkType ?? 'external';
    _startAt = e?.startAt;
    _endAt = e?.endAt;
  }

  @override
  void dispose() {
    _ctaLabelCtrl.dispose();
    _linkTargetCtrl.dispose();
    _orderCtrl.dispose();
    _priorityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _startAt : _endAt) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

  Future<void> _submit() async {
    if (!_isEdit && _mainFile == null) {
      ToastUtil.showToast('Choose a banner image');
      return;
    }

    final ctaLabel = _ctaLabelCtrl.text.trim();
    final linkTarget = _linkTargetCtrl.text.trim();
    final order = int.tryParse(_orderCtrl.text.trim());
    final priority = int.tryParse(_priorityCtrl.text.trim());

    bool ok;
    if (_isEdit) {
      ok = await widget.controller.updateBanner(
        widget.existing!,
        type: _type,
        ctaLabel: ctaLabel.isEmpty ? null : ctaLabel,
        linkType: _linkType,
        linkTarget: linkTarget.isEmpty ? null : linkTarget,
        order: order,
        priority: priority,
        startAt: _startAt,
        endAt: _endAt,
      );
    } else {
      ok = await widget.controller.createBanner(
        file: _mainFile!,
        mobileFile: _mobileFile,
        type: _type,
        ctaLabel: ctaLabel.isEmpty ? null : ctaLabel,
        linkType: _linkType,
        linkTarget: linkTarget.isEmpty ? null : linkTarget,
        order: order,
        priority: priority,
        startAt: _startAt,
        endAt: _endAt,
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
                      width: 36,
                      height: 4,
                      margin: EdgeInsets.only(bottom: BaseSpacing.md),
                      decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  CustomText(
                    text: _isEdit ? 'Edit Banner' : 'Create Banner',
                    color: AppColors.black2,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: BaseSpacing.md),
                  if (_isEdit) ...[
                    CustomText(
                      text: 'The image can\'t be changed after creation — delete and recreate this banner for a new image.',
                      color: AppColors.gray600,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: BaseSpacing.sm),
                    Row(
                      children: [
                        _ImagePreview(url: widget.existing!.imageUrl, label: 'Main'),
                        if (widget.existing!.mobileImageUrl != null && widget.existing!.mobileImageUrl!.isNotEmpty) ...[
                          SizedBox(width: BaseSpacing.sm),
                          _ImagePreview(url: widget.existing!.mobileImageUrl, label: 'Mobile'),
                        ],
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        _ImagePickerSlot(
                          label: 'Main Image',
                          file: _mainFile,
                          onTap: () => AppImagePicker.show(
                            title: 'Banner Image',
                            canRemove: _mainFile != null,
                            onPicked: (file) => setState(() => _mainFile = file),
                            onRemove: () => setState(() => _mainFile = null),
                          ),
                        ),
                        SizedBox(width: BaseSpacing.sm),
                        _ImagePickerSlot(
                          label: 'Mobile (optional)',
                          file: _mobileFile,
                          onTap: () => AppImagePicker.show(
                            title: 'Mobile Banner Image',
                            canRemove: _mobileFile != null,
                            onPicked: (file) => setState(() => _mobileFile = file),
                            onRemove: () => setState(() => _mobileFile = null),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: BaseSpacing.sm),
                  _LabeledDropdown(
                    label: 'Type',
                    value: _type,
                    items: kBannerTypes,
                    onChanged: (v) => setState(() => _type = v),
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(label: 'CTA Label (optional)', hintText: 'e.g. Shop Now', controller: _ctaLabelCtrl, isborder: true),
                  SizedBox(height: BaseSpacing.sm),
                  _LabeledDropdown(
                    label: 'Link Type',
                    value: _linkType,
                    items: kBannerLinkTypes,
                    onChanged: (v) => setState(() => _linkType = v),
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Link Target (optional)',
                    hintText: _linkType == 'external' ? 'https://...' : 'ID or slug',
                    controller: _linkTargetCtrl,
                    isborder: true,
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Order (optional)',
                          controller: _orderCtrl,
                          isborder: true,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: BaseSpacing.sm),
                      Expanded(
                        child: CustomTextField(
                          label: 'Priority (optional)',
                          controller: _priorityCtrl,
                          isborder: true,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: _DatePickerField(label: 'Starts', value: _startAt, onTap: () => _pickDate(isStart: true), onClear: () => setState(() => _startAt = null))),
                      SizedBox(width: BaseSpacing.sm),
                      Expanded(child: _DatePickerField(label: 'Ends', value: _endAt, onTap: () => _pickDate(isStart: false), onClear: () => setState(() => _endAt = null))),
                    ],
                  ),
                  SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => GestureDetector(
                      onTap: widget.controller.isSaving.value ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(BaseRadius.md)),
                        child: widget.controller.isSaving.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : CustomText(text: _isEdit ? 'Save Changes' : 'Create Banner', color: AppColors.white, fontSize: AppFontSize.small, fontWeight: FontWeight.w700),
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

// ── Image slots ──────────────────────────────────────────────────────────────

class _ImagePickerSlot extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;
  const _ImagePickerSlot({required this.label, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
            SizedBox(height: BaseSpacing.xxs),
            Container(
              height: 84,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey2),
                borderRadius: BorderRadius.circular(BaseRadius.md),
                color: AppColors.background,
              ),
              child: file != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(BaseRadius.md),
                      child: CommonImageView(file: file, fit: BoxFit.cover, height: 84, width: double.infinity),
                    )
                  : Icon(Icons.add_photo_alternate_outlined, color: AppColors.gray600, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String? url;
  final String label;
  const _ImagePreview({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
          SizedBox(height: BaseSpacing.xxs),
          ClipRRect(
            borderRadius: BorderRadius.circular(BaseRadius.md),
            child: CommonImageView(url: url, fit: BoxFit.cover, height: 84, width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ── Dropdown ─────────────────────────────────────────────────────────────────

class _LabeledDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _LabeledDropdown({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
        SizedBox(height: BaseSpacing.xxs),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm),
          decoration: BoxDecoration(border: Border.all(color: AppColors.lightGrey2), borderRadius: BorderRadius.circular(BaseRadius.md)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gray600),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              items: items
                  .map((i) => DropdownMenuItem(
                        value: i,
                        child: CustomText(
                          text: i[0].toUpperCase() + i.substring(1),
                          fontSize: AppFontSize.verySmall,
                          color: AppColors.black2,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Date field ───────────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const _DatePickerField({required this.label, required this.value, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
        SizedBox(height: BaseSpacing.xxs),
        PressableScale(
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
                if (value != null)
                  GestureDetector(onTap: onClear, child: Icon(Icons.close_rounded, size: 15, color: AppColors.gray600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
