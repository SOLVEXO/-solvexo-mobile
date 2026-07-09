import 'dart:convert';

import 'package:book_store_app/app/data/models/analytics/analytics_overview_model.dart';
import 'package:book_store_app/app/data/models/analytics/customer_analytics_model.dart';
import 'package:book_store_app/app/data/models/analytics/inventory_insights_model.dart';
import 'package:book_store_app/app/data/models/analytics/payment_method_breakdown_model.dart';
import 'package:book_store_app/app/data/models/analytics/product_performance_model.dart';
import 'package:book_store_app/app/data/models/analytics/revenue_point_model.dart';
import 'package:book_store_app/app/data/models/analytics/top_product_analytics_model.dart';
import 'package:book_store_app/app/data/models/analytics/traffic_source_model.dart';
import 'package:book_store_app/app/data/repositories/seller_analytics_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

enum AnalyticsTab { overview, products, customers, inventory }

const kAnalyticsRangeLabels = {
  '7d': 'Last 7 days',
  '30d': 'Last 30 days',
  '90d': 'Last 90 days',
  '6m': 'Last 6 months',
  '12m': 'Last 12 months',
};

class SellerAnalyticsController extends GetxController {
  final SellerAnalyticsRepository _repo = SellerAnalyticsRepository();

  String storeId = '';
  final Rx<AnalyticsTab> tab = AnalyticsTab.overview.obs;
  final RxString range = '30d'.obs;
  final RxBool isExporting = false.obs;

  // ── Overview tab ───────────────────────────────────────────────────────
  final RxBool isLoadingOverview = true.obs;
  final Rx<AnalyticsOverviewModel> overview = Rx<AnalyticsOverviewModel>(AnalyticsOverviewModel.empty);
  final RxString chartGranularity = 'day'.obs;
  final RxList<RevenuePointModel> revenueSeries = <RevenuePointModel>[].obs;
  final RxList<OrderPointModel> orderSeries = <OrderPointModel>[].obs;
  final RxList<TrafficSourceModel> trafficSources = <TrafficSourceModel>[].obs;
  final RxList<TopProductAnalyticsModel> topProducts = <TopProductAnalyticsModel>[].obs;
  final RxList<PaymentMethodBreakdownModel> paymentMethods = <PaymentMethodBreakdownModel>[].obs;
  final Rx<RevenueBreakdownModel> revenueBreakdown = Rx<RevenueBreakdownModel>(RevenueBreakdownModel.empty);

  // ── Products tab ───────────────────────────────────────────────────────
  final RxBool isLoadingProducts = false.obs;
  final RxList<ProductPerformanceModel> products = <ProductPerformanceModel>[].obs;
  final RxInt productsPage = 1.obs;
  final RxInt productsTotalPages = 1.obs;
  bool _productsLoaded = false;

  // ── Customers tab ──────────────────────────────────────────────────────
  final RxBool isLoadingCustomers = false.obs;
  final Rx<CustomerAnalyticsModel> customers = Rx<CustomerAnalyticsModel>(CustomerAnalyticsModel.empty);
  bool _customersLoaded = false;

