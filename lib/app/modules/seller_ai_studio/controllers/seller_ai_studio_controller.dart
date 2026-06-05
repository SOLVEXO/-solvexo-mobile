import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Enums ──────────────────────────────────────────────────────────────────────

enum AiTool {
  listingWriter,
  priceOptimizer,
  worksheetBuilder,
  seoBooster,
  emailCampaigns,
  imageEnhancer,
}

enum WritingTone { professional, friendly, academic }

enum WorksheetType { practice, assessment, review }

enum CampaignType { promotional, welcome, reEngagement }

enum ImageEnhancement { autoEnhance, bgRemove, brightness, sharpen }

// ── Tool metadata ──────────────────────────────────────────────────────────────

class AiToolData {
  final AiTool tool;
  final String emoji;
  final String name;
  final String description;
  final int creditCost;

  const AiToolData({
    required this.tool,
    required this.emoji,
    required this.name,
    required this.description,
    required this.creditCost,
  });
}

const kAiTools = [
  AiToolData(
    tool: AiTool.listingWriter,
    emoji: AppIcons.faqIcon,
    name: 'Listing Writer',
    description: 'AI-generated product titles and descriptions',
    creditCost: 5,
  ),
  AiToolData(
    tool: AiTool.priceOptimizer,
    emoji: AppIcons.cashIcon,
    name: 'Price Optimizer',
    description: 'Smart pricing based on market data',
    creditCost: 3,
  ),
  AiToolData(
    tool: AiTool.worksheetBuilder,
    emoji: AppIcons.billsIcon,
    name: 'Worksheet Builder',
    description: 'Generate educational worksheets instantly',
    creditCost: 10,
  ),
  AiToolData(
    tool: AiTool.seoBooster,
    emoji: AppIcons.searchIcon,
    name: 'SEO Booster',
    description: 'Optimize tags, titles & search ranking',
    creditCost: 5,
  ),
  AiToolData(
    tool: AiTool.emailCampaigns,
    emoji: AppIcons.emailIcon,
    name: 'Email Campaigns',
    description: 'Write buyer emails and newsletters',
    creditCost: 5,
  ),
  AiToolData(
    tool: AiTool.imageEnhancer,
    emoji: AppIcons.aiBeautyIcon,
    name: 'Image Enhancer',
    description: 'Improve product photo quality with AI',
    creditCost: 8,
  ),
];

const int kMonthlyCredits = 1000;

// ── Output model ──────────────────────────────────────────────────────────────

class AiOutput {
  final String title;
  final String body;
  final List<String> tags;
  final String? secondaryLabel;
  final String? secondaryValue;

  const AiOutput({
    required this.title,
    required this.body,
    this.tags = const [],
    this.secondaryLabel,
    this.secondaryValue,
  });
}

// ── Mock outputs ──────────────────────────────────────────────────────────────

const Map<AiTool, AiOutput> kMockOutputs = {
  AiTool.listingWriter: AiOutput(
    title:
        'Grade 5 Math Mastery Bundle — Complete Full-Year Curriculum with Worksheets, Assessments & Answer Keys | Common Core Aligned',
    body:
        'Transform your Grade 5 classroom with this comprehensive, ready-to-use math curriculum designed to take students from foundational concepts to grade-level mastery. This all-in-one bundle covers 36 weeks of instruction across fractions, decimals, geometry, measurement, and data analysis.',
    tags: [
      'grade 5 math',
      'common core',
      'full year curriculum',
      'fractions worksheets',
      'math assessment',
      '5th grade',
      'printable',
      'differentiated',
    ],
  ),
  AiTool.priceOptimizer: AiOutput(
    title: 'Recommended Price: \$47.00',
    body:
        'Based on analysis of 1,240 similar listings, \$47 places you in the top 25% of your category while remaining competitive. Comparable Educational Resource bundles range from \$35–\$65. A price of \$47 maximises conversion while protecting your perceived value.',
    tags: ['competitive', 'high-value', 'top 25%'],
    secondaryLabel: 'Market Position',
    secondaryValue: 'Premium tier — above 75% of similar listings',
  ),
  AiTool.worksheetBuilder: AiOutput(
    title: 'Fractions & Decimals Practice Pack — Grade 5',
    body:
        'A 12-page printable worksheet pack covering: (1) Converting fractions to decimals, (2) Comparing and ordering decimals, (3) Adding & subtracting fractions with unlike denominators, (4) Mixed number operations, (5) Real-world word problems. Includes answer key.',
    tags: [
      'fractions',
      'decimals',
      'grade 5',
      'printable',
      'common core',
      'answer key',
    ],
    secondaryLabel: 'Estimated Completion Time',
    secondaryValue: '45–60 minutes',
  ),
  AiTool.seoBooster: AiOutput(
    title:
        'Grade 5 Math Bundle | Full-Year Curriculum Worksheets, Assessments & Lesson Plans — Common Core Aligned | 5th Grade Teachers',
    body:
        'Meta description: Shop the ultimate Grade 5 math resource bundle — 36 weeks of printable worksheets, assessments, and lesson plans. Common Core aligned. Trusted by 2,000+ teachers. Instant digital download.',
    tags: [
      'grade 5 math bundle',
      'common core worksheets',
      '5th grade curriculum',
      'printable math activities',
      'math assessment bundle',
      'teacher resources',
    ],
    secondaryLabel: 'Estimated SEO Improvement',
    secondaryValue: '+34% more search visibility',
  ),
  AiTool.emailCampaigns: AiOutput(
    title: 'Subject: Your students are about to love math 📐',
    body:
        'Hi [First Name],\n\nWe know finding high-quality, curriculum-aligned resources takes hours. That\'s why we built the Grade 5 Math Mastery Bundle — everything you need for a full year, ready to print.\n\n✅ 36 weeks of structured lessons\n✅ Common Core aligned\n✅ Answer keys included\n\nThis week only: 20% off with code MATH20.\n\n[Shop Now →]',
    tags: ['promotional', 'math', 'discount', 'educators'],
    secondaryLabel: 'Estimated Open Rate',
    secondaryValue: '24–31% (above category average)',
  ),
  AiTool.imageEnhancer: AiOutput(
    title: 'Image Enhancement Complete',
    body:
        'Your product image has been enhanced with AI: brightness and contrast adjusted, background cleaned, sharpness improved, and colours balanced. The enhanced image is optimised for marketplace listing thumbnails (1000×1000px).',
    tags: ['enhanced', 'optimised', 'marketplace-ready'],
    secondaryLabel: 'Quality Score',
    secondaryValue: '94/100 — Excellent',
  ),
};

