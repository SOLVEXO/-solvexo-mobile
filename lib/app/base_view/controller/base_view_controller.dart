import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

abstract class BaseController extends GetxController {
  final baseClient = BaseClient();

  String? userId;
  final RxBool loginUser = false.obs;
  // final RoundedLoadingButtonController btnController =
  //     RoundedLoadingButtonController();
  // final TextEditingController searchController = TextEditingController();

  // final TextEditingController statusController = TextEditingController();

  // Rx<bool> absorb = false.obs;

  // bool loggedIn = false;

  // RxList<BottomSheetModel> statusList = [
  //   BottomSheetModel(title: 'active'.tr, check: false),
  //   BottomSheetModel(title: 'disabled'.tr, check: false),
  //   BottomSheetModel(title: 'in_process'.tr, check: false),
  //   BottomSheetModel(title: 'rejected'.tr, check: false),
  //   BottomSheetModel(title: 'cancelled'.tr, check: false),
  // ].obs;

  // RxList<BottomSheetModel> exportList = [
  //   BottomSheetModel(title: 'copy'.tr, check: false),
  //   BottomSheetModel(title: 'excel'.tr, check: false),
  //   BottomSheetModel(title: 'pdf'.tr, check: false),
  // ].obs;

  @override
  void onInit() {
    super.onInit();
    isUserLogin();
  }

  Future<bool> isUserLogin() async {
    userId = await AppPreferences.getUserId();
    debugPrint("user id check: $userId");
    if (userId!.isNotEmpty) {
      loginUser.value = true;
    }
    return loginUser.value = false;
  }

  // void getUser() async {
  //   var data = AppPreferences.getUserDetails();
  //   if (data != null) {
  //     user.value = data;
  //     onUserFetch(data);
  //   }

  //   token = AppPreferences.getAccessToken();
  // }

  ///Update user
  // void updateUser() async {
  //   var data = AppPreferences.getUserDetails();

  //   if (data != null) {
  //     debugPrint("Test update user 2 ${data.firstName}");
  //     user.value = data;
  //   }
  // }

  // void onUserFetch(UserModel user) {}

  // void getLoggedIn() async {
  //   loggedIn = AppPreferences.getIsLoggedIn();
  // }

  // void showLoader(BuildContext context) {
  //   context.loaderOverlay.show();
  // }

  // void hideLoader(BuildContext context) {
  //   context.loaderOverlay.hide();
  // }

  // void startLoading() {
  //   btnController.start();
  //   absorb.value = true;
  // }

  // void stopLoading() {
  //   btnController.stop();
  //   absorb.value = false;
  // }

  // void getProfileApi() async {
  //   if (loggedIn) {
  //     var data = {ApiConstants.barberId: user.value.userId};

  //     try {
  //       var response = await baseClient.get(
  //         ApiConstants.getProfile,
  //         queryParameters: data,
  //       );

  //       BaseResponse<UserModel> baseResponse = BaseResponse.fromJson(
  //         response.data,
  //         (data) => UserModel.fromJson(data),
  //       );

  //       if (baseResponse.status == 1) {
  //         await AppPreferences.setUserDetails(user: baseResponse.data);

  //         user.value = baseResponse.data;
  //       } else {
  //         ToastUtil.showToast(baseResponse.developerMessage);
  //       }

  //       debugPrint("Got response --> ${baseResponse.developerMessage}");
  //     } on DioException catch (e) {
  //       debugPrint("Error --> $e");
  //       DioExceptionHandler.handleDioException(e);
  //     }
  //   }
  // }

  // Future<void> logout() async {
  //   _logoutApi();

  //   FcmService().unsubscribeToUserId();

  //   AppPreferences.clearPreference();

  //   // NavigationService.navigateToDashboard();
  // }

  // void _logoutApi() async {
  //   var data = {
  //     ApiConstants.userId: user.value.userId,
  //     // ApiConstants.companyId: user.value.userId,
  //     ApiConstants.firebaseToken: FcmService().fcmToken,
  //   };

  //   try {
  //     var response = await baseClient.get(
  //       ApiConstants.logout,
  //       queryParameters: data,
  //     );

  //     BaseResponse baseResponse = BaseResponse.fromJson(
  //       response.data,
  //       (data) => debugPrint("Data --> $data"),
  //     );

  //     debugPrint("Got logout response --> ${baseResponse.developerMessage}");
  //   } on DioException catch (e) {
  //     debugPrint("Error logout --> $e");
  //     DioExceptionHandler.handleDioException(e);
  //   }
  // }

  // showStatusBottomSheet(context) {
  //   return Util.showCustomBottomSheet(
  //     context,
  //     title: "select_status".tr,
  //     widget: Obx(
  //       () => ListView.builder(
  //         itemCount: statusList.length,
  //         shrinkWrap: true,
  //         itemBuilder: (context, index) {
  //           return Obx(
  //             () => BottomSheetSelectionWidget(
  //               check: statusList[index].check,
  //               onTap: () {
  //                 for (var e in statusList) {
  //                   e.check = false;
  //                 }
  //                 statusList[index].check = true;
  //                 statusController.text = statusList[index].title;
  //                 statusList.refresh();
  //                 Get.back();
  //                 print("Selected Status ${statusController.text}");
  //               },
  //               text: statusList[index].title,
  //               showSingleSelect: true,
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  // showExportBottomSheet(context) {
  //   return Util.showCustomBottomSheet(
  //     context,
  //     title: "export".tr,
  //     widget: Obx(
  //       () => ListView.builder(
  //         itemCount: exportList.length,
  //         shrinkWrap: true,
  //         itemBuilder: (context, index) {
  //           return Obx(
  //             () => BottomSheetSelectionWidget(
  //               check: exportList[index].check,
  //               onTap: () {
  //                 for (var e in exportList) {
  //                   e.check = false;
  //                 }
  //                 exportList[index].check = true;
  //                 exportList.refresh();
  //                 Get.back();
  //                 print("Selected Status ${exportList[index].title}");
  //               },
  //               text: exportList[index].title,
  //               showSingleSelect: true,
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }
}
