import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:book_store_app/app/data/repositories/seller_students_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

/// Students roster (checklist #14b). Optional argument {productId}.
class StudentsController extends GetxController {
  StudentsController({SellerStudentsRepository? repository, String? storeId})
      : _repo = repository ?? SellerStudentsRepository(),
        _storeIdOverride = storeId;

  final SellerStudentsRepository _repo;
  final String? _storeIdOverride;
  String _storeId = '';

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool failed = false.obs;
  final RxBool exporting = false.obs;
  final RxSet<String> opening = <String>{}.obs;
  final Rx<RosterPage> page = const RosterPage().obs;
  final RxList<StudentRow> rows = <StudentRow>[].obs;

  final Rx<StudentStatus> status = StudentStatus.all.obs;
  final Rx<StudentSort> sort = StudentSort.activity.obs;
  final RxnString productId = RxnString();
  final RxString query = ''.obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    if (a is Map && a['productId'] is String) productId.value = a['productId'] as String;
    load();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    failed.value = false;
    _storeId = _storeIdOverride ?? await AppPreferences.getStoreId() ?? '';
    try {
      final p = await _repo.roster(_storeId,
          status: status.value, productId: productId.value, q: query.value, sort: sort.value);
      page.value = p;
      rows.assignAll(p.rows);
    } catch (_) {
      failed.value = true;
    }
    isLoading.value = false;
  }

  bool get hasMore => page.value.page < page.value.totalPages;

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final p = await _repo.roster(_storeId,
          status: status.value, productId: productId.value, q: query.value, sort: sort.value, page: page.value.page + 1);
      page.value = p;
      rows.addAll(p.rows);
    } catch (_) {
      ToastUtil.showToast('Could not load more students.');
    }
    isLoadingMore.value = false;
  }

  void setStatus(StudentStatus s) {
    status.value = s;
    load();
  }

  void setSort(StudentSort s) {
    sort.value = s;
    load();
  }

  void setProduct(String? id) {
    productId.value = id;
    load();
  }

  void onSearch(String q) {
    query.value = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), load);
  }

  Future<void> exportCsv() async {
    if (exporting.value) return;
    exporting.value = true;
    try {
      final csv = await _repo.exportCsv(_storeId, status: status.value, productId: productId.value, q: query.value);
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(Uint8List.fromList(utf8.encode(csv)), name: 'students.csv', mimeType: 'text/csv')],
        subject: 'Students',
      ));
    } catch (_) {
      ToastUtil.showToast('Could not export the list.');
    } finally {
      exporting.value = false;
    }
  }

  Future<void> message(StudentRow s) async {
    if (s.buyerId.isEmpty || opening.contains(s.buyerId)) return;
    opening.add(s.buyerId);
    try {
      final r = await _repo.startConversation(_storeId, s.buyerId);
      if (r.conversationId == null) {
        ToastUtil.showToast(r.message ?? 'Could not open a chat.');
        return;
      }
      await Get.toNamed(Routes.chatView, arguments: {'conversationId': r.conversationId, 'peerName': s.name});
    } finally {
      opening.remove(s.buyerId);
    }
  }
}
