// import 'package:aldermin/app/bottom_bar/custom_bottom_bar.dart';
// import 'package:aldermin/app/components/widgets/common_image_view.dart';
// import 'package:aldermin/app/components/widgets/custom_app_bar.dart';
// import 'package:aldermin/app/components/widgets/custom_divider.dart';
// import 'package:aldermin/app/components/widgets/custom_text.dart';
// import 'package:aldermin/app/components/widgets/textFields_widgets/search_text_field.dart';
// import 'package:aldermin/config/resources/app_colors.dart';
// import 'package:aldermin/config/resources/app_images.dart';
// import 'package:aldermin/utils/dimens.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';

// class BaseViewScreen extends StatelessWidget {
//   const BaseViewScreen({
//     super.key,
//     required this.child,
//     this.showBottomBar = true,
//     this.horizontalPadding = true,
//     this.verticalPadding = true,
//     this.screenName,
//     this.hasBackButton = true,
//     this.backgroundColor,
//     this.showAppBar = true,
//     this.centerTitle = false,
//     this.resizeToAvoidBottomInset,
//     this.customBottomBar,
//     this.actions,
//     this.actions2,
//     this.titleWidget,
//     this.onBackPressed,
//     this.floatingActionButton,
//     this.backImage = AppImages.back,
//     this.backIconColor = AppColors.white,
//     this.titleColor = AppColors.black2,
//     this.appBarBackgroundColor = AppColors.white,
//     this.titleSpacing = 0,
//     this.height = 70,
//     this.showPattern = true,
//     this.customFlexibleSpace,
//     this.extendedAppBar = false,
//     this.readOnly = false,
//     this.canPop = true,
//     this.safeAreaTop = true,
//     this.onPopInvoked,
//     this.onChanged,
//     this.onSearchTap,
//     this.showCustomAppBar = false,
//     this.showSearchBar = false,
//     this.showHomeAppBar = false,
//     this.showLeadingIcons = false,
//     this.leadingWidget,
//     this.searchController,
//     this.useInnerAppBar = false,
//     this.changeBrightnessIcon = true,
//     this.showLeadingWidgetWithOutSearchBar = false,
//   });

//   final bool showBottomBar;
//   final bool horizontalPadding;
//   final bool verticalPadding;
//   final bool hasBackButton;

//   final bool centerTitle;
//   final String backImage;
//   final double titleSpacing;

