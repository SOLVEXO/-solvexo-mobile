import 'dart:io';

import 'package:book_store_app/app/data/models/refund_request_model.dart';
import 'package:book_store_app/app/data/models/return_reasons.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/data/repositories/refund_request_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_item_model.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Returns & refunds form (B5, docs §2.7; backend 5adba44):
/// - "Return the item" (physical, delivered) -> POST /api/orders/return-request/:orderId
/// - "Refund only" -> POST /api/refund-request (one seller's items)
/// Both take the ONE reason list (reasonCode), a note of 20-1000 characters
/// and up to 4 photos (uploaded images; physical items only).
/// The status list shows every request with its timeline and the seller's
/// reject reason. Argument: the OrderModel.
class RefundRequestController extends GetxController {
  RefundRequestController({RefundRequestRepository? refunds, OrderRepository? orders, UploadRepository? uploads, OrderModel? order})
      : _refunds = refunds ?? RefundRequestRepository(),
        _orders = orders ?? OrderRepository(),
        _uploads = uploads ?? UploadRepository(),
        _orderOverride = order;

  final RefundRequestRepository _refunds;
  final OrderRepository _orders;
  final UploadRepository _uploads;
  final OrderModel? _orderOverride;

  late final OrderModel order;
  late final List<OrderStore> eligibleStores;

  final Rx<OrderStore?> selectedStore = Rx<OrderStore?>(null);
  final RxSet<String> selectedItemIds = <String>{}.obs;

  /// 'return' (send the item back) | 'refund' (refund only).
  final RxString kind = 'refund'.obs;
  final RxnString reasonCode = RxnString();
  final noteController = TextEditingController();
  final RxList<String> photos = <String>[].obs;
  final RxBool uploading = false.obs;
  final RxMap<String, String> errors = <String, String>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingStatuses = true.obs;
  final RxBool statusFailed = false.obs;
  final RxList<RefundRequestModel> existingRequests = <RefundRequestModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    order = _orderOverride ?? Get.arguments as OrderModel;
    eligibleStores = order.stores.where(_storeHasReturnableItems).toList();
    if (eligibleStores.length == 1) selectedStore.value = eligibleStores.first;
    loadExistingRequests();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  bool _storeHasReturnableItems(OrderStore s) =>
      (s.status == 'delivered' || s.status == 'completed') && s.items.any(isItemReturnable);

  /// Not already returned / refunded, and not in an open or approved request.
  bool isItemReturnable(OrderItem i) => i.returnStatus == 'none' && !_requestedItemIds.contains(i.itemId);

  Set<String> get _requestedItemIds =>
      existingRequests.where((r) => r.isPending || r.isApproved).expand((r) => r.itemIds).toSet();

  List<OrderItem> get returnableItems => selectedStore.value?.items.where(isItemReturnable).toList() ?? const [];

  List<OrderItem> get selectedItems => returnableItems.where((i) => selectedItemIds.contains(i.itemId)).toList();
  bool get selectionIsDigital => selectedItems.isNotEmpty && selectedItems.every((i) => i.type == 'digital');
  bool get canSendBack => selectedItems.isNotEmpty && selectedItems.every((i) => i.type == 'physical');

  /// Items with an item-return status (from the order) for the status list.
  List<OrderItem> get itemReturns => [for (final s in order.stores) ...s.items.where((i) => i.returnStatus != 'none')];

  List<(String, String)> get reasons => ReturnRules.reasonsFor(digital: selectionIsDigital);

  void selectStore(OrderStore s) {
    selectedStore.value = s;
    selectedItemIds.clear();
  }

  void toggleItem(String id) {
    selectedItemIds.contains(id) ? selectedItemIds.remove(id) : selectedItemIds.add(id);
    if (!canSendBack) kind.value = 'refund';
    if (reasonCode.value != null && !reasons.any((r) => r.$1 == reasonCode.value)) reasonCode.value = null;
    errors.remove('items');
  }

  Future<void> addPhoto(File f) async {
    if (photos.length >= ReturnRules.maxPhotos || uploading.value) return;
    uploading.value = true;
    final url = await _uploads.uploadImage(f);
    uploading.value = false;
    if (url == null) {
      ToastUtil.showToast('Photo upload failed. Please retry.'.tr);
      return;
    }
    photos.add(url);
  }

  bool validate() {
    final e = <String, String>{};
    if (selectedItems.isEmpty) e['items'] = 'Choose at least one item.'.tr;
    if (reasonCode.value == null) e['reason'] = 'Choose a reason.'.tr;
    final n = ReturnRules.note(noteController.text);
    if (n != null) e['note'] = n;
    errors.assignAll(e);
    return e.isEmpty;
  }

  Future<void> submit() async {
    final store = selectedStore.value;
    if (store == null || isLoading.value || !validate()) return;
    isLoading.value = true;
    final ids = selectedItems.map((i) => i.itemId).toList();
    final images = selectionIsDigital ? const <String>[] : photos.toList();
    final ok = kind.value == 'return' && canSendBack
        ? await _orders.requestReturn(orderId: order.orderId, itemIds: ids, reasonCode: reasonCode.value!, note: noteController.text.trim(), evidenceImages: images)
        : await _refunds.create(
            orderId: order.orderId,
            sellerOrderId: store.sellerOrderId,
            itemIds: ids,
            reasonCode: reasonCode.value!,
            note: noteController.text.trim(),
            evidenceImages: images,
          );
    isLoading.value = false;
    if (!ok) return; // the repository shows the server's message
    ToastUtil.showToast(kind.value == 'return' ? 'Return request sent'.tr : 'Refund request sent'.tr);
    noteController.clear();
    reasonCode.value = null;
    photos.clear();
    selectedItemIds.clear();
    if (eligibleStores.length > 1) selectedStore.value = null;
    await loadExistingRequests();
  }

  Future<void> loadExistingRequests() async {
    isLoadingStatuses.value = true;
    statusFailed.value = false;
    try {
      existingRequests.assignAll(await _refunds.listForOrder(order.orderId));
    } catch (_) {
      statusFailed.value = true;
    }
    isLoadingStatuses.value = false;
  }
}
