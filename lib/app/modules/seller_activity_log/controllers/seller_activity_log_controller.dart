import 'dart:async';
import 'dart:typed_data';

import 'package:book_store_app/app/data/models/activity_log/activity_log_model.dart';
import 'package:book_store_app/app/data/repositories/activity_log_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class SellerActivityLogController extends GetxController {
  final _repo = ActivityLogRepository();

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isExporting = false.obs;
  final RxList<ActivityLogModel> logs = <ActivityLogModel>[].obs;
  final Rx<ActivityLogStatsModel?> stats = Rx(null);

  final RxnString selectedCategory = RxnString();
  final RxString searchQuery = ''.obs;
  final Rx<DateTime?> from = Rx(null);
  final Rx<DateTime?> to = Rx(null);

  String _storeId = '';
  int _page = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  Timer? _debounce;

  bool get hasActiveFilters =>
      selectedCategory.value != null || searchQuery.value.isNotEmpty || from.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadContext().then((_) {
      loadStats();
      loadLogs();
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _loadContext() async {
    _storeId = await AppPreferences.getStoreId() ?? '';
  }

  String? _fmt(DateTime? d) => d?.toIso8601String().split('T').first;

  Future<void> loadStats() async {
    if (_storeId.isEmpty) return;
    stats.value = await _repo.getStats(_storeId);
  }

  Future<void> loadLogs() async {
    if (_storeId.isEmpty) return;
    isLoading.value = true;
    _page = 1;
    try {
      final result = await _repo.getLogs(
        storeId: _storeId,
        page: _page,
        category: selectedCategory.value,
        search: searchQuery.value,
        from: _fmt(from.value),
        to: _fmt(to.value),
      );
      logs.assignAll(result.items);
      _hasMore = result.hasMore;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore || _storeId.isEmpty) return;
    isLoadingMore.value = true;
    try {
      final result = await _repo.getLogs(
        storeId: _storeId,
        page: _page + 1,
        category: selectedCategory.value,
        search: searchQuery.value,
        from: _fmt(from.value),
        to: _fmt(to.value),
      );
      logs.addAll(result.items);
      _page++;
      _hasMore = result.hasMore;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshData() async {
    await Future.wait([loadStats(), loadLogs()]);
  }

  void setCategory(String? category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    loadLogs();
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchQuery.value = value.trim();
      loadLogs();
    });
  }

  void setDateRange(DateTime? f, DateTime? t) {
    from.value = f;
    to.value = t;
    loadLogs();
  }

  void clearFilters() {
    selectedCategory.value = null;
    searchQuery.value = '';
    searchController.clear();
    from.value = null;
    to.value = null;
    loadLogs();
  }

  Future<void> exportCsv() async {
    if (_storeId.isEmpty || isExporting.value) return;
    isExporting.value = true;
    try {
      final bytes = await _repo.exportCsv(
        _storeId,
        category: selectedCategory.value,
        from: _fmt(from.value),
        to: _fmt(to.value),
      );
      if (bytes == null) return;
      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        name: 'activity-log-${_fmt(DateTime.now())}.csv',
        mimeType: 'text/csv',
      );
      await SharePlus.instance.share(ShareParams(files: [file], subject: 'Store Activity Log'));
    } catch (e) {
      ToastUtil.showToast('Failed to export activity log.');
    } finally {
      isExporting.value = false;
    }
  }
}