  // ── Inventory tab ──────────────────────────────────────────────────────
  final RxBool isLoadingInventory = false.obs;
  final Rx<InventoryInsightsModel> inventory = Rx<InventoryInsightsModel>(InventoryInsightsModel.empty);
  bool _inventoryLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ SellerAnalyticsController: no storeId in prefs');
      isLoadingOverview.value = false;
      return;
    }
    await loadOverview();
  }

  void changeTab(AnalyticsTab value) {
    tab.value = value;
    switch (value) {
      case AnalyticsTab.overview:
        break; // already loaded eagerly, refreshed on pull-to-refresh
      case AnalyticsTab.products:
        if (!_productsLoaded) loadProducts();
        break;
      case AnalyticsTab.customers:
        if (!_customersLoaded) loadCustomers();
        break;
      case AnalyticsTab.inventory:
        if (!_inventoryLoaded) loadInventory();
        break;
    }
  }

  void changeRange(String value) {
    if (range.value == value) return;
    range.value = value;
    refresh();
  }

  Future<void> loadOverview() async {
    if (storeId.isEmpty) return;
    isLoadingOverview.value = true;
    final r = range.value;
    final results = await Future.wait([
      _repo.getOverview(storeId, r),
      _repo.getRevenueOverTime(storeId, r),
      _repo.getOrdersOverTime(storeId, r),
      _repo.getTrafficSources(storeId, r),
      _repo.getTopProducts(storeId, r, limit: 5),
      _repo.getPaymentMethods(storeId, r),
      _repo.getRevenueBreakdown(storeId, r),
    ]);

    overview.value = results[0] as AnalyticsOverviewModel;
    final revenue = results[1] as ({String granularity, List<RevenuePointModel> series});
    revenueSeries.assignAll(revenue.series);
    chartGranularity.value = revenue.granularity;
    final orders = results[2] as ({String granularity, List<OrderPointModel> series});
    orderSeries.assignAll(orders.series);
    trafficSources.assignAll(results[3] as List<TrafficSourceModel>);
    topProducts.assignAll(results[4] as List<TopProductAnalyticsModel>);
    paymentMethods.assignAll(results[5] as List<PaymentMethodBreakdownModel>);
    revenueBreakdown.value = results[6] as RevenueBreakdownModel;

    isLoadingOverview.value = false;
  }

  Future<void> loadProducts({bool loadMore = false}) async {
    if (storeId.isEmpty) return;
    isLoadingProducts.value = true;
    final page = loadMore ? productsPage.value + 1 : 1;
    final result = await _repo.getProductPerformance(storeId, range.value, page: page);
    if (loadMore) {
      products.addAll(result.products);
    } else {
      products.assignAll(result.products);
    }
    productsPage.value = page;
    productsTotalPages.value = result.totalPages;
    _productsLoaded = true;
    isLoadingProducts.value = false;
  }

  Future<void> loadCustomers() async {
    if (storeId.isEmpty) return;
    isLoadingCustomers.value = true;
    customers.value = await _repo.getCustomerAnalytics(storeId, range.value);
    _customersLoaded = true;
    isLoadingCustomers.value = false;
  }

  Future<void> loadInventory() async {
    if (storeId.isEmpty) return;
    isLoadingInventory.value = true;
    inventory.value = await _repo.getInventoryInsights(storeId);
    _inventoryLoaded = true;
    isLoadingInventory.value = false;
  }

  @override
  Future<void> refresh() async {
    switch (tab.value) {
      case AnalyticsTab.overview:
        await loadOverview();
        break;
      case AnalyticsTab.products:
        await loadProducts();
        break;
      case AnalyticsTab.customers:
        await loadCustomers();
        break;
      case AnalyticsTab.inventory:
        await loadInventory();
        break;
    }
  }

  // ── Export ───────────────────────────────────────────────────────────────

  Future<void> exportPdf() async {
    if (isExporting.value) return;
    isExporting.value = true;
    try {
      final bytes = await _repo.exportPdf(storeId, range.value);
      if (bytes == null) return;
      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        name: 'analytics-report-${DateTime.now().millisecondsSinceEpoch}.pdf',
        mimeType: 'application/pdf',
      );
      await SharePlus.instance.share(ShareParams(files: [file], subject: 'Analytics Report'));
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportCsv(String section) async {
    if (isExporting.value) return;
    isExporting.value = true;
    try {
      final csv = await _repo.exportCsv(storeId, range.value, section: section);
      if (csv == null) return;
      final file = XFile.fromData(
        Uint8List.fromList(utf8.encode(csv)),
        name: 'analytics-$section-${DateTime.now().millisecondsSinceEpoch}.csv',
        mimeType: 'text/csv',
      );
      await SharePlus.instance.share(
        ShareParams(files: [file], subject: 'Analytics — ${section[0].toUpperCase()}${section.substring(1)}'),
      );
    } finally {
      isExporting.value = false;
    }
  }
}
