import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/marketing/coupon_model.dart';
import 'package:book_store_app/app/modules/seller_coupons/controllers/seller_coupons_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Create/edit bottom sheet for a coupon — reused for both flows; when
/// [existing] is null this is "Create Coupon", otherwise "Edit Coupon".
class CouponFormSheet extends StatefulWidget {
  final SellerCouponsController controller;
  final CouponModel? existing;

  const CouponFormSheet({super.key, required this.controller, this.existing});

  static void show(BuildContext context, SellerCouponsController controller, {CouponModel? existing}) {
    Get.bottomSheet(
      CouponFormSheet(controller: controller, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<CouponFormSheet> createState() => _CouponFormSheetState();
}

class _CouponFormSheetState extends State<CouponFormSheet> {
  late final TextEditingController _codeCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _minOrderCtrl;
  late final TextEditingController _usageLimitCtrl;
  String _discountType = 'percentage';
  DateTime? _expiresAt;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _codeCtrl = TextEditingController(text: e?.code ?? '');
    _valueCtrl = TextEditingController(text: e != null ? _trimZero(e.discountValue) : '');
    _minOrderCtrl = TextEditingController(text: e?.minOrderAmount != null ? _trimZero(e!.minOrderAmount!) : '');
    _usageLimitCtrl = TextEditingController(text: e?.usageLimit?.toString() ?? '');
    _discountType = e?.discountType ?? 'percentage';
    _expiresAt = e?.expiresAt;
  }

  String _trimZero(double v) => v.truncateToDouble() == v ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _codeCtrl.dispose();
    _valueCtrl.dispose();
    _minOrderCtrl.dispose();
    _usageLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  Future<void> _submit() async {
    final code = _codeCtrl.text.trim();
    final value = double.tryParse(_valueCtrl.text.trim());

    if (code.isEmpty) {
      ToastUtil.showToast('Enter a coupon code');
      return;
    }
    if (value == null || value <= 0) {
      ToastUtil.showToast('Enter a valid discount value');
      return;
    }
    if (_discountType == 'percentage' && value > 100) {
      ToastUtil.showToast('Percentage discount cannot exceed 100');
      return;
    }

    final minOrder = double.tryParse(_minOrderCtrl.text.trim());
    final usageLimit = int.tryParse(_usageLimitCtrl.text.trim());
    final expiresAtStr = _expiresAt?.toIso8601String();

    bool ok;
    if (_isEdit) {
      ok = await widget.controller.updateCoupon(
        widget.existing!,
        code: code,
        discountType: _discountType,
        discountValue: value,
        minOrderAmount: minOrder,
        usageLimit: usageLimit,
        expiresAt: expiresAtStr,
      );
    } else {
      ok = await widget.controller.createCoupon(
        code: code,
        discountType: _discountType,
        discountValue: value,
        minOrderAmount: minOrder,
        usageLimit: usageLimit,
        expiresAt: expiresAtStr,
      );
    }

    if (ok && mounted) Get.back();
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
                  Text(
                    _isEdit ? 'Edit Coupon' : 'Create Coupon',
                    style: BaseTypography.titleMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: BaseSpacing.md),
                  CustomTextField(
                    label: 'Coupon Code',
                    hintText: 'e.g. BACK2SCHOOL',
                    controller: _codeCtrl,
                    isborder: true,
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: _TypeToggle(
                        value: _discountType,
                        onChanged: (v) => setState(() => _discountType = v),
                      )),
                    ],
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: _discountType == 'percentage' ? 'Discount (%)' : 'Discount Amount (\$)',
                    hintText: _discountType == 'percentage' ? 'e.g. 20' : 'e.g. 10',
                    controller: _valueCtrl,
                    isborder: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Minimum Order Amount (optional)',
                    hintText: 'e.g. 50',
                    controller: _minOrderCtrl,
                    isborder: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Usage Limit (optional)',
                    hintText: 'e.g. 100',
                    controller: _usageLimitCtrl,
                    isborder: true,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  GestureDetector(
                    onTap: _pickExpiry,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm + 2, vertical: BaseSpacing.sm + 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey2),
                        borderRadius: BorderRadius.circular(BaseRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_outlined, size: 18, color: AppColors.gray600),
                          SizedBox(width: BaseSpacing.xs),
                          Text(
                            _expiresAt != null
                                ? 'Expires ${DateFormat('MMM d, yyyy').format(_expiresAt!)}'
                                : 'No expiry (optional)',
                            style: BaseTypography.bodySmall(color: AppColors.black2),
                          ),
                          const Spacer(),
                          if (_expiresAt != null)
                            GestureDetector(
                              onTap: () => setState(() => _expiresAt = null),
                              child: Icon(Icons.close_rounded, size: 16, color: AppColors.gray600),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => PressableScale(
                      onTap: widget.controller.isSaving.value ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(BaseRadius.md),
                        ),
                        child: widget.controller.isSaving.value
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                              )
                            : Text(
                                _isEdit ? 'Save Changes' : 'Create Coupon',
                                style: BaseTypography.bodyLarge(color: AppColors.white).copyWith(fontWeight: FontWeight.w700),
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

class _TypeToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _TypeToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(BaseRadius.md)),
      child: Row(
        children: [
          _segment('percentage', 'Percentage'),
          _segment('fixed', 'Fixed Amount'),
        ],
      ),
    );
  }

  Widget _segment(String v, String label) {
    final selected = value == v;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(v),
        child: AnimatedContainer(
          duration: BaseMotion.normal,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(BaseRadius.sm),
          ),
          child: Text(
            label,
            style: BaseTypography.labelSmall(
              color: selected ? AppColors.white : AppColors.gray600,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
