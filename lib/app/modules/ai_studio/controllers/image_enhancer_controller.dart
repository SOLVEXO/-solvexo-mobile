import 'dart:async';
import 'dart:io';

import 'package:book_store_app/app/data/models/ai_studio/ai_generate_response.dart';
import 'package:book_store_app/app/data/repositories/ai_studio_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/ai_generate_handling_mixin.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageEnhancerController extends GetxController with AiGenerateHandlingMixin {
  final AiStudioRepository _repo = AiStudioRepository();
  final UploadRepository _uploadRepo = UploadRepository();

  static const enhancementTypes = ['upscale', 'denoise', 'background_cleanup'];

  @override
  String storeId = '';

  final RxString enhancementType = 'upscale'.obs;
  final Rx<File?> localImage = Rx<File?>(null);
  final RxString uploadedImageUrl = ''.obs;
  final RxBool isUploading = false.obs;

  final Rx<AiImageJobModel?> job = Rx<AiImageJobModel?>(null);
  final RxBool isPolling = false.obs;
  Timer? _pollTimer;

  final RxBool accepted = false.obs;
  final RxBool isAccepting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
  }

  Future<void> pickImage(ImageSource source) async {
    final file = await _uploadRepo.pickImage(source: source);
    if (file == null) return;

    _pollTimer?.cancel();
    localImage.value = file;
    uploadedImageUrl.value = '';
    job.value = null;
    accepted.value = false;

    isUploading.value = true;
    final url = await _uploadRepo.uploadFile(file);
    isUploading.value = false;
    if (url != null) uploadedImageUrl.value = url;
  }

  Future<void> generate() async {
    if (uploadedImageUrl.value.isEmpty) {
      ToastUtil.showToast('Select an image first');
      return;
    }
    _pollTimer?.cancel();

    final start = await runGenerate(() => _repo.startImageEnhance(
          storeId,
          imageUrl: uploadedImageUrl.value,
          enhancementType: enhancementType.value,
        ));
    if (start == null) return;

    job.value = AiImageJobModel(
      jobId: start.jobId,
      status: start.status,
      creditsCharged: start.creditsCharged,
      originalImageUrl: uploadedImageUrl.value,
    );
    accepted.value = false;
    _startPolling(start.jobId);
  }

  void _startPolling(String jobId) {
    isPolling.value = true;
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final result = await _repo.getImageJob(storeId, jobId);
      if (result == null) return;
      job.value = result;
      if (!result.isProcessing) {
        timer.cancel();
        isPolling.value = false;
      }
    });
  }

  Future<void> accept() async {
    final current = job.value;
    if (current == null || isAccepting.value) return;
    isAccepting.value = true;
    final updated = await _repo.acceptGeneration(storeId, current.jobId);
    isAccepting.value = false;
    if (updated != null) {
      accepted.value = true;
      ToastUtil.showToast('Marked as accepted');
    }
  }
}
