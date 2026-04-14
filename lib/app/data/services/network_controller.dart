import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkController extends GetxController {
  var isConnected = true.obs;

  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();

    _checkConnection();

    _connectivity.onConnectivityChanged.listen((result) {
      isConnected.value = result != ConnectivityResult.none;
    });
  }

  void _checkConnection() async {
    var result = await _connectivity.checkConnectivity();
    isConnected.value = result != ConnectivityResult.none;
  }
}
