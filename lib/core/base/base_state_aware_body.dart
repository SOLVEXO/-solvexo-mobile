import 'package:book_store_app/core/base/base_controller.dart';
import 'package:book_store_app/core/base/base_state.dart';
import 'package:book_store_app/core/widgets/base_empty_view.dart';
import 'package:book_store_app/core/widgets/base_error_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Renders [content] normally, or a loading/error/empty view driven by
/// `controller.viewState` when [controller] extends [BaseController].
/// Controllers that are still plain `GetxController` fall through to
/// [content] unchanged — adopting this never requires touching controller
/// logic first. Shared by both [BaseView] (inheritance) and
/// [BaseViewScreen] (composition) so the state-rendering rules live in
/// exactly one place.
class BaseStateAwareBody extends StatelessWidget {
  const BaseStateAwareBody({
    super.key,
    required this.controller,
    required this.content,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  });

  final GetxController controller;
  final Widget content;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, String)? errorBuilder;
  final WidgetBuilder? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    final base = controller;
    if (base is! BaseController) return content;

    return Obx(() {
      switch (base.viewState.value) {
        case BaseViewState.loading:
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        case BaseViewState.error:
          final message = base.errorMessage.value.isEmpty
              ? 'Something went wrong. Please try again.'
              : base.errorMessage.value;
          return errorBuilder?.call(context, message) ??
              BaseErrorView(
                message: message,
                onRetry: () => base.viewState.value = BaseViewState.idle,
              );
        case BaseViewState.empty:
          return emptyBuilder?.call(context) ?? const BaseEmptyView();
        case BaseViewState.idle:
        case BaseViewState.success:
          return content;
      }
    });
  }
}
