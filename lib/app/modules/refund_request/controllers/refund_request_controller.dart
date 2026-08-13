import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/data/models/enums/enums.dart';
import 'package:book_store_app/app/data/models/refund_request_model.dart';
import 'package:book_store_app/app/data/repositories/refund_request_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_item_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Item-level refund request flow — `POST /api/refund-request`
/// (`refund-request.service.ts`). Supersedes the old single-`reason`-string
/// `orders/return-request/:orderId` flow: a request now targets exactly one
/// seller's items (`sellerOrderId`) within the order, so the buyer first
/// picks a store (skipped automatically when only one is eligible), then the
/// items within it, then the issue + optional note.
class RefundRequestController extends GetxController {
  final RefundRequestRepository _repo = RefundRequestRepository();

  late final OrderModel order;

  /// Stores that have at least one item eligible for a refund request,
  /// mirroring `OrderModel.canRequestReturn`'s per-store eligibility rule.
  late final List<OrderStore> eligibleStores;

  final Rx<OrderStore?> selectedStore = Rx<OrderStore?>(null);
  final RxSet<String> selectedItemIds = <String>{}.obs;
  final RxBool itemsConfirmed = false.obs;
  final Rx<RefundIssue?> selectedIssue = Rx<RefundIssue?>(null);
  final messageController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingStatuses = true.obs;
  final RxList<RefundRequestModel> existingRequests = <RefundRequestModel>[].obs;

  final issues = {
    RefundIssue.missing: "Missing product or accessories",
    RefundIssue.notReceived: "Package wasn't received",
    RefundIssue.notAsDescribed: "Product doesn't match description",
    RefundIssue.damaged: "Package or product is damaged",
    RefundIssue.wrongItem: "Wrong product was sent",
    RefundIssue.defective: "Product is defective or doesn't work",
    RefundIssue.counterfeit: "Suspected counterfeit",
  };

  @override
  void onInit() {
    super.onInit();
    order = Get.arguments as OrderModel;
    eligibleStores = order.stores.where(_storeHasReturnableItems).toList();
    if (eligibleStores.length == 1) {
      selectedStore.value = eligibleStores.first;
    }
    _loadExistingRequests();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  bool _storeHasReturnableItems(OrderStore store) {
    return (store.status == 'delivered' || store.status == 'completed') &&
        store.items.any((i) => _isItemReturnable(i));
  }

  bool _isItemReturnable(OrderItem item) {
    if (item.type != 'physical') return false;
    if (item.returnStatus != 'none') return false;
    return !_requestedItemIds.contains(item.itemId);
  }

  /// itemIds already covered by a pending or approved refund request — a new
  /// pending/approved request for the same item is rejected server-side, so
  /// they're filtered out of the picker once known.
  Set<String> get _requestedItemIds => existingRequests
      .where((r) => r.isPending || r.isApproved)
      .expand((r) => r.itemIds)
      .toSet();

  /// Eligible items within the currently selected store.
  List<OrderItem> get returnableItems {
    final store = selectedStore.value;
    if (store == null) return [];
    return store.items.where(_isItemReturnable).toList();
  }

  bool get canConfirmItems => selectedItemIds.isNotEmpty;
  bool get canContinue => selectedIssue.value != null;

  void selectStore(OrderStore store) {
    selectedStore.value = store;
    selectedItemIds.clear();
    itemsConfirmed.value = false;
  }

  void changeStore() {
    selectedStore.value = null;
    selectedItemIds.clear();
    itemsConfirmed.value = false;
  }

  void toggleItem(String itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
  }

  void confirmItems() {
    if (!canConfirmItems) return;
    itemsConfirmed.value = true;
  }

  Future<void> _loadExistingRequests() async {
    isLoadingStatuses.value = true;
    final requests = await _repo.listForOrder(order.orderId);
    existingRequests.assignAll(requests);
    isLoadingStatuses.value = false;
  }

  Future<void> submitRefund() async {
    final store = selectedStore.value;
    if (store == null || !canConfirmItems || !canContinue || isLoading.value) return;

    final issueLabel = issues[selectedIssue.value]!;
    final note = messageController.text.trim();
    final reason = note.isEmpty ? issueLabel : '$issueLabel — $note';

    isLoading.value = true;
    final success = await _repo.create(
      orderId: order.orderId,
      sellerOrderId: store.sellerOrderId,
      itemIds: selectedItemIds.toList(),
      reason: reason,
    );
    isLoading.value = false;

    if (success) {
      CustomAppSnackbar.success("Refund request submitted");
      messageController.clear();
      selectedIssue.value = null;
      selectedItemIds.clear();
      itemsConfirmed.value = false;
      // Only auto-clear the store when more than one is eligible — with a
      // single store there's nothing to re-pick between.
      if (eligibleStores.length > 1) selectedStore.value = null;
      await _loadExistingRequests();
    }
    // On failure the repository already surfaces the specific backend
    // message (e.g. "not yet delivered", "already has a pending request")
    // via ToastUtil.
  }
}
