import 'package:book_store_app/app/data/models/ai_studio/ai_generate_response.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/insufficient_credits_sheet.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

/// Shared "run a generate call, handle insufficient credits, surface
/// failures" flow — identical across all 6 AI Studio tools, so each tool
/// controller mixes this in instead of re-implementing it.
mixin AiGenerateHandlingMixin on GetxController {
  String get storeId;
  final RxBool isGenerating = false.obs;

  Future<T?> runGenerate<T>(Future<AiGenerateOutcome<T>> Function() call) async {
    if (isGenerating.value) return null;
    isGenerating.value = true;
    final outcome = await call();
    isGenerating.value = false;

    if (outcome.isSuccess) return outcome.data;

    if (outcome.insufficientCredits) {
      final bought = await InsufficientCreditsSheet.show(
        storeId: storeId,
        required: outcome.requiredCredits,
        balance: outcome.currentBalance,
        message: outcome.message,
      );
      if (bought) return runGenerate(call);
      return null;
    }

    if (outcome.message != null) ToastUtil.showToast(outcome.message!);
    return null;
  }
}
