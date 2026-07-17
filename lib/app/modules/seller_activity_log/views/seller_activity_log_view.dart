import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/models/activity_log/activity_log_model.dart';
import 'package:book_store_app/app/modules/seller_activity_log/controllers/seller_activity_log_controller.dart';
import 'package:book_store_app/app/modules/seller_activity_log/widgets/activity_log_tile.dart';
import 'package:book_store_app/app/modules/seller_activity_log/widgets/seller_activity_log_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SellerActivityLogView extends StatelessWidget {
  SellerActivityLogView({super.key});

  final SellerActivityLogController c = Get.put(SellerActivityLogController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(
        title: 'Activity Log',
        color: AppColors.black2,
        actions: [
          Obx(
            () => GestureDetector(
              onTap: c.isExporting.value ? null : c.exportCsv,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: c.isExporting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : const SvgIcon(
                        assetName: AppIcons.downloadIcon,
                        color: AppColors.primaryColor,
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.logs.isEmpty && c.stats.value == null) {
          return const SellerActivityLogShimmer();
        }
        return CustomRefreshWrapper(
          onRefresh: c.refreshData,
          child: CustomScrollView(
            controller: c.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimen.allPadding,
                    AppDimen.allPadding,
                    AppDimen.allPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatsGrid(c: c),
                      const SizedBox(height: 16),
                      _LastLoginCard(c: c),
                      const SizedBox(height: 16),
                      _SearchField(c: c),
                      const SizedBox(height: 10),
                      _CategoryChips(c: c),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              _LogsSliver(c: c),
            ],
          ),
        );
      }),
    );
  }
}

// ── Stats grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final SellerActivityLogController c;
  const _StatsGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = c.stats.value;
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.history_rounded,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFDBEAFE),
                  label: 'Events (90d)',
                  value: '${s?.totalEvents ?? 0}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.bolt_rounded,
                  iconColor: const Color(0xFFD97706),
                  iconBg: const Color(0xFFFEF3C7),
                  label: 'Actions Today',
                  value: '${s?.staffActionsToday ?? 0}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people_alt_outlined,
                  iconColor: const Color(0xFF16A34A),
                  iconBg: const Color(0xFFDCFCE7),
                  label: 'Active Staff Today',
                  value: '${s?.activeStaffToday ?? 0}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFFDC2626),
                  iconBg: const Color(0xFFFEE2E2),
                  label: 'Security Alerts',
                  value: '${s?.securityAlerts ?? 0}',
                  highlight: (s?.securityAlerts ?? 0) > 0,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? const Color(0xFFFCA5A5) : AppColors.lightGrey11,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(height: 14),
          CustomText(
            text: value,
            fontSize: AppFontSize.medium,
            fontWeight: FontWeight.w800,
            color: AppColors.black2,
          ),
          const SizedBox(height: 3),
          CustomText(
            text: label,
            fontSize: AppFontSize.tiny,
            color: AppColors.lightGrey5,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

// ── Last login card ────────────────────────────────────────────────────────

class _LastLoginCard extends StatelessWidget {
  final SellerActivityLogController c;
  const _LastLoginCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final login = c.stats.value?.lastLogin;
      if (login == null || login.at == null) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGrey11),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.login_rounded,
                size: 15,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Last login · ${login.actorName ?? 'Unknown'}',
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black2,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    text:
                        '${DateFormat('MMM d, h:mm a').format(login.at!.toLocal())}${login.ip != null ? ' · ${login.ip}' : ''}',
                    fontSize: AppFontSize.tiny,
                    color: AppColors.lightGrey5,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Search + date range ───────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final SellerActivityLogController c;
  const _SearchField({required this.c});

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: c.from.value != null && c.to.value != null
          ? DateTimeRange(start: c.from.value!, end: c.to.value!)
          : null,
    );
    if (picked != null) c.setDateRange(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: c.searchController,
                onChanged: c.onSearchChanged,
                hintText: 'Search activity...',
                borderBorderradius: AppDimen.borderRadius,
                borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                prefixIcon: SvgIcon(
                  assetName: AppIcons.searchIcon,
                  color: AppColors.gray600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _pickDateRange(context),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: (c.from.value != null)
                      ? AppColors.primaryColor
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                  border: Border.all(
                    color: (c.from.value != null)
                        ? AppColors.primaryColor
                        : AppColors.lightGrey11,
                  ),
                ),
                child: SvgIcon(
                  assetName: AppIcons.calenderIcon,
                  size: 30,
                  color: (c.from.value != null)
                      ? AppColors.white
                      : AppColors.lightGrey5,
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          if (c.from.value == null || c.to.value == null) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () => c.setDateRange(null, null),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text:
                          '${DateFormat('MMM d').format(c.from.value!)} — ${DateFormat('MMM d, y').format(c.to.value!)}',
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    const SvgIcon(
                      assetName: AppIcons.cross,
                      size: 13,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Category chips ────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final SellerActivityLogController c;
  const _CategoryChips({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [null, ...kActivityLogCategories].map((category) {
            final active = c.selectedCategory.value == category;
            final label = category == null
                ? 'All'
                : activityLogCategoryLabel(category);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => c.setCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primaryColor : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? AppColors.primaryColor
                          : AppColors.lightGrey11,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: CustomText(
                    text: label,
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.white : AppColors.lightGrey5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Logs list ─────────────────────────────────────────────────────────────────

class _LogsSliver extends StatelessWidget {
  final SellerActivityLogController c;
  const _LogsSliver({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimen.allPadding,
            0,
            AppDimen.allPadding,
            AppDimen.allPadding,
          ),
          sliver: const SliverToBoxAdapter(child: ActivityLogListShimmer()),
        );
      }
      if (c.logs.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.history_toggle_off_rounded,
                    size: 40,
                    color: AppColors.lightGrey7,
                  ),
                  const SizedBox(height: 10),
                  CustomText(
                    text: c.hasActiveFilters
                        ? 'No activity matches these filters.'
                        : 'No activity recorded yet.',
                    fontSize: AppFontSize.small2,
                    color: AppColors.lightGrey5,
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppDimen.allPadding,
          0,
          AppDimen.allPadding,
          AppDimen.allPadding,
        ),
        sliver: SliverList.builder(
          itemCount: c.logs.length + (c.hasMore ? 1 : 0),
          itemBuilder: (_, i) {
            if (i >= c.logs.length) {
              return const ActivityLogListShimmer(itemCount: 2);
            }
            return ActivityLogTile(log: c.logs[i]);
          },
        ),
      );
    });
  }
}
