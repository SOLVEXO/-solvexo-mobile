import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_ai_studio/controllers/seller_ai_studio_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiOutputPanel extends StatelessWidget {
  final SellerAiStudioController controller;

  const AiOutputPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final out = controller.output.value;
      final isGenerating = controller.isGenerating.value;

      if (isGenerating) return _GeneratingPlaceholder();
      if (out == null) return const SizedBox.shrink();

      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OutputHeader(),
              const Divider(height: 1, color: AppColors.lightGrey2),
              Padding(
                padding: const EdgeInsets.all(AppDimen.allPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OutputSection(
                      label: _titleLabel(controller.selectedTool.value),
                      content: out.title,
                      isBold: true,
                    ),
                    const SizedBox(height: 14),
                    _OutputSection(
                      label: _bodyLabel(controller.selectedTool.value),
                      content: out.body,
                    ),
                    if (out.secondaryLabel != null && out.secondaryValue != null) ...[
                      const SizedBox(height: 14),
                      _SecondaryValueCard(
                        label: out.secondaryLabel!,
                        value: out.secondaryValue!,
                      ),
                    ],
                    if (out.tags.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _TagsSection(tags: out.tags),
                    ],
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.lightGrey2),
                    const SizedBox(height: 14),
                    _ActionButtons(controller: controller),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static String _titleLabel(AiTool tool) {
    switch (tool) {
      case AiTool.listingWriter: return 'GENERATED TITLE';
      case AiTool.priceOptimizer: return 'RECOMMENDED PRICE';
      case AiTool.worksheetBuilder: return 'WORKSHEET TITLE';
      case AiTool.seoBooster: return 'OPTIMISED TITLE';
      case AiTool.emailCampaigns: return 'SUBJECT LINE';
      case AiTool.imageEnhancer: return 'ENHANCEMENT RESULT';
    }
  }

  static String _bodyLabel(AiTool tool) {
    switch (tool) {
      case AiTool.listingWriter: return 'GENERATED DESCRIPTION';
      case AiTool.priceOptimizer: return 'MARKET ANALYSIS';
      case AiTool.worksheetBuilder: return 'WORKSHEET OUTLINE';
      case AiTool.seoBooster: return 'META DESCRIPTION';
      case AiTool.emailCampaigns: return 'EMAIL BODY';
      case AiTool.imageEnhancer: return 'SUMMARY';
    }
  }
}

// ── Output header ─────────────────────────────────────────────────────────────

class _OutputHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimen.allPadding, 14, AppDimen.allPadding, 14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.greenSuccess,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const CustomText(
            text: 'AI Output — Preview',
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ],
      ),
    );
  }
}

// ── Output section ────────────────────────────────────────────────────────────

class _OutputSection extends StatelessWidget {
  final String label;
  final String content;
  final bool isBold;

  const _OutputSection({
    required this.label,
    required this.content,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w700,
          color: AppColors.grey,
          letterSpacing: 0.6,
        ),
        const SizedBox(height: 6),
        CustomText(
          text: content,
          fontSize: isBold ? AppFontSize.small2 : AppFontSize.verySmall,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          color: AppColors.black,
        ),
      ],
    );
  }
}

// ── Secondary value card ──────────────────────────────────────────────────────

class _SecondaryValueCard extends StatelessWidget {
  final String label;
  final String value;

  const _SecondaryValueCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.greenContainerInnerColor,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        border: Border.all(color: AppColors.darkGreen.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.darkGreen),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tags section ──────────────────────────────────────────────────────────────

class _TagsSection extends StatelessWidget {
  final List<String> tags;
  const _TagsSection({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'SUGGESTED TAGS',
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w700,
          color: AppColors.grey,
          letterSpacing: 0.6,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => _TagChip(tag: tag)).toList(),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimen.draggableBorderRadius),
        border: Border.all(color: AppColors.lightGrey2),
      ),
      child: CustomText(
        text: tag,
        fontSize: AppFontSize.tiny,
        color: AppColors.black2,
      ),
    );
  }
}

// ── Action buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final SellerAiStudioController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: controller.useOutput,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
              ),
              alignment: Alignment.center,
              child: const CustomText(
                text: 'Use This',
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: controller.regenerate,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
                border: Border.all(color: AppColors.lightGrey2),
              ),
              alignment: Alignment.center,
              child: const CustomText(
                text: 'Regenerate',
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w600,
                color: AppColors.black2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
                border: Border.all(color: AppColors.lightGrey2),
              ),
              alignment: Alignment.center,
              child: const CustomText(
                text: 'Edit',
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.black2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Generating placeholder ────────────────────────────────────────────────────

class _GeneratingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'AI is generating your content...',
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                SizedBox(height: 3),
                CustomText(
                  text: 'This usually takes a few seconds.',
                  fontSize: AppFontSize.tiny,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
