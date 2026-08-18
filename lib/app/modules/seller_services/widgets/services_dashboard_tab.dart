import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/bookings/bookings_dashboard_model.dart';
import 'package:book_store_app/app/modules/seller_services/controllers/seller_services_controller.dart';
import 'package:book_store_app/app/modules/seller_services/widgets/services_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicesDashboardTab extends StatelessWidget {
  final SellerServicesController controller;
  const ServicesDashboardTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDashboard.value) return const ServicesShimmer();

      final d = controller.dashboard.value;

      return CustomRefreshWrapper(
        onRefresh: controller.loadDashboard,
        child: ListView(
          padding: EdgeInsets.all(BaseSpacing.md),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: BaseSpacing.sm,
              mainAxisSpacing: BaseSpacing.sm,
              childAspectRatio: 1.7,
              children: [
                _StatCard(icon: Icons.today_rounded, label: 'Today', value: '${d.todayCount}', color: AppColors.primaryColor),
                _StatCard(icon: Icons.event_available_rounded, label: 'Upcoming', value: '${d.upcomingCount}', color: AppColors.accentColor),
                _StatCard(icon: Icons.task_alt_rounded, label: 'Completed (mo.)', value: '${d.completedThisMonth}', color: AppColors.seaGreen),
                _StatCard(icon: Icons.event_busy_rounded, label: 'Cancelled (mo.)', value: '${d.cancelledThisMonth}', color: d.cancelledThisMonth > 0 ? AppColors.red : AppColors.darkGreen),
              ],
            ),
            SizedBox(height: BaseSpacing.md),
            _RevenueCard(d: d),
            if (d.statusBreakdown.isNotEmpty) ...[
              SizedBox(height: BaseSpacing.md),
              _SectionCard(
                title: 'Status Breakdown',
                child: Column(
                  children: d.statusBreakdown
                      .map((s) => Padding(
                            padding: EdgeInsets.only(bottom: BaseSpacing.xs + 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomText(text: _statusLabel(s.status), color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                                ),
                                CustomText(text: '${s.count}', color: AppColors.primaryColor, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
            SizedBox(height: BaseSpacing.xxl),
          ],
        ),
      );
    });
  }

  String _statusLabel(String status) => status.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
}

class _RevenueCard extends StatelessWidget {
  final BookingsDashboardModel d;
  const _RevenueCard({required this.d});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(gradient: AppColors.appbarGradient, borderRadius: BorderRadius.circular(BaseRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: 'Revenue This Month', color: AppColors.white.withOpacity(0.85), fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
          SizedBox(height: BaseSpacing.xxs),
          CustomText(text: '\$${d.revenueThisMonthUSD.toStringAsFixed(0)}', color: AppColors.white, fontSize: AppFontSize.regular, fontWeight: FontWeight.w800),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg), boxShadow: BaseShadows.forLevel(BaseElevation.level1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.sm)),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: color),
          ),
          SizedBox(height: BaseSpacing.xs),
          CustomText(text: value, color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.w800),
          CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg), boxShadow: BaseShadows.forLevel(BaseElevation.level1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: title, color: AppColors.black2, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w700),
          SizedBox(height: BaseSpacing.sm),
          child,
        ],
      ),
    );
  }
}
