import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:book_store_app/app/modules/seller_returns/widgets/returns_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Returns & refunds (docs Part B 6.6). Seller panel: English only.
class SellerReturnsView extends StatelessWidget {
  SellerReturnsView({super.key});

  final SellerReturnsController controller = Get.put(SellerReturnsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTwo(title: 'Returns & Refunds'),
      body: Obx(() {
        if (controller.isLoading.value) return const ReturnsSkeleton();
        if (controller.loadFailed.value) {
          return ReturnsMessage(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load returns',
            body: 'Check your connection and try again.',
            action: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
              onPressed: controller.refreshData,
              child: const Text('Retry'),
            ),
          );
        }
        final rows = controller.filtered;
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) controller.loadMore();
              return false;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                ReturnsStats(stats: controller.stats.value),
                const SizedBox(height: 12),
                ReturnsFilters(controller: controller),
                const SizedBox(height: 12),
                if (rows.isEmpty)
                  ReturnsMessage(
                    icon: Icons.assignment_return_outlined,
                    title: controller.selectedFilter.value == ReturnFilter.open
                        ? 'No open returns'
                        : 'Nothing here',
                    body: 'Returns and refund requests from buyers appear here. '
                        'You have 48 hours to respond to each one.',
                  )
                else
                  for (final r in rows) ...[
                    ReturnCard(item: r, controller: controller),
                    const SizedBox(height: 12),
                  ],
                if (controller.isLoadingMore.value)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
