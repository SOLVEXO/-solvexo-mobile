import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/bookings/booking_model.dart';
import 'package:book_store_app/app/modules/seller_services/controllers/seller_services_controller.dart';
import 'package:book_store_app/app/modules/seller_services/widgets/services_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const List<(String?, String)> _kStatusFilters = [
  (null, 'All'),
  ('pending_payment', 'Pending'),
  ('confirmed', 'Confirmed'),
  ('completed', 'Completed'),
  ('cancelled_by_buyer', 'Cancelled (Buyer)'),
  ('cancelled_by_seller', 'Cancelled (Seller)'),
  ('no_show', 'No Show'),
];

Color _statusColor(String status) => switch (status) {
      'pending_payment' => AppColors.orange,
      'confirmed' => AppColors.blue,
      'completed' => AppColors.greenSuccess,
      'cancelled_by_buyer' || 'cancelled_by_seller' => AppColors.red,
      'no_show' => AppColors.gray600,
      _ => AppColors.gray600,
    };

String _statusLabel(String status) => status.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

class ServicesBookingsTab extends StatelessWidget {
  final SellerServicesController controller;
  const ServicesBookingsTab({super.key, required this.controller});

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.bookingDateFilter.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.loadBookings(status: controller.bookingStatusFilter.value, date: picked, serviceId: controller.bookingServiceFilter.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.sm, BaseSpacing.md, 0),
          child: SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kStatusFilters.length,
              separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.xs),
              itemBuilder: (_, i) {
                final (status, label) = _kStatusFilters[i];
                return Obx(() {
                  final selected = controller.bookingStatusFilter.value == status;
                  return GestureDetector(
                    onTap: () => controller.loadBookings(status: status, date: controller.bookingDateFilter.value, serviceId: controller.bookingServiceFilter.value),
                    child: AnimatedContainer(
                      duration: BaseMotion.fast,
                      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryColor : AppColors.white,
                        borderRadius: BorderRadius.circular(BaseRadius.pill),
                        border: Border.all(color: selected ? AppColors.primaryColor : AppColors.lightGrey2),
                      ),
                      child: CustomText(text: label, color: selected ? AppColors.white : AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                    ),
                  );
                });
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.sm, BaseSpacing.md, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _pickDate(context),
                child: Obx(() {
                  final date = controller.bookingDateFilter.value;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.pill), border: Border.all(color: AppColors.lightGrey2)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.gray600),
                        SizedBox(width: BaseSpacing.xxs),
                        CustomText(
                          text: date != null ? DateFormat('MMM d, yyyy').format(date) : 'Any date',
                          color: AppColors.gray600,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  );
                }),
              ),
              Obx(() {
                if (controller.bookingDateFilter.value == null) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(Icons.close_rounded, size: 16, color: AppColors.gray600),
                  onPressed: () => controller.loadBookings(status: controller.bookingStatusFilter.value, date: null, serviceId: controller.bookingServiceFilter.value),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingBookings.value) return const ServicesShimmer();

            if (controller.bookings.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(BaseSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy_outlined, size: 48, color: AppColors.lightGrey),
                      SizedBox(height: BaseSpacing.sm),
                      CustomText(text: 'No bookings found', color: AppColors.black2, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w600),
                      SizedBox(height: BaseSpacing.xxs),
                      CustomText(text: 'Bookings from buyers will show up here.', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            return CustomRefreshWrapper(
              onRefresh: () => controller.loadBookings(
                status: controller.bookingStatusFilter.value,
                date: controller.bookingDateFilter.value,
                serviceId: controller.bookingServiceFilter.value,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(BaseSpacing.md),
                      itemCount: controller.bookings.length,
                      separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
                      itemBuilder: (_, i) => _BookingListItem(
                        booking: controller.bookings[i],
                        onTap: () => BookingDetailsSheet.show(context, controller, controller.bookings[i]),
                      ),
                    ),
                  ),
                  if (controller.bookingsTotalPages.value > 1)
                    Padding(
                      padding: EdgeInsets.only(bottom: BaseSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GhostButton(
                            label: 'Previous',
                            onPressed: controller.bookingsPage.value > 1
                                ? () => controller.loadBookings(
                                      status: controller.bookingStatusFilter.value,
                                      date: controller.bookingDateFilter.value,
                                      serviceId: controller.bookingServiceFilter.value,
                                      page: controller.bookingsPage.value - 1,
                                    )
                                : null,
                          ),
                          SizedBox(width: BaseSpacing.md),
                          CustomText(text: '${controller.bookingsPage.value} / ${controller.bookingsTotalPages.value}', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                          SizedBox(width: BaseSpacing.md),
                          GhostButton(
                            label: 'Next',
                            onPressed: controller.bookingsPage.value < controller.bookingsTotalPages.value
                                ? () => controller.loadBookings(
                                      status: controller.bookingStatusFilter.value,
                                      date: controller.bookingDateFilter.value,
                                      serviceId: controller.bookingServiceFilter.value,
                                      page: controller.bookingsPage.value + 1,
                                    )
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BookingListItem extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  const _BookingListItem({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(BaseSpacing.sm + 2),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg), boxShadow: BaseShadows.forLevel(BaseElevation.level1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(text: booking.buyer?.name ?? 'Buyer', color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                  decoration: BoxDecoration(color: _statusColor(booking.status).withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.pill)),
                  child: CustomText(text: _statusLabel(booking.status), color: _statusColor(booking.status), fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            SizedBox(height: BaseSpacing.xxs),
            CustomText(text: booking.service?.name ?? 'Service', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
            SizedBox(height: BaseSpacing.xs),
            Row(
              children: [
                Icon(Icons.event_outlined, size: 13, color: AppColors.gray600),
                SizedBox(width: BaseSpacing.xxs / 2),
                CustomText(text: '${DateFormat('MMM d, yyyy').format(booking.date)} · ${booking.startTime}-${booking.endTime}', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                const Spacer(),
                CustomText(text: '\$${booking.price.toStringAsFixed(2)} ${booking.currency}', color: AppColors.primaryColor, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookingDetailsSheet extends StatelessWidget {
  final SellerServicesController controller;
  final BookingModel booking;
  const BookingDetailsSheet({super.key, required this.controller, required this.booking});

  static void show(BuildContext context, SellerServicesController controller, BookingModel booking) {
    Get.bottomSheet(
      BookingDetailsSheet(controller: controller, booking: booking),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final reasonCtrl = TextEditingController();
    await CustomConfirmDialog.show(
      context,
      title: 'Cancel this booking?',
      contentBuilder: (_) => CustomTextField(label: 'Reason (optional)', controller: reasonCtrl, isborder: true, maxLines: 2),
      confirmLabel: 'Cancel Booking',
      confirmColor: AppColors.red,
      onConfirm: () {
        controller.cancelBooking(booking.id, reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim());
        Get.back();
      },
    );
  }

  Future<void> _setMeetingLink(BuildContext context) async {
    final linkCtrl = TextEditingController(text: booking.meetingLink ?? '');
    await CustomConfirmDialog.show(
      context,
      title: 'Meeting link',
      contentBuilder: (_) => CustomTextField(label: 'URL', hintText: 'https://...', controller: linkCtrl, isborder: true),
      confirmLabel: 'Save',
      onConfirm: () {
        final link = linkCtrl.text.trim();
        if (link.isNotEmpty) controller.setMeetingLink(booking.id, link);
        Get.back();
      },
    );
  }

  Future<void> _reschedule(BuildContext context) async {
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
    final isTerminal = ['completed', 'cancelled_by_buyer', 'cancelled_by_seller', 'no_show'].contains(booking.status);
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
                    width: 36, height: 4,
                    margin: EdgeInsets.only(bottom: BaseSpacing.md),
                    decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: CustomText(text: booking.service?.name ?? 'Booking', color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                      decoration: BoxDecoration(color: _statusColor(booking.status).withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.pill)),
                      child: CustomText(text: _statusLabel(booking.status), color: _statusColor(booking.status), fontSize: 10.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: BaseSpacing.md),
                _DetailRow(icon: Icons.person_outline_rounded, label: 'Buyer', value: booking.buyer?.name ?? 'Unknown'),
                if (booking.buyer?.email != null) _DetailRow(icon: Icons.email_outlined, label: 'Email', value: booking.buyer!.email!),
                _DetailRow(icon: Icons.event_outlined, label: 'Date', value: DateFormat('EEEE, MMM d, yyyy').format(booking.date)),
                _DetailRow(icon: Icons.schedule_rounded, label: 'Time', value: '${booking.startTime} - ${booking.endTime}'),
                _DetailRow(icon: Icons.place_outlined, label: 'Location', value: _locationLabel(booking.locationType)),
                if (booking.serviceAddress?.addressLine1 != null)
                  _DetailRow(icon: Icons.home_outlined, label: 'Address', value: [booking.serviceAddress?.addressLine1, booking.serviceAddress?.city].whereType<String>().join(', ')),
                if (booking.meetingLink != null && booking.meetingLink!.isNotEmpty)
                  _DetailRow(icon: Icons.videocam_outlined, label: 'Meeting Link', value: booking.meetingLink!),
                _DetailRow(icon: Icons.attach_money_rounded, label: 'Price', value: booking.isPaidFromPackage ? 'Paid via package' : '\$${booking.price.toStringAsFixed(2)} ${booking.currency}'),
                if (booking.buyerNote != null && booking.buyerNote!.isNotEmpty) _DetailRow(icon: Icons.note_outlined, label: 'Note', value: booking.buyerNote!),
                if (booking.cancellationReason != null && booking.cancellationReason!.isNotEmpty)
                  _DetailRow(icon: Icons.info_outline_rounded, label: 'Cancellation reason', value: booking.cancellationReason!),
                SizedBox(height: BaseSpacing.lg),
                if (!isTerminal)
                  Obx(() {
                    final busy = controller.isUpdatingBooking.value;
                    if (booking.status == 'pending_payment') {
                      return Column(
                        children: [
                          PrimaryButton(label: 'Confirm Booking', isLoading: busy, onPressed: busy ? null : () async { final ok = await controller.confirmBooking(booking.id); if (ok) Get.back(); }),
                          SizedBox(height: BaseSpacing.sm),
                          DangerButton(label: 'Cancel Booking', isLoading: busy, onPressed: busy ? null : () => _confirmCancel(context)),
                        ],
                      );
                    }
                    if (booking.status == 'confirmed') {
                      return Column(
                        children: [
                          PrimaryButton(label: 'Mark as Completed', isLoading: busy, onPressed: busy ? null : () async { final ok = await controller.completeBooking(booking.id); if (ok) Get.back(); }),
                          SizedBox(height: BaseSpacing.sm),
                          OutlineButton(label: 'Reschedule', isLoading: busy, onPressed: busy ? null : () => _reschedule(context)),
                          if (booking.locationType == 'virtual') ...[
                            SizedBox(height: BaseSpacing.sm),
                            OutlineButton(label: booking.meetingLink == null || booking.meetingLink!.isEmpty ? 'Set Meeting Link' : 'Update Meeting Link', isLoading: busy, onPressed: busy ? null : () => _setMeetingLink(context)),
                          ],
                          SizedBox(height: BaseSpacing.sm),
                          DangerButton(label: 'Cancel Booking', isLoading: busy, onPressed: busy ? null : () => _confirmCancel(context)),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _locationLabel(String type) => switch (type) {
        'in_person' => 'In Person',
        'virtual' => 'Virtual',
        'customer_address' => "Customer's Address",
        _ => type,
      };
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.gray600),
          SizedBox(width: BaseSpacing.xs),
          SizedBox(
            width: 100,
            child: CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: CustomText(text: value, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
