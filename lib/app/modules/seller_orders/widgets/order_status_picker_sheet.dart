import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _kPickableStatuses = [
  OrderStatus.pending,
  OrderStatus.processing,
  OrderStatus.shipped,
  OrderStatus.completed,
];

Color _statusColor(OrderStatus s) => switch (s) {
      OrderStatus.completed => AppColors.greenSuccess,
      OrderStatus.processing => AppColors.iosBlue,
      OrderStatus.shipped => const Color(0xFF5856D6),
      _ => AppColors.iosOrange,
    };

String _statusLabel(OrderStatus s) => switch (s) {
      OrderStatus.completed => 'Completed',
      OrderStatus.processing => 'Processing',
      OrderStatus.shipped => 'Shipped',
      _ => 'Pending',
    };

String _statusDescription(OrderStatus s) => switch (s) {
      OrderStatus.completed => 'Order fulfilled and delivered',
      OrderStatus.processing => 'Preparing and packing the order',
      OrderStatus.shipped => 'Order dispatched — tracking required',
      _ => 'Waiting to be processed',
    };

class OrderStatusPickerSheet extends StatefulWidget {
  final SellerOrder order;
  final SellerOrdersController controller;

  const OrderStatusPickerSheet({
    super.key,
    required this.order,
    required this.controller,
  });

  static Future<void> show(SellerOrder order, SellerOrdersController controller) {
    return Get.bottomSheet(
      OrderStatusPickerSheet(order: order, controller: controller),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
    );
  }

  @override
  State<OrderStatusPickerSheet> createState() => _OrderStatusPickerSheetState();
}

class _OrderStatusPickerSheetState extends State<OrderStatusPickerSheet> {
  late OrderStatus _selected;
  bool _isUpdating = false;
  String? _trackingError;