// ── Controller ─────────────────────────────────────────────────────────────────

class SellerAiStudioController extends GetxController {
  final Rx<AiTool> selectedTool = AiTool.listingWriter.obs;
  final RxInt credits = 750.obs;
  final RxBool isGenerating = false.obs;
  final Rx<AiOutput?> output = Rx(null);

  // ── Listing Writer inputs
  final RxString lwProductType = 'Educational Resource'.obs;
  final RxString lwKeywords = ''.obs;
  final Rx<WritingTone> lwTone = WritingTone.professional.obs;

  // ── Price Optimizer inputs
  final RxString poProductName = ''.obs;
  final RxString poCurrentPrice = ''.obs;
  final RxString poCategory = 'Education & Learning'.obs;

  // ── Worksheet Builder inputs
  final RxString wbSubject = 'Math'.obs;
  final RxString wbGrade = 'Grade 4–5'.obs;
  final RxString wbTopic = ''.obs;
  final Rx<WorksheetType> wbType = WorksheetType.practice.obs;

  // ── SEO Booster inputs
  final RxString seoTitle = ''.obs;
  final RxString seoCategory = 'Education & Learning'.obs;
  final RxString seoKeywords = ''.obs;

  // ── Email Campaigns inputs
  final Rx<CampaignType> ecType = CampaignType.promotional.obs;
  final RxString ecAudience = ''.obs;
  final RxString ecMessage = ''.obs;

  // ── Image Enhancer inputs
  final Rx<ImageEnhancement> ieType = ImageEnhancement.autoEnhance.obs;
  final RxBool ieHasImage = false.obs;

  // TextEditingControllers
  late final TextEditingController lwKeywordsCtrl;
  late final TextEditingController poProductNameCtrl;
  late final TextEditingController poCurrentPriceCtrl;
  late final TextEditingController wbTopicCtrl;
  late final TextEditingController seoTitleCtrl;
  late final TextEditingController seoKeywordsCtrl;
  late final TextEditingController ecAudienceCtrl;
  late final TextEditingController ecMessageCtrl;

  // ── Computed ─────────────────────────────────────────────────────────────────

  AiToolData get currentToolData =>
      kAiTools.firstWhere((t) => t.tool == selectedTool.value);

  double get creditsProgress => credits.value / kMonthlyCredits;

  bool get canGenerate {
    if (credits.value < currentToolData.creditCost) return false;
    switch (selectedTool.value) {
      case AiTool.listingWriter:
        return lwKeywords.value.trim().isNotEmpty;
      case AiTool.priceOptimizer:
        return poProductName.value.trim().isNotEmpty;
      case AiTool.worksheetBuilder:
        return wbTopic.value.trim().isNotEmpty;
      case AiTool.seoBooster:
        return seoTitle.value.trim().isNotEmpty;
      case AiTool.emailCampaigns:
        return ecMessage.value.trim().isNotEmpty;
      case AiTool.imageEnhancer:
        return ieHasImage.value;
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  void selectTool(AiTool tool) {
    if (selectedTool.value == tool) return;
    selectedTool.value = tool;
    output.value = null;
  }

  Future<void> generate() async {
    if (!canGenerate || isGenerating.value) return;
    isGenerating.value = true;
    output.value = null;
    await Future.delayed(const Duration(milliseconds: 1800));
    credits.value -= currentToolData.creditCost;
    output.value = kMockOutputs[selectedTool.value];
    isGenerating.value = false;
  }

  void regenerate() {
    output.value = null;
    generate();
  }

  void useOutput() {
    Get.snackbar(
      '',
      'Output copied — ready to use in your listing!',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void pickImage() => ieHasImage.value = true;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    lwKeywordsCtrl = TextEditingController();
    poProductNameCtrl = TextEditingController();
    poCurrentPriceCtrl = TextEditingController();
    wbTopicCtrl = TextEditingController();
    seoTitleCtrl = TextEditingController();
    seoKeywordsCtrl = TextEditingController();
    ecAudienceCtrl = TextEditingController();
    ecMessageCtrl = TextEditingController();
  }

  @override
  void onClose() {
    lwKeywordsCtrl.dispose();
    poProductNameCtrl.dispose();
    poCurrentPriceCtrl.dispose();
    wbTopicCtrl.dispose();
    seoTitleCtrl.dispose();
    seoKeywordsCtrl.dispose();
    ecAudienceCtrl.dispose();
    ecMessageCtrl.dispose();
    super.onClose();
  }
}
