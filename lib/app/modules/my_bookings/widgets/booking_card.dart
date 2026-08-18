import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/bookings/booking_model.dart';
import 'package:book_store_app/app/modules/my_bookings/widgets/booking_status_chip.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Full-width card for one booking — a prominent "date block" (the way a
/// calendar/ticket app anchors a booking), service + status, then a
/// time/location/price info row.
class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  Color get _accentColor => switch (booking.status) {
    'pending_payment' => AppColors.orange,
    'confirmed' => AppColors.blue,
    'completed' => AppColors.greenSuccess,
    'cancelled_by_buyer' || 'cancelled_by_seller' => AppColors.red,
    _ => AppColors.gray600,
  };

  (IconData, String) get _locationInfo => switch (booking.locationType) {
    'virtual' => (Icons.videocam_rounded, 'Virtual'),
    'customer_address' => (Icons.home_rounded, 'At your address'),
    _ => (Icons.storefront_rounded, 'In-person'),
  };

  @override
  Widget build(BuildContext context) {
    final (locationIcon, locationLabel) = _locationInfo;
    final isMuted = booking.status == 'cancelled_by_buyer' || booking.status == 'cancelled_by_seller';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.xl),
          boxShadow: BaseShadows.forLevel(BaseElevation.level2),
          border: Border.all(color: AppColors.lightGrey2, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Date block — a calendar-ticket-style anchor for the eye ──
            Container(
              width: 64,
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.md),
              decoration: BoxDecoration(
                color: isMuted ? AppColors.lightGrey3 : _accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(BaseRadius.xl),
                  bottomLeft: Radius.circular(BaseRadius.xl),
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: DateFormat('MMM').format(booking.date).toUpperCase(),
                    color: isMuted ? AppColors.lightGrey : _accentColor,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: BaseSpacing.xxs),
                  CustomText(
                    text: DateFormat('d').format(booking.date),
                    color: isMuted ? AppColors.gray600 : AppColors.black2,
                    fontSize: AppFontSize.regular,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),
            ),
            // ── Details ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(BaseSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            text: booking.service?.name ?? 'Service',
                            color: AppColors.black2,
                            fontSize: AppFontSize.extraSmall,
                            fontWeight: FontWeight.w700,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: BaseSpacing.xs),
                        BookingStatusChip(status: booking.status),
                      ],
                    ),
                    SizedBox(height: BaseSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: AppColors.gray600),
                        SizedBox(width: BaseSpacing.xxs),
                        CustomText(
                          text: '${booking.startTime} - ${booking.endTime}',
                          color: AppColors.gray600,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(width: BaseSpacing.sm),
                        Icon(locationIcon, size: 14, color: AppColors.gray600),
                        SizedBox(width: BaseSpacing.xxs),
                        Expanded(
                          child: CustomText(
                            text: locationLabel,
                            color: AppColors.gray600,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: BaseSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                          decoration: BoxDecoration(
                            color: (booking.isPaidFromPackage ? AppColors.greenSuccess : AppColors.primaryColor)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(BaseRadius.sm),
                          ),
                          child: CustomText(
                            text: booking.isPaidFromPackage
                                ? 'Paid via package'
                                : '\$${booking.price.toStringAsFixed(2)} ${booking.currency}',
                            color: booking.isPaidFromPackage ? AppColors.greenSuccess : AppColors.primaryColor,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
