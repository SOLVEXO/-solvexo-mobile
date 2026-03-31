import 'package:get/get.dart';

class RefreshControllerX extends GetxController {
  var pullDistance = 0.0.obs;
  var isRefreshing = false.obs;

  void updatePull(double value) {
    if (!isRefreshing.value) {
      pullDistance.value += value;
    }
  }

  void resetPull() {
    pullDistance.value = 0;
  }

  Future<void> handleRefresh(Future<void> Function() onRefresh) async {
    if (isRefreshing.value) return;

    isRefreshing.value = true;

    await onRefresh();

    isRefreshing.value = false;
    pullDistance.value = 0;
  }
}
