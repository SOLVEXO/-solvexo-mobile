import 'package:get/get.dart';
import '../models/faq_model.dart';

class HelpCenterController extends GetxController {
  /// Search
  RxString searchQuery = ''.obs;

  /// FAQ List
  RxList<FAQModel> faqs = <FAQModel>[].obs;

  /// Suggestions
  RxList<FAQModel> filteredFaqs = <FAQModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFaqs();
    debounce(
      searchQuery,
      (_) => _filterFaqs(),
      time: const Duration(milliseconds: 300),
    );
  }

  void _loadFaqs() {
    faqs.assignAll([
      FAQModel(
        id: "1",
        question: "How can I track the package that returned?",
        answer:
            "You can track returned packages via the Track Order section using your order number.",
        category: "Order",
      ),
      FAQModel(
        id: "2",
        question: "What is the return policy and how do I initiate a return?",
        answer:
            "Returns can be initiated from My Orders within 7 days of delivery.",
        category: "Refund",
      ),
      FAQModel(
        id: "3",
        question: "How do I recover my account?",
        answer:
            "Go to Login → Forgot Password and follow the verification steps.",
        category: "Account",
      ),
      FAQModel(
        id: "4",
        question: "How can I delete my account?",
        answer:
            "Please contact customer support to permanently delete your account.",
        category: "Account",
      ),
      FAQModel(
        id: "5",
        question: "What can I do if my account has been hacked?",
        answer: "Immediately reset your password and contact support.",
        category: "Account",
      ),
      FAQModel(
        id: "6",
        question: "What should I do if I received a damaged item?",
        answer: "You can request a refund or replacement from Order Details.",
        category: "Order",
      ),
    ]);

    filteredFaqs.assignAll(faqs);
  }

  void _filterFaqs() {
    if (searchQuery.value.isEmpty) {
      filteredFaqs.assignAll(faqs);
    } else {
      filteredFaqs.assignAll(
        faqs.where(
          (f) => f.question.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        ),
      );
    }
  }
}
