import 'package:book_store_app/app/services/maintenance_service.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Full-screen page shown while maintenance covers `all` or `buyer`.
/// It is drawn over the navigator (see [MaintenanceGate]) so the user's place
/// in the app is kept and comes back when maintenance ends.
class MaintenanceView extends StatelessWidget {
  const MaintenanceView({super.key, required this.state});

  final MaintenanceState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ends = state.endsAt;
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(BaseSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.construction_rounded,
                        size: 44, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: BaseSpacing.lg),
                  Text(
                    state.title?.isNotEmpty == true
                        ? state.title!
                        : 'We’ll be right back'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: BaseSpacing.sm),
                  Text(
                    state.message?.isNotEmpty == true
                        ? state.message!
                        : 'Edudeen is being updated. Please check back shortly.'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (ends != null) ...[
                    const SizedBox(height: BaseSpacing.md),
                    Chip(
                      avatar: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text(
                        '${'Expected back'.tr}: ${DateFormat('d MMM, h:mm a').format(ends)}',
                      ),
                    ),
                  ],
                  const SizedBox(height: BaseSpacing.xl),
                  FilledButton.icon(
                    onPressed: MaintenanceService.to.check,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text('Try again'.tr),
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

/// Wraps the navigator: full page for app-wide maintenance, a slim banner for
/// a scheduled window or a single feature, nothing otherwise.
class MaintenanceGate extends StatelessWidget {
  const MaintenanceGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = MaintenanceService.to.state.value;
      if (s.blocksBuyerApp) {
        return Stack(children: [child, Positioned.fill(child: MaintenanceView(state: s))]);
      }
      if (!s.enabled) return child;
      final text = s.isScheduled
          ? '${'Scheduled maintenance'.tr}: ${DateFormat('d MMM, h:mm a').format(s.startsAt!)}'
          : (s.message?.isNotEmpty == true
              ? s.message!
              : 'Some features are being updated.'.tr);
      return Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: BaseSpacing.md, vertical: BaseSpacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.onTertiaryContainer),
                    const SizedBox(width: BaseSpacing.sm),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: child,
            ),
          ),
        ],
      );
    });
  }
}
