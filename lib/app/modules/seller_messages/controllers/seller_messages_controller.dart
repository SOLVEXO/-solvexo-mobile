import 'package:get/get.dart';

// ── Models ─────────────────────────────────────────────────────────────────────

class SellerConversation {
  final String id;
  final String buyerName;
  final String buyerInitials;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool lastFromSeller;

  const SellerConversation({
    required this.id,
    required this.buyerName,
    required this.buyerInitials,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastFromSeller = false,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final String time;
  final String date;
  final bool isSeller;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.date,
    required this.isSeller,
    this.isRead = true,
  });
}

// ── Static mock data ──────────────────────────────────────────────────────────

const List<SellerConversation> kMockConversations = [
  SellerConversation(id: 'c1', buyerName: 'Sarah M.', buyerInitials: 'SM', lastMessage: 'Hi! Does the Math Bundle include answer keys?', lastMessageTime: '2m', unreadCount: 2, isOnline: true),
  SellerConversation(id: 'c2', buyerName: 'David R.', buyerInitials: 'DR', lastMessage: "My order hasn't arrived yet, can you check?", lastMessageTime: '1h', unreadCount: 1),
  SellerConversation(id: 'c3', buyerName: 'Lena K.', buyerInitials: 'LK', lastMessage: 'Thank you so much! Amazing resources 🎉', lastMessageTime: '3h', isOnline: true),
  SellerConversation(id: 'c4', buyerName: 'Omar T.', buyerInitials: 'OT', lastMessage: 'Perfect, I just downloaded it. Really helpful!', lastMessageTime: '5h', lastFromSeller: false),
  SellerConversation(id: 'c5', buyerName: 'Amira L.', buyerInitials: 'AL', lastMessage: 'Is the Science Workbook available for Grade 6?', lastMessageTime: 'Yesterday'),
];

const Map<String, List<ChatMessage>> kMockMessages = {
  'c1': [
    ChatMessage(id: 'm1', text: "Hi! I saw your Math Bundle and I'm very interested.", time: '10:20 AM', date: 'Today', isSeller: false),
    ChatMessage(id: 'm2', text: "Does it include answer keys for all the worksheets?", time: '10:21 AM', date: 'Today', isSeller: false),
    ChatMessage(id: 'm3', text: "Hi Sarah! Yes, the Grade 5 Math Bundle includes complete answer keys for every worksheet and quiz. It covers the full year — fractions, decimals, geometry, and data analysis 📚", time: '10:24 AM', date: 'Today', isSeller: true),
    ChatMessage(id: 'm4', text: "That sounds perfect! Are there also assessments included?", time: '10:26 AM', date: 'Today', isSeller: false),
    ChatMessage(id: 'm5', text: "Absolutely! There are 12 unit quizzes and 4 semester assessments, all with marking guides. Everything you need for a full year of teaching.", time: '10:28 AM', date: 'Today', isSeller: true),
    ChatMessage(id: 'm6', text: "Is it aligned with Common Core?", time: '10:29 AM', date: 'Today', isSeller: false),
    ChatMessage(id: 'm7', text: "Yes, fully Common Core aligned! All standards are clearly labelled on each worksheet. ✅", time: '10:31 AM', date: 'Today', isSeller: true),
    ChatMessage(id: 'm8', text: "Perfect, placing my order now! Thanks so much.", time: '10:33 AM', date: 'Today', isSeller: false),
    ChatMessage(id: 'm9', text: "Happy to help! Enjoy the resources, reach out anytime 🎉", time: '10:34 AM', date: 'Today', isSeller: true),
    ChatMessage(id: 'm10', text: "Hi! Does the Math Bundle include answer keys?", time: '2:31 PM', date: 'Today', isSeller: false, isRead: false),
    ChatMessage(id: 'm11', text: "Also — does it work for homeschooling?", time: '2:32 PM', date: 'Today', isSeller: false, isRead: false),
  ],
  'c2': [
    ChatMessage(id: 'm1', text: "Hi, I ordered the Ceramic Mug Set 3 days ago and it still hasn't shipped.", time: '9:00 AM', date: 'Yesterday', isSeller: false),
    ChatMessage(id: 'm2', text: "Hi David! I'm so sorry for the delay. Let me check your order right now.", time: '9:05 AM', date: 'Yesterday', isSeller: true),
    ChatMessage(id: 'm3', text: "It was dispatched yesterday — you should receive a tracking email shortly. Delivery estimate: 1–2 days.", time: '9:07 AM', date: 'Yesterday', isSeller: true),
    ChatMessage(id: 'm4', text: "Okay thanks. I didn't get an email though.", time: '9:10 AM', date: 'Yesterday', isSeller: false),
    ChatMessage(id: 'm5', text: "I've resent the tracking link to your email. Apologies again!", time: '9:12 AM', date: 'Yesterday', isSeller: true),
    ChatMessage(id: 'm6', text: "My order hasn't arrived yet, can you check?", time: '10:15 AM', date: 'Today', isSeller: false, isRead: false),
  ],
  'c3': [
    ChatMessage(id: 'm1', text: "Just received the Wall Print A3 — it looks absolutely stunning!", time: '3:00 PM', date: 'Today', isSeller: false),
    ChatMessage(id: 'm2', text: "That's wonderful to hear Lena! Thank you for the kind words 😊", time: '3:05 PM', date: 'Today', isSeller: true),
    ChatMessage(id: 'm3', text: "The quality is even better than expected. Definitely ordering more!", time: '3:07 PM', date: 'Today', isSeller: false),
    ChatMessage(id: 'm4', text: "Thank you so much! Amazing resources 🎉", time: '3:08 PM', date: 'Today', isSeller: false),
  ],
  'c4': [
    ChatMessage(id: 'm1', text: "Hi, the download link says the file expired?", time: '11:00 AM', date: 'Today', isSeller: false),
    ChatMessage(id: 'm2', text: "Hi Omar! I've sent a fresh link to your email. Should work now!", time: '11:04 AM', date: 'Today', isSeller: true),
    ChatMessage(id: 'm3', text: "Got it, downloading now. Thanks for the quick response!", time: '11:06 AM', date: 'Today', isSeller: false),
    ChatMessage(id: 'm4', text: "Perfect, I just downloaded it. Really helpful!", time: '11:10 AM', date: 'Today', isSeller: false),
  ],
  'c5': [
    ChatMessage(id: 'm1', text: "Love the Grade 5 workbook! Do you have a Grade 6 Science version?", time: '4:00 PM', date: 'Yesterday', isSeller: false),
    ChatMessage(id: 'm2', text: "Hi Amira! Working on Grade 6 Science right now — available within 2 weeks!", time: '4:10 PM', date: 'Yesterday', isSeller: true),
    ChatMessage(id: 'm3', text: "Is the Science Workbook available for Grade 6?", time: '9:00 AM', date: 'Today', isSeller: false),
  ],
};

// ── Controller ─────────────────────────────────────────────────────────────────

class SellerMessagesController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<SellerConversation> conversations =
      <SellerConversation>[].obs;

  List<SellerConversation> get filteredConversations {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return conversations;
    return conversations
        .where((c) => c.buyerName.toLowerCase().contains(q))
        .toList();
  }

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  List<ChatMessage> messagesFor(String id) => kMockMessages[id] ?? [];

  void onSearch(String value) => searchQuery.value = value;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    conversations.assignAll(kMockConversations);
    isLoading.value = false;
  }

  Future<void> refreshData() async => _load();
}
