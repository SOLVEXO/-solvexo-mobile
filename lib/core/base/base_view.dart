import 'package:book_store_app/core/base/base_controller.dart';
import 'package:book_store_app/core/base/base_state.dart';
import 'package:book_store_app/core/base/base_state_aware_body.dart';
import 'package:book_store_app/core/widgets/base_empty_view.dart';
import 'package:book_store_app/core/widgets/base_error_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Inheritance-based screen base, kept for the handful of screens already
/// built on it (home, auth tabs, profile, cart, notifications, my orders,
/// wishlist). **New screens should use `BaseViewScreen`
/// (`lib/core/widgets/base_view_screen.dart`) instead** — a `StatelessWidget`
/// composed with `BaseViewScreen(child: ...)` rather than subclassed — so
/// views stay plain widgets. This class and `BaseViewScreen` share the same
/// state-rendering rules via `BaseStateAwareBody`.
///
/// ```dart
/// class HomeView extends BaseView<HomeController> {
///   const HomeView({super.key});
///
///   @override
///   Widget buildBody(BuildContext context) => ...;
/// }
/// ```
///
/// Automatically wires up SafeArea, keyboard-dismiss-on-tap, pull-to-refresh
/// (when [onRefresh] is overridden), and — for controllers that extend the
/// new [BaseController] — loading/error/empty rendering driven by
/// `controller.viewState`. Screens whose controller is still a plain
/// `GetxController` (i.e. every screen not yet migrated) get `buildBody`
/// rendered directly, so adopting `BaseView` never requires touching
/// controller logic first.
abstract class BaseView<T extends GetxController> extends StatelessWidget {
  const BaseView({super.key});

  T get controller => Get.find<T>();

  // ── Screen chrome — override only what a given screen needs ─────────────
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;
  Widget? buildFloatingActionButton(BuildContext context) => null;
  Widget? buildBottomNavigationBar(BuildContext context) => null;
  Color? get backgroundColor => null;
  bool get resizeToAvoidBottomInset => true;
  bool get dismissKeyboardOnTap => true;
  bool get useSafeArea => true;
  Future<void> Function()? get onRefresh => null;

  /// The screen's real content.
  Widget buildBody(BuildContext context);

  Widget buildLoading(BuildContext context) => const Center(child: CircularProgressIndicator());

  Widget buildErrorState(BuildContext context, String message) => BaseErrorView(
        message: message,
        onRetry: () {
          final c = controller;
          if (c is BaseController) c.viewState.value = BaseViewState.idle;
        },
      );

  Widget buildEmptyState(BuildContext context) => const BaseEmptyView();

  @override
  Widget build(BuildContext context) {
    Widget body = BaseStateAwareBody(
      controller: controller,
      content: buildBody(context),
      loadingBuilder: buildLoading,
      errorBuilder: buildErrorState,
      emptyBuilder: buildEmptyState,
    );

    if (useSafeArea) body = SafeArea(child: body);

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
      appBar: buildAppBar(context),
      floatingActionButton: buildFloatingActionButton(context),
      bottomNavigationBar: buildBottomNavigationBar(context),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: body,
    );
  }
}
