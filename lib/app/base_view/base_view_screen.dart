import 'dart:io';

import 'package:book_store_app/app/bottom_bar/widget/dashboard_bottom_nav.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/main_app_bar.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BaseViewScreen extends StatelessWidget {
  const BaseViewScreen({
    super.key,
    this.issearch = false,
    required this.child,
    this.size = 22,
    this.onPressed,
    this.actionIcon = AppIcons.heartIcon,
    this.background,
    this.showBottomBar = false,
    this.mainAppBar = false,
    this.horizontalPadding = true,
    this.verticalPadding = true,
    this.screenName,
    this.hasBackButton = true,
    this.backgroundColor,
    this.showAppBar = true,
    this.centerTitle = false,
    this.resizeToAvoidBottomInset,
    this.customBottomBar,
    this.actions,
    this.actions2,
    this.titleWidget,
    this.onBackPressed,
    this.floatingActionButton,
    this.backImage = AppIcons.chevronLeft,
    this.backIconColor = AppColors.black,
    this.titleColor = AppColors.black,
    this.appBarBackgroundColor = AppColors.white,
    this.titleSpacing = 0,
    this.height = 50,
    this.showPattern = true,
    this.customFlexibleSpace,
    this.extendedAppBar = false,
    this.readOnly = false,
    this.canPop = true,
    this.safeAreaTop = true,
    this.onPopInvoked,
    this.onChanged,
    this.onSearchTap,
    this.showCustomAppBar = false,
    this.showSearchBar = false,
    this.showHomeAppBar = false,
    this.showLeadingIcons = false,
    this.leadingWidget,
    this.useInnerAppBar = false,
    this.changeBrightnessIcon = false,
    this.showLeadingWidgetWithOutSearchBar = false,
    this.bottomBarShadow = true,
    this.appBarChild,
    this.floatingActionButtonLocation,
  });

  final Widget child;
  final Widget? background;
  final bool? bottomBarShadow;
  final bool mainAppBar;
  final Widget? appBarChild;
  final bool issearch;
  final bool showBottomBar;
  final bool horizontalPadding;
  final bool verticalPadding;
  final bool hasBackButton;
  final bool centerTitle;
  final String backImage;
  final double size;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final String actionIcon;
  final Function()? onPressed;
  final double titleSpacing;
  final double height;
  final String? screenName;
  final Color? backgroundColor;
  final Color appBarBackgroundColor;
  final Color backIconColor;
  final Color titleColor;
  final bool showAppBar;
  final bool extendedAppBar;
  final Widget? customFlexibleSpace;
  final bool showPattern;
  final bool? resizeToAvoidBottomInset;
  final Widget? customBottomBar;
  final List<Widget>? actions;
  final List<Widget>? actions2;
  final Widget? titleWidget;
  final Widget? floatingActionButton;
  final Function()? onBackPressed;
  final void Function(bool)? onPopInvoked;
  final Function(String)? onChanged;
  final Function? onSearchTap;
  final bool canPop;
  final bool readOnly;
  final bool safeAreaTop;
  final bool showHomeAppBar;
  final bool showCustomAppBar;
  final bool showSearchBar;
  final bool showLeadingIcons;
  final Widget? leadingWidget;
  final bool useInnerAppBar;
  final bool changeBrightnessIcon;
  final bool showLeadingWidgetWithOutSearchBar;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: onPopInvoked,
      child: Stack(
        children: [
          // // Background image or fallback plain background
          // background ??
          //     const CommonImageView(
          //       imagePath: AppImages.transparentLogo,
          //       width: double.infinity,
          //     ),
          Scaffold(
            extendBody: true,
            backgroundColor: backgroundColor ?? AppColors.transparent,
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
            floatingActionButtonLocation: floatingActionButtonLocation,
            // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            // App Bar
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(showCustomAppBar ? height : 0),
              child: Visibility(
                visible: showCustomAppBar,
                child: mainAppBar
                    ? MainAppBar(
                        height: height,
                        issearch: issearch,
                        size: size,
                        actionIcon: actionIcon,
                        onPressed: onPressed,
                      )
                    : CustomAppBarTwo(
                        appbarHeight: height,
                        title: screenName ?? '',
                        showBackButton: hasBackButton,
                        // centerTitle: centerTitle,
                        actions: actions,
                        backgroundColor: appBarBackgroundColor,
                        color: titleColor,
                        iconColor: backIconColor,
                        onBack: onBackPressed,
                        child: appBarChild,
                      ),
              ),
            ),

            // Bottom Bar
            bottomNavigationBar: SafeArea(
              maintainBottomViewPadding: true,
              bottom: Platform.isAndroid,
              // minimum: EdgeInsets.only(bottom: 10),
              // bottom: Platform.isAndroid,
              child:
                  customBottomBar ??
                  Visibility(
                    visible: showBottomBar,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: 1.0,
                      child: DashboardBottomNav(
                        showShadow: bottomBarShadow ?? true,
                      ),
                    ),
                  ),
            ),

            // Main Body
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                top: safeAreaTop,
                bottom: Platform.isAndroid,
                maintainBottomViewPadding: true,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding
                        ? AppDimen.horizontalPadding.w
                        : 0,
                    vertical: verticalPadding ? AppDimen.verticalPadding.h : 0,
                  ),
                  child: child,
                ),
              ),
            ),

            floatingActionButton: floatingActionButton,
          ),
        ],
      ),
    );
  }
}
