import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/seo/seo_product_list_item_model.dart';
import 'package:book_store_app/app/modules/seller_seo_products/controllers/seller_seo_products_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Product row ──────────────────────────────────────────────────────────────

class SeoProductTile extends StatelessWidget {
  final SeoProductListItemModel product;
  final SellerSeoProductsController controller;
  const SeoProductTile({super.key, required this.product, required this.controller});

  Color get _scoreColor {
    if (product.completeness >= 80) return AppColors.greenSuccess;
    if (product.completeness >= 50) return AppColors.amberDark;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _ProductSeoFormSheet.show(context, controller, product: product),
      child: Container(
        margin: EdgeInsets.only(bottom: BaseSpacing.sm),
        padding: EdgeInsets.all(BaseSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: product.name,
                    color: AppColors.black2,
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  CustomText(
                    text: (product.seo.metaTitle?.isNotEmpty ?? false)
                        ? product.seo.metaTitle!
                        : 'No meta title set',
                    color: (product.seo.metaTitle?.isNotEmpty ?? false) ? AppColors.gray600 : AppColors.amberDark,
                    fontSize: AppFontSize.tiny,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: BaseSpacing.xs),
            Container(
              padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
              decoration: BoxDecoration(
                color: _scoreColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(BaseRadius.pill),
              ),
              child: CustomText(
                text: '${product.completeness}%',
                color: _scoreColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray600),
          ],
        ),
      ),
    );
  }
}

// ── Per-product edit sheet ───────────────────────────────────────────────────

class _ProductSeoFormSheet extends StatefulWidget {
  final SellerSeoProductsController controller;
  final SeoProductListItemModel product;
  const _ProductSeoFormSheet({required this.controller, required this.product});

  static void show(BuildContext context, SellerSeoProductsController controller, {required SeoProductListItemModel product}) {
    Get.bottomSheet(
      _ProductSeoFormSheet(controller: controller, product: product),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<_ProductSeoFormSheet> createState() => _ProductSeoFormSheetState();
}

class _ProductSeoFormSheetState extends State<_ProductSeoFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _keywordsCtrl;
  late bool _noindex;

  @override
  void initState() {
    super.initState();
    final seo = widget.product.seo;
    _titleCtrl = TextEditingController(text: seo.metaTitle ?? '');
    _descCtrl = TextEditingController(text: seo.metaDescription ?? '');
    _keywordsCtrl = TextEditingController(text: seo.keywords.join(', '));
    _noindex = seo.noindex;
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
    await widget.controller.saveProductSeo(
      widget.product.id,
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
                    text: widget.product.name,
                    color: AppColors.black2,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: BaseSpacing.md),
                  CustomTextField(
                    label: 'Meta Title',
                    hintText: 'e.g. Handmade Ceramic Mug | My Shop',
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
                      onTap: widget.controller.isSavingProduct.value ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(BaseRadius.md),
                        ),
                        child: widget.controller.isSavingProduct.value
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

// ── Bulk template sheet ──────────────────────────────────────────────────────

class BulkTemplateFormSheet extends StatefulWidget {
  final SellerSeoProductsController controller;
  const BulkTemplateFormSheet({super.key, required this.controller});

  static void show(BuildContext context, SellerSeoProductsController controller) {
    Get.bottomSheet(
      BulkTemplateFormSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<BulkTemplateFormSheet> createState() => _BulkTemplateFormSheetState();
}

class _BulkTemplateFormSheetState extends State<BulkTemplateFormSheet> {
  late final TextEditingController _titleTemplateCtrl;
  late final TextEditingController _descTemplateCtrl;
  bool _onlyMissing = true;

  @override
  void initState() {
    super.initState();
    _titleTemplateCtrl = TextEditingController();
    _descTemplateCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleTemplateCtrl.dispose();
    _descTemplateCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleTemplateCtrl.text.trim().isEmpty && _descTemplateCtrl.text.trim().isEmpty) return;
    await widget.controller.applyBulkTemplate(
      titleTemplate: _titleTemplateCtrl.text.trim(),
      descriptionTemplate: _descTemplateCtrl.text.trim(),
      onlyMissing: _onlyMissing,
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
                    text: 'Bulk Apply Template',
                    color: AppColors.black2,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 2),
                  CustomText(
                    text: 'Use {{productName}} to insert each product\'s name.',
                    color: AppColors.gray600,
                    fontSize: AppFontSize.tiny,
                  ),
                  SizedBox(height: BaseSpacing.md),
                  CustomTextField(
                    label: 'Meta Title Template',
                    hintText: '{{productName}} | My Shop',
                    controller: _titleTemplateCtrl,
                    isborder: true,
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Meta Description Template',
                    hintText: 'Shop {{productName}} at My Shop — fast shipping.',
                    controller: _descTemplateCtrl,
                    isborder: true,
                    maxLines: 3,
                  ),
                  SizedBox(height: BaseSpacing.xs),
                  StatefulBuilder(
                    builder: (context, setSheetState) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomText(
                            text: 'Only apply to products missing a meta title',
                            color: AppColors.black2,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _onlyMissing,
                            activeColor: AppColors.primaryColor,
                            onChanged: (v) => setSheetState(() => _onlyMissing = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => GestureDetector(
                      onTap: widget.controller.isApplyingTemplate.value ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(BaseRadius.md),
                        ),
                        child: widget.controller.isApplyingTemplate.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                              )
                            : CustomText(
                                text: 'Apply Template',
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
