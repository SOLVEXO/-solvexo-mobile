import 'package:book_store_app/app/data/repositories/worksheet_trial_repository.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Standalone, unauthenticated worksheet-builder trial — a taste of AI
/// Studio for buyers/guests. Deliberately simpler than the seller-only
/// `WorksheetBuilderController`: no storeId, no credits, no accept/regenerate
/// flow, and tighter caps (≤5 topics, 1-6 questions) matching the backend's
/// public trial contract.
class WorksheetTrialController extends GetxController {
  WorksheetTrialController({WorksheetTrialRepository? repository})
    : _repo = repository ?? WorksheetTrialRepository();

  final WorksheetTrialRepository _repo;

  static const int maxTopics = 5;
  static const int minQuestions = 1;
  static const int maxQuestions = 6;

  final subjectCtrl = TextEditingController();
  final gradeLevelCtrl = TextEditingController();
  final topicsCtrl = TextEditingController();
  final RxInt questionCount = 5.obs;
  final RxBool includeAnswerKey = true.obs;

  final RxBool isGenerating = false.obs;
  final Rx<Map<String, dynamic>?> result = Rx<Map<String, dynamic>?>(null);

  @override
  void onClose() {
    subjectCtrl.dispose();
    gradeLevelCtrl.dispose();
    topicsCtrl.dispose();
    super.onClose();
  }

  void incrementQuestions() {
    if (questionCount.value < maxQuestions) questionCount.value++;
  }

  void decrementQuestions() {
    if (questionCount.value > minQuestions) questionCount.value--;
  }

  Future<void> generate() async {
    if (isGenerating.value) return;

    final subject = subjectCtrl.text.trim();
    final gradeLevel = gradeLevelCtrl.text.trim();
    var topics = topicsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (subject.isEmpty || gradeLevel.isEmpty) {
      ToastUtil.showToast('Enter a subject and grade level');
      return;
    }
    if (topics.isEmpty) {
      ToastUtil.showToast('Enter at least one topic');
      return;
    }
    if (topics.length > maxTopics) {
      topics = topics.sublist(0, maxTopics);
    }

    isGenerating.value = true;
    final outcome = await _repo.tryFree(
      subject: subject,
      gradeLevel: gradeLevel,
      topics: topics,
      questionCount: questionCount.value,
      includeAnswerKey: includeAnswerKey.value,
    );
    isGenerating.value = false;

    if (outcome.success) {
      result.value = outcome.output;
    } else {
      ToastUtil.showToast(
        outcome.message ?? 'Something went wrong. Please try again.',
      );
    }
  }
}