//   final double height;
//   final String? screenName;
//   final Color? backgroundColor;
//   final Color appBarBackgroundColor;
//   final Color backIconColor;
//   final Color titleColor;
//   final bool showAppBar;
//   final bool extendedAppBar;
//   final Widget? customFlexibleSpace;
//   final bool showPattern;
//   final bool? resizeToAvoidBottomInset;
//   final Widget child;
//   final TextEditingController? searchController;
//   final Widget? customBottomBar;
//   final List<Widget>? actions;
//   final List<Widget>? actions2;
//   final Widget? titleWidget;
//   final Widget? floatingActionButton;
//   final Function()? onBackPressed;
//   final void Function(bool)? onPopInvoked;
//   final Function(String)? onChanged;
//   final Function? onSearchTap;
//   final bool canPop;
//   final bool readOnly;
//   final bool safeAreaTop;
//   final bool showHomeAppBar;
//   final bool showCustomAppBar;
//   final bool showSearchBar;
//   final bool showLeadingIcons;
//   final Widget? leadingWidget;
//   final bool useInnerAppBar;
//   final bool changeBrightnessIcon;
//   final bool showLeadingWidgetWithOutSearchBar;

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: canPop,
//       onPopInvoked: onPopInvoked,
//       child: Scaffold(
//         extendBody: true,
//         backgroundColor: AppColors.white,
//         extendBodyBehindAppBar: true,
//         resizeToAvoidBottomInset: true,
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(showCustomAppBar ? height : 0),
//           child: Visibility(
//             visible: showCustomAppBar,
//             child: CustomAppBar(
//               titleSpacing: titleSpacing,
//               title: screenName ?? "",
//               hasBackButton: hasBackButton,
//               centerTitle: centerTitle,
//               actions: actions,
//               backImage: backImage,
//               backgroundColor: appBarBackgroundColor,
//               titleColor: titleColor,
//               backIconColor: backIconColor,
//               titleWidget: titleWidget,
//               onBackPressed: onBackPressed,
//               showPattern: showPattern,
//               leadingWidget: showLeadingWidgetWithOutSearchBar
//                   ? innerScreenLeadingWidgetWithoutSearchBar(screenName ?? '')
//                   : useInnerAppBar
//                   ? innerScreenLeadingWidget(screenName ?? '')
//                   : leadingWidget,
//               changeBrightnessIcons: changeBrightnessIcon,
//               // customFlexibleSpace: customFlexibleSpace,
//             ),
//           ),
//         ),
//         bottomNavigationBar:
//             customBottomBar ??
//             Visibility(
//               visible: showBottomBar,
//               child: AnimatedOpacity(
//                 duration: const Duration(milliseconds: 500),
//                 opacity: 1.0,
//                 child: CustomBottomBar(),
//               ),
//             ),
//         body: GestureDetector(
//           onTap: () {
//             FocusScope.of(context).requestFocus(FocusNode());
//           },
//           child: SafeArea(
//             top: safeAreaTop,
//             bottom: false,
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: horizontalPadding
//                     ? AppDimen.horizontalPadding.w
//                     : 0,
//                 // vertical: verticalPadding ? AppDimen.verticalPadding.h : 0,
//               ),
//               child: child,
//             ),
//           ),
//         ),
//         floatingActionButton: floatingActionButton,
//       ),
//     );
//   }

//   innerScreenLeadingWidget(String screenName) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: AppDimen.horizontalPadding.w,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             spacing: 10,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Get.back();
//                 },
//                 child: CommonImageView(
//                   svgPath: backImage,
//                   height: 24,
//                   width: 24,
//                 ),
//               ),
//               CustomText(
//                 text: screenName,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.black,
//               ),
//             ],
//           ),
//         ),
//         Visibility(
//           visible: showSearchBar,
//           child: Padding(
//             padding: EdgeInsets.only(
//               left: AppDimen.horizontalPadding.w,
//               right: AppDimen.horizontalPadding.w,
//               top: 10,
//             ),
//             child: Row(
//               spacing: 10,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Expanded(
//                   child: SearchTextField(
//                     onTap: onSearchTap,
//                     controller: searchController ?? TextEditingController(),
//                     autoFocus: false,
//                     prefixWidget: const Padding(
//                       padding: EdgeInsets.only(left: 8, right: 8),
//                       child: CommonImageView(
//                         height: 20,
//                         width: 20,
//                         svgPath: AppImages.searchIcon,
//                         color: AppColors.greyColor,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     onChanged: onChanged,
//                     onFieldSubmit: (value) {},
//                     readOnly: readOnly,
//                     hintText: "search".tr,
//                   ),
//                 ),
//                 Row(spacing: 10, children: actions2 ?? []),
//               ],
//             ),
//           ),
//         ),
//         const CustomDivider(),
//       ],
//     );
//   }

//   innerScreenLeadingWidgetWithoutSearchBar(String screenName) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: AppDimen.horizontalPadding.w,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 spacing: 10,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Get.back();
//                     },
//                     child: CommonImageView(
//                       svgPath: backImage,
//                       height: 24,
//                       width: 24,
//                     ),
//                   ),
//                   CustomText(
//                     text: screenName,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.black,
//                   ),
//                 ],
//               ),
//               Row(
//                 spacing: 10,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [Row(spacing: 10, children: actions2 ?? [])],
//               ),
//             ],
//           ),
//         ),
//         const CustomDivider(),
//       ],
//     );
//   }
// }
