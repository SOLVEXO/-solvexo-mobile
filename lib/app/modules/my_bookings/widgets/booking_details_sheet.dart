import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/bookings/booking_model.dart';
import 'package:book_store_app/app/modules/my_bookings/controllers/my_bookings_controller.dart';
import 'package:book_store_app/app/modules/my_bookings/widgets/booking_status_chip.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Bottom sheet with a booking's full detail and self-service actions
/// (Cancel / Reschedule). Reads `controller.selected` so it live-updates
/// after the detail fetch and after each action.
class BookingDetailsSheet extends StatelessWidget {
  final MyBookingsController controller;

  const BookingDetailsSheet({super.key, required this.controller});

  static void show(BuildContext context, MyBookingsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => BookingDetailsSheet(controller: controller),
    );
  }

  String _locationLabel(String type) => switch (type) {
        'in_person' => 'In Person',
        'virtual' => 'Virtual',
        'customer_address' => "Your Address",
        _ => type,
      };

  Future<void> _confirmCancel(BuildContext context, BookingModel booking) async {
    final reasonCtrl = TextEditingController();
    await CustomConfirmDialog.show(
      context,
      title: 'Cancel this booking?',
      contentBuilder: (_) => CustomTextField(label: 'Reason (optional)', controller: reasonCtrl, isborder: true, maxLines: 2),
      confirmLabel: 'Cancel Booking',
      confirmColor: AppColors.red,
      onConfirm: () async {
        final ok = await controller.cancelBooking(booking.id, reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim());
        if (ok) Get.back();
      },
    );
  }

  Future<void> _reschedule(BuildContext context, BookingModel booking) async {
    final date = await showDatePicker(
      context: context,
      initialDate: booking.date.isAfter(DateTime.now()) ? booking.date : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final ok = await controller.rescheduleBooking(booking.id, date: dateStr, startTime: timeStr);
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final b = controller.selected.value;
      if (b == null) return const SizedBox.shrink();
      // Read inside the Obx builder so action-in-flight changes rebuild the
      // sheet (descendant builds are outside Obx's tracking scope).
      final isBusy = controller.actioningId.value == b.id;

      return CustomBottomSheet(
        title: b.service?.name ?? 'Booking',
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: b.service?.name ?? 'Booking',
                    color: AppColors.black2,
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                BookingStatusChip(status: b.status),
              ],
            ),
            SizedBox(height: BaseSpacing.md),
            _DetailRow(label: 'Date', value: DateFormat('EEEE, MMM d, yyyy').format(b.date)),
            _DetailRow(label: 'Time', value: '${b.startTime} - ${b.endTime}'),
            _DetailRow(label: 'Location', value: _locationLabel(b.locationType)),
            if (b.serviceAddress?.addressLine1 != null)
              _DetailRow(
                label: 'Address',
                value: [b.serviceAddress?.addressLine1, b.serviceAddress?.city].whereType<String>().join(', '),
              ),
            if (b.meetingLink != null && b.meetingLink!.isNotEmpty) _DetailRow(label: 'Meeting Link', value: b.meetingLink!),
            _DetailRow(label: 'Price', value: b.isPaidFromPackage ? 'Paid via package' : '\$${b.price.toStringAsFixed(2)} ${b.currency}'),
            if (b.buyerNote != null && b.buyerNote!.isNotEmpty) _DetailRow(label: 'Your note', value: b.buyerNote!),
            if (b.cancellationReason != null && b.cancellationReason!.isNotEmpty)
              _DetailRow(label: 'Cancellation reason', value: b.cancellationReason!),
            SizedBox(height: BaseSpacing.lg),
            _Actions(controller: controller, booking: b, isBusy: isBusy, onCancel: () => _confirmCancel(context, b), onReschedule: () => _reschedule(context, b)),
          ],
        ),
      );
    });
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: CustomText(text: value, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final MyBookingsController controller;
  final BookingModel booking;
  final bool isBusy;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  const _Actions({
    required this.controller,
    required this.booking,
    required this.isBusy,
    required this.onCancel,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (booking.isReschedulable)
        _ActionButton(label: 'Reschedule', color: AppColors.primaryColor, isBusy: isBusy, onTap: onReschedule),
      if (booking.isCancellable)
        _ActionButton(label: 'Cancel Booking', color: AppColors.red, outlined: true, isBusy: isBusy, onTap: onCancel),
    ];

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) SizedBox(height: BaseSpacing.xs),
          buttons[i],
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  final bool isBusy;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.isBusy,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? AppColors.white : color,
          border: outlined ? Border.all(color: color) : null,
          borderRadius: BorderRadius.circular(BaseRadius.md),
        ),
        child: isBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: outlined ? color : AppColors.white),
              )
            : CustomText(
                text: label,
                color: outlined ? color : AppColors.white,
                fontSize: AppFontSize.extraSmall,
                fontWeight: FontWeight.w700,
              ),
      ),
    );
  }
}