  final _carrierCtrl = TextEditingController();
  final _trackingNumberCtrl = TextEditingController();
  final _trackingUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.order.status;
  }

  @override
  void dispose() {
    _carrierCtrl.dispose();
    _trackingNumberCtrl.dispose();
    _trackingUrlCtrl.dispose();
    super.dispose();
  }

  Map<String, String>? _buildTracking() {
    final carrier = _carrierCtrl.text.trim();
    final number = _trackingNumberCtrl.text.trim();
    final url = _trackingUrlCtrl.text.trim();

    if (carrier.isEmpty || number.isEmpty) return null;

    return {
      'carrier': carrier,
      'trackingNumber': number,
      if (url.isNotEmpty) 'trackingUrl': url,
    };
  }

  Future<void> _update() async {
    if (_selected == widget.order.status) {
      Get.back();
      return;
    }

    // Validate tracking for shipped status
    if (_selected == OrderStatus.shipped) {
      if (_carrierCtrl.text.trim().isEmpty ||
          _trackingNumberCtrl.text.trim().isEmpty) {
        setState(
            () => _trackingError = 'Carrier and tracking number are required');
        return;
      }
    }

    setState(() {
      _isUpdating = true;
      _trackingError = null;
    });

    final success = await widget.controller.updateOrderStatus(
      widget.order.id,
      _selected.name,
      tracking:
          _selected == OrderStatus.shipped ? _buildTracking() : null,
    );

    if (success) {
      Get.back();
    } else {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
              child: Row(
                children: [
                  const Expanded(
                    child: CustomText(
                      text: 'Update Order Status',
                      fontSize: AppFontSize.medium,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black2,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isUpdating ? null : Get.back,
                    child: const Icon(Icons.close,
                        size: 20, color: AppColors.lightGrey5),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
              child: CustomText(
                text: widget.order.orderNumber,
                fontSize: AppFontSize.tiny,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.lightGrey2),
            // Status options
            ...(_kPickableStatuses.map((status) {
              final color = _statusColor(status);
              final isSelected = _selected == status;
              final isCurrent = widget.order.status == status;
              return GestureDetector(
                onTap: _isUpdating
                    ? null
                    : () => setState(() {
                          _selected = status;
                          _trackingError = null;
                        }),
                child: Container(
                  color: isSelected
                      ? color.withOpacity(0.05)
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimen.allPadding,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomText(
                                  text: _statusLabel(status),
                                  fontSize: AppFontSize.small,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black2,
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: CustomText(
                                      text: 'Current',
                                      fontSize: AppFontSize.tiny,
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            CustomText(
                              text: _statusDescription(status),
                              fontSize: AppFontSize.tiny,
                              color: AppColors.lightGrey5,
                            ),
                          ],
                        ),
                      ),
                      // Radio
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? color : AppColors.lightGrey4,
                            width: isSelected ? 2 : 1.5,
                          ),
                          color: isSelected
                              ? color.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            })),

            // ── Tracking section (shown only when Shipped is selected) ──────────
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: _selected == OrderStatus.shipped
                  ? _TrackingSection(
                      carrierCtrl: _carrierCtrl,
                      trackingNumberCtrl: _trackingNumberCtrl,
                      trackingUrlCtrl: _trackingUrlCtrl,
                      error: _trackingError,
                      enabled: !_isUpdating,
                      onChanged: () =>
                          setState(() => _trackingError = null),
                    )
                  : const SizedBox.shrink(),
            ),

            const Divider(height: 1, color: AppColors.lightGrey2),
            // Update button
            Padding(
              padding: const EdgeInsets.all(AppDimen.allPadding),
              child: GestureDetector(
                onTap: _isUpdating ? null : _update,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _selected == widget.order.status
                        ? AppColors.buttonDisableColor
                        : AppColors.primaryColor,
                    borderRadius:
                        BorderRadius.circular(AppDimen.borderRadius),
                  ),
                  alignment: Alignment.center,
                  child: _isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : CustomText(
                          text: _selected == widget.order.status
                              ? 'No Changes'
                              : 'Update Status',
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

// ── Tracking details form ─────────────────────────────────────────────────────

class _TrackingSection extends StatelessWidget {
  final TextEditingController carrierCtrl;
  final TextEditingController trackingNumberCtrl;
  final TextEditingController trackingUrlCtrl;
  final String? error;
  final bool enabled;
  final VoidCallback onChanged;

  const _TrackingSection({
    required this.carrierCtrl,
    required this.trackingNumberCtrl,
    required this.trackingUrlCtrl,
    required this.error,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF5856D6).withOpacity(0.04),
      padding: const EdgeInsets.fromLTRB(
        AppDimen.allPadding,
        14,
        AppDimen.allPadding,
        14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  size: 15, color: Color(0xFF5856D6)),
              const SizedBox(width: 6),
              const CustomText(
                text: 'Tracking Details',
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5856D6),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CustomText(
                  text: 'Required',
                  fontSize: AppFontSize.tiny,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TrackingField(
            controller: carrierCtrl,
            label: 'Carrier',
            hint: 'e.g. TCS, DHL, FedEx',
            enabled: enabled,
            onChanged: onChanged,
          ),
          const SizedBox(height: 10),
          _TrackingField(
            controller: trackingNumberCtrl,
            label: 'Tracking Number',
            hint: 'e.g. TCS-123456',
            enabled: enabled,
            onChanged: onChanged,
          ),
          const SizedBox(height: 10),
          _TrackingField(
            controller: trackingUrlCtrl,
            label: 'Tracking URL',
            hint: 'https://... (optional)',
            enabled: enabled,
            onChanged: onChanged,
            keyboardType: TextInputType.url,
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 13, color: Colors.red),
                const SizedBox(width: 5),
                CustomText(
                  text: error!,
                  fontSize: AppFontSize.tiny,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackingField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;
  final VoidCallback onChanged;
  final TextInputType keyboardType;

  const _TrackingField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.enabled,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          fontSize: AppFontSize.tiny,
          color: AppColors.lightGrey5,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          onChanged: (_) => onChanged(),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.black2,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.lightGrey5,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
              borderSide:
                  const BorderSide(color: AppColors.lightGrey2, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
              borderSide:
                  const BorderSide(color: AppColors.lightGrey2, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
              borderSide: const BorderSide(
                  color: Color(0xFF5856D6), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
