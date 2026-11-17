import 'dart:async';

import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/core/i18n/locale_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

enum ChatAuthor { me, bot, team }

class ChatEntry {
  ChatEntry({
    required this.author,
    required this.text,
    DateTime? at,
    this.id,
  }) : at = at ?? DateTime.now();

  final ChatAuthor author;
  final String text;
  final DateTime at;
  final String? id;
}

class ChatChip {
  const ChatChip(this.label, {this.link});
  final String label;

  /// Web path from an action (`{label, to}`); null for a quick reply.
  final String? link;
}

/// Edudeen Help (docs §5.15) on the backend chatbot — no AI key on the device.
///
/// `POST /api/chatbot/message {audience:'buyer', text, lang}` answers greetings
/// and FAQs; text it cannot answer is escalated by the server to the admin
/// inbox. Team replies are read with `GET /api/chatbot/conversation?since=`
/// (signed-in buyers; polled every 20 s while this screen is open) and also
/// arrive as a `support_reply` notification.
class SupportChatController extends GetxController {
  SupportChatController({BaseClient? client}) : _client = client ?? BaseClient();

  final BaseClient _client;

  final RxList<ChatEntry> messages = <ChatEntry>[].obs;
  final RxList<ChatChip> chips = <ChatChip>[].obs;
  final RxBool sending = false.obs;
  final RxnString notice = RxnString();
  final RxBool signedIn = false.obs;

  final Set<String> _seenTeamIds = {};
  DateTime? _since;
  Timer? _poll;

  @override
  void onInit() {
    super.onInit();
    messages.add(ChatEntry(
      author: ChatAuthor.bot,
      text: 'Hi! How can we help you today?'.tr,
    ));
    _start();
  }

  Future<void> _start() async {
    signedIn.value = await AppPreferences.isLoggedIn();
    if (signedIn.value) {
      await pollTeamReplies();
      _poll = Timer.periodic(
          const Duration(seconds: 20), (_) => pollTeamReplies());
    }
  }

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || sending.value) return;
    messages.add(ChatEntry(author: ChatAuthor.me, text: text));
    chips.clear();
    sending.value = true;
    try {
      final res = await _client.post(
        ApiConstants.chatbotMessage,
        data: {
          'audience': 'buyer',
          'text': text,
          'lang': LocaleService.current.languageCode,
        },
        requiresAuth: signedIn.value,
      );
      final body = res.data;
      final data = body is Map ? body['data'] : null;
      if (data is Map) {
        final reply = data['reply']?.toString();
        if (reply != null && reply.isNotEmpty) {
          messages.add(ChatEntry(author: ChatAuthor.bot, text: reply));
        }
        final next = <ChatChip>[];
        final quick = data['quickReplies'];
        if (quick is List) {
          for (final q in quick) {
            final label = q is Map ? q['label']?.toString() : q?.toString();
            if (label != null && label.isNotEmpty) next.add(ChatChip(label));
          }
        }
        final actions = data['actions'];
        if (actions is List) {
          for (final a in actions) {
            if (a is Map && a['label'] != null && a['to'] != null) {
              next.add(ChatChip(a['label'].toString(), link: a['to'].toString()));
            }
          }
        }
        chips.assignAll(next);
        final n = data['notice']?.toString();
        if (n != null && n.isNotEmpty) notice.value = n;
      }
    } on DioException catch (e) {
      messages.add(ChatEntry(
        author: ChatAuthor.bot,
        text: ApiError.fromBody(e.response?.data) ??
            'Something went wrong. Please try again.'.tr,
      ));
    } finally {
      sending.value = false;
    }
  }

  /// Team replies to an escalated question. The body shape was not verified
  /// from this environment; both a list and `{messages: [...]}` are read.
  Future<void> pollTeamReplies() async {
    try {
      final res = await _client.get(
        ApiConstants.chatbotConversation,
        queryParameters: {
          if (_since != null) 'since': _since!.toUtc().toIso8601String(),
        },
        requiresAuth: true,
      );
      final body = res.data;
      dynamic data = body is Map ? body['data'] : null;
      if (data is Map) data = data['messages'];
      if (data is! List) return;
      for (final m in data) {
        if (m is! Map) continue;
        final from = (m['from'] ?? m['sender'] ?? m['role'])?.toString();
        if (from != 'admin' && from != 'team' && from != 'support') continue;
        final id = (m['_id'] ?? m['id'])?.toString();
        if (id != null && !_seenTeamIds.add(id)) continue;
        final text = (m['text'] ?? m['body'] ?? m['message'])?.toString();
        if (text == null || text.isEmpty) continue;
        final at = DateTime.tryParse(m['createdAt']?.toString() ?? '')?.toLocal();
        messages.add(ChatEntry(author: ChatAuthor.team, text: text, at: at, id: id));
        if (at != null && (_since == null || at.isAfter(_since!))) _since = at;
      }
    } catch (_) {
      // Quiet: polling never interrupts the chat.
    }
  }

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }
}
