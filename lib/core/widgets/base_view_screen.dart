import 'package:book_store_app/core/base/base_state_aware_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The wrapper every screen composes around its content:
///
/// ```dart
/// class HomeView extends StatelessWidget {
///   const HomeView({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final controller = Get.find<HomeController>();
///     return BaseViewScreen(
///       controller: controller,
///       appBar: MainAppBar(...),
///       child: ...,
///     );
///   }
/// }
/// ```
///
/// Views stay plain `StatelessWidget`s — this is composition, not
/// inheritance. Wires up `Scaffold`/`SafeArea`/keyboard-dismiss/pull-to-
/// refresh, and — when [controller] extends `BaseController` — loading/
/// error/empty rendering driven by `controller.viewState` (via the same
/// `BaseStateAwareBody` used by the legacy `BaseView<T>`). Pass no
/// [controller] for screens with no GetX controller (e.g. a pure role
/// picker) and [child] renders as-is.
class BaseViewScreen extends StatelessWidget {
  const BaseViewScreen({
    super.key,
    required this.child,
    this.controller,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.padding,
    this.useSafeArea = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.resizeToAvoidBottomInset = true,
    this.dismissKeyboardOnTap = true,
    this.onRefresh,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  });

  final Widget child;
  final GetxController? controller;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool resizeToAvoidBottomInset;
  final bool dismissKeyboardOnTap;
  final Future<void> Function()? onRefresh;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, String)? errorBuilder;
  final WidgetBuilder? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    Widget content = padding != null ? Padding(padding: padding!, child: child) : child;

    final ctrl = controller;
    Widget body = ctrl != null
        ? BaseStateAwareBody(
            controller: ctrl,
            content: content,
            loadingBuilder: loadingBuilder,
            errorBuilder: errorBuilder,
            emptyBuilder: emptyBuilder,
          )
        : content;

    if (useSafeArea) {
      body = SafeArea(top: safeAreaTop, bottom: safeAreaBottom, child: body);
    }

    final refresh = onRefresh;
    if (refresh != null) body = RefreshIndicator(onRefresh: refresh, child: body);

    if (dismissKeyboardOnTap) {
      body = GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: body,
    );
  }
}
