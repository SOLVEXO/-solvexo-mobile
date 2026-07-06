import 'package:get/get.dart';

/// A `Bindings` that registers exactly one lazily-built controller —
/// cuts the usual 5-line boilerplate binding file down to one line at the
/// call site: `BaseBindings(HomeController.new)`.
class BaseBindings<T> extends Bindings {
  final T Function() builder;
  final bool fenix;

  BaseBindings(this.builder, {this.fenix = false});

  @override
  void dependencies() {
    Get.lazyPut<T>(builder, fenix: fenix);
  }
}
