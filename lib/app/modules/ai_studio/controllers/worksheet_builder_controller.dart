import 'package:book_store_app/app/data/models/ai_studio/ai_generate_response.dart';
import 'package:book_store_app/app/data/repositories/ai_studio_repository.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/ai_generate_handling_mixin.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class WorksheetBuilderController extends GetxController with AiGenerateHandlingMixin {
  final AiStudioRepository _repo = AiStudioRepository();

  @override
  String storeId = '';

  final subjectCtrl = TextEditingController();
  final gradeLevelCtrl = TextEditingController();
  final topicsCtrl = TextEditingController();
  final RxInt questionCount = 10.obs;
  final RxBool includeAnswerKey = true.obs;

  final Rx<AiGenerateResponse?> result = Rx<AiGenerateResponse?>(null);
  final RxBool accepted = false.obs;
  final RxBool isAccepting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    subjectCtrl.dispose();
    gradeLevelCtrl.dispose();
    topicsCtrl.dispose();
    super.onClose();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
  }

  void incrementQuestions() {
    if (questionCount.value < 40) questionCount.value++;
  }

  void decrementQuestions() {
    if (questionCount.value > 1) questionCount.value--;
  }

  Future<void> generate() => _generate();
  Future<void> regenerate() => _generate(regenerateFromId: result.value?.generationId);

  Future<void> _generate({String? regenerateFromId}) async {
    final subject = subjectCtrl.text.trim();
    final gradeLevel = gradeLevelCtrl.text.trim();
    final topics = topicsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    if (subject.isEmpty || gradeLevel.isEmpty) {
      ToastUtil.showToast('Enter a subject and grade level');
      return;
    }
    if (topics.isEmpty) {
      ToastUtil.showToast('Enter at least one topic');
      return;
    }

    final response = await runGenerate(() => _repo.generateWorksheet(
          storeId,
          subject: subject,
          gradeLevel: gradeLevel,
          topics: topics,
          questionCount: questionCount.value,
          includeAnswerKey: includeAnswerKey.value,
          regenerateFromId: regenerateFromId,
        ));
    if (response != null) {
      result.value = response;
      accepted.value = false;
    }
  }

  Future<void> accept() async {
    final current = result.value;
    if (current == null || isAccepting.value) return;
    isAccepting.value = true;
    final updated = await _repo.acceptGeneration(storeId, current.generationId);
    isAccepting.value = false;
    if (updated != null) {
      accepted.value = true;
      ToastUtil.showToast('Marked as accepted');
    }
  }
}
