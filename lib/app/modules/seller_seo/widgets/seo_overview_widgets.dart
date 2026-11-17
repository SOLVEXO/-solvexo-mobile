import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/seo/seo_dashboard_model.dart';
import 'package:book_store_app/app/data/models/seo/seo_meta_model.dart';
import 'package:book_store_app/app/modules/seller_seo/controllers/seller_seo_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Completeness overview card ───────────────────────────────────────────────

class SeoCompletenessCard extends StatelessWidget {
  final SeoDashboardModel data;
  const SeoCompletenessCard({super.key, required this.data});

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
          CustomText(
            text: 'SEO Completeness',
            color: AppColors.black2,
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: BaseSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ScoreStat(label: 'Store', value: data.storeCompleteness),
              ),
              SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: _ScoreStat(label: 'Products avg', value: data.productCompletenessAvg),
              ),
              SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: _ScoreStat(label: 'Checklist', value: data.checklistCompletion),
              ),
            ],
          ),
          SizedBox(height: BaseSpacing.xs),
          CustomText(
            text: '${data.productCount} product(s) tracked',
            color: AppColors.gray600,
            fontSize: AppFontSize.tiny,
          ),
        ],
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String label;
  final int value;
  const _ScoreStat({required this.label, required this.value});

  Color get _color {
    if (value >= 80) return AppColors.greenSuccess;
    if (value >= 50) return AppColors.amberDark;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.lightGrey10,
        borderRadius: BorderRadius.circular(BaseRadius.md),
      ),
      child: Column(
        children: [
          CustomText(
            text: '$value%',
            color: _color,
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.w800,
          ),
          SizedBox(height: 2),
          CustomText(
            text: label,
            color: AppColors.gray600,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

// ── Checklist card ────────────────────────────────────────────────────────────

class SeoChecklistCard extends StatelessWidget {
  final SellerSeoController controller;
  const SeoChecklistCard({super.key, required this.controller});

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
      child: Obx(() {
        final checklist = controller.dashboard.value?.checklist ?? const <SeoChecklistItemModel>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'SEO Checklist',
              color: AppColors.black2,
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: BaseSpacing.xs),
            ...checklist.map((item) => _ChecklistRow(
                  item: item,
                  isBusy: controller.isTogglingChecklist.value,
                  onToggle: item.automated
                      ? null
                      : (value) => controller.toggleChecklistItem(item.key, value),
                )),
          ],
        );
      }),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final SeoChecklistItemModel item;
  final bool isBusy;
  final ValueChanged<bool>? onToggle;
  const _ChecklistRow({required this.item, required this.isBusy, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs),
      child: Row(
        children: [
          Icon(
            item.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: item.done ? AppColors.greenSuccess : AppColors.lightGrey7,
          ),
          SizedBox(width: BaseSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: item.label,
                  color: AppColors.black2,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
                if (item.automated)
                  CustomText(
                    text: 'Automatic',
                    color: AppColors.gray600,
                    fontSize: 10.5,
                  ),
              ],
            ),
          ),
          if (onToggle != null)
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: item.done,
                onChanged: isBusy ? null : onToggle,
                activeColor: AppColors.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Store meta card ───────────────────────────────────────────────────────────

class SeoStoreMetaCard extends StatelessWidget {
  final SellerSeoController controller;
  const SeoStoreMetaCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final meta = controller.storeMeta.value;
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
              children: [
                Expanded(
                  child: CustomText(
                    text: 'Store Meta',
                    color: AppColors.black2,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => _StoreMetaFormSheet.show(context, controller, existing: meta),
                  child: CustomText(
                    text: 'Edit',
                    color: AppColors.primaryColor,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: BaseSpacing.xs),
            CustomText(
              text: (meta?.metaTitle?.isNotEmpty ?? false) ? meta!.metaTitle! : 'No meta title set',
              color: (meta?.metaTitle?.isNotEmpty ?? false) ? AppColors.black2 : AppColors.gray600,
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            CustomText(
              text: (meta?.metaDescription?.isNotEmpty ?? false)
                  ? meta!.metaDescription!
                  : 'No meta description set',
              color: AppColors.gray600,
              fontSize: AppFontSize.tiny,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (meta?.noindex ?? false) ...[
              SizedBox(height: BaseSpacing.xs),
              Container(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                ),
                child: CustomText(
                  text: 'Hidden from search (noindex)',
                  color: AppColors.red,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _StoreMetaFormSheet extends StatefulWidget {
  final SellerSeoController controller;
  final SeoMetaModel? existing;
  const _StoreMetaFormSheet({required this.controller, this.existing});

  static void show(BuildContext context, SellerSeoController controller, {SeoMetaModel? existing}) {
    Get.bottomSheet(
      _StoreMetaFormSheet(controller: controller, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<_StoreMetaFormSheet> createState() => _StoreMetaFormSheetState();
}

class _StoreMetaFormSheetState extends State<_StoreMetaFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _keywordsCtrl;
  late bool _noindex;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.metaTitle ?? '');
    _descCtrl = TextEditingController(text: e?.metaDescription ?? '');
    _keywordsCtrl = TextEditingController(text: e?.keywords.join(', ') ?? '');
    _noindex = e?.noindex ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _keywordsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final keywords = _keywordsCtrl.text.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
    await widget.controller.saveStoreMeta(
      metaTitle: _titleCtrl.text.trim(),
      metaDescription: _descCtrl.text.trim(),
      keywords: keywords,
      noindex: _noindex,
    );
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
                    text: 'Edit Store Meta',
                    color: AppColors.black2,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: BaseSpacing.md),
                  CustomTextField(
                    label: 'Meta Title',
                    hintText: 'e.g. My Shop | Handmade Goods',
                    controller: _titleCtrl,
                    isborder: true,
                    maxLength: 70,
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Meta Description',
                    hintText: 'A short summary shown in search results',
                    controller: _descCtrl,
                    isborder: true,
                    maxLines: 3,
                    maxLength: 320,
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Keywords, comma separated',
                    hintText: 'handmade, gifts, jewelry',
                    controller: _keywordsCtrl,
                    isborder: true,
                  ),
                  SizedBox(height: BaseSpacing.xs),
                  StatefulBuilder(
                    builder: (context, setSheetState) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: 'Hide from search engines (noindex)',
                          color: AppColors.black2,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w600,
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _noindex,
                            activeColor: AppColors.primaryColor,
                            onChanged: (v) => setSheetState(() => _noindex = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => GestureDetector(
                      onTap: widget.controller.isSavingStoreMeta.value ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(BaseRadius.md),
                        ),
                        child: widget.controller.isSavingStoreMeta.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                              )
                            : CustomText(
                                text: 'Save Changes',
                                color: AppColors.white,
                                fontSize: AppFontSize.small,
                                fontWeight: FontWeight.w700,
                              ),
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
