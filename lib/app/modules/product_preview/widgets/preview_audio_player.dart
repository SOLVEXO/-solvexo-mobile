import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/product_preview/controller/product_preview_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Simple play/pause + progress row for a short, trimmed audio-preview clip.
class PreviewAudioPlayer extends StatelessWidget {
  final ProductPreviewController controller;
  final String url;

  const PreviewAudioPlayer({super.key, required this.controller, required this.url});

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: BaseSpacing.md,
          children: [
            Icon(Icons.audiotrack_rounded, size: 64, color: AppColors.primaryColor),
            Obx(
              () => IconButton(
                iconSize: 56,
                color: AppColors.primaryColor,
                icon: Icon(
                  controller.isAudioPlaying.value
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                ),
                onPressed: () => controller.toggleAudio(url),
              ),
            ),
            Obx(() {
              final duration = controller.audioDuration.value;
              final position = controller.audioPosition.value;
              return Column(
                spacing: BaseSpacing.xxs,
                children: [
                  SizedBox(
                    width: 220,
                    child: LinearProgressIndicator(
                      value: duration.inMilliseconds == 0
                          ? 0
                          : position.inMilliseconds / duration.inMilliseconds,
                      color: AppColors.primaryColor,
                      backgroundColor: AppColors.white2,
                    ),
                  ),
                  CustomText(
                    text: '${_format(position)} / ${_format(duration)} — preview only',
                    color: AppColors.gray600,
                    fontSize: AppFontSize.tiny,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
