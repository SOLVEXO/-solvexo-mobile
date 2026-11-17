import 'dart:async';

import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/core/i18n/locale_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
/// inbox. A guest is first asked for contact details (`source:
/// 'needs_contact'`); the same text is then re-sent with `guest {name, email |
/// phone}` and the reply carries `escalation.guestToken`.
///
/// Team replies: `GET /api/chatbot/conversation?since=&guestToken=` ->
/// `{data: {conversation: null | {id, status, messages: [{id, from, text,
/// at}]}, serverTime}}` (verified against the live API 2026-11-17). Polled
/// every 20 s while this screen is open, for signed-in users and for guests
/// holding a token; `since` is the previous response's `serverTime`, so the
/// device clock never matters.
class SupportChatController extends GetxController {
  SupportChatController({BaseClient? client}) : _client = client ?? BaseClient();

  final BaseClient _client;

  final RxList<ChatEntry> messages = <ChatEntry>[].obs;
  final RxList<ChatChip> chips = <ChatChip>[].obs;
  final RxBool sending = false.obs;
  final RxnString notice = RxnString();
  final RxBool signedIn = false.obs;

  /// The guest's question waiting for name + contact (`needs_contact`).
  final RxnString pendingContactText = RxnString();

  final Set<String> _seenTeamIds = {};
  String? _since;
  String? _guestToken;
  Timer? _poll;

  @visibleForTesting
  set guestToken(String? v) => _guestToken = v;
  @visibleForTesting
  String? get since => _since;

  bool get _canPoll => signedIn.value || _guestToken != null;

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
    if (!signedIn.value) {
      _guestToken = await AppPreferences.getSupportGuestToken();
    }
    _startPolling();
  }

  void _startPolling() {
    if (!_canPoll || _poll != null) return;
    pollTeamReplies();
    _poll = Timer.periodic(const Duration(seconds: 20), (_) => pollTeamReplies());
  }

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || sending.value) return;
    messages.add(ChatEntry(author: ChatAuthor.me, text: text));
    pendingContactText.value = null;
    await _ask(text);
  }

  /// Validates the guest contact form. Returns an error, or null when valid.
  static String? validateContact(String name, String contact) {
    if (name.trim().isEmpty || name.trim().length > 80) {
      return 'Please enter your name.'.tr;
    }
    final c = contact.trim();
    final isEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(c) && c.length <= 200;
    final digits = c.replaceAll(RegExp(r'[\s\-()]'), '');
    final isPhone = RegExp(r'^\+?\d{7,15}$').hasMatch(digits) && digits.length <= 20;
    if (!isEmail && !isPhone) return 'Enter a valid email or phone number.'.tr;
    return null;
  }

  /// Re-sends the pending question with the guest's contact details.
  Future<void> submitContact(String name, String contact) async {
    final text = pendingContactText.value;
    if (text == null || validateContact(name, contact) != null) return;
    final c = contact.trim();
    final guest = <String, String>{
      'name': name.trim(),
      if (c.contains('@')) 'email': c else 'phone': c.replaceAll(RegExp(r'[\s\-()]'), ''),
    };
    pendingContactText.value = null;
    await _ask(text, guest: guest);
  }

  void cancelContact() => pendingContactText.value = null;

  Future<void> _ask(String text, {Map<String, String>? guest}) async {
    chips.clear();
    sending.value = true;
    try {
      final res = await _client.post(
        ApiConstants.chatbotMessage,
        data: {
          'audience': 'buyer',
          'text': text,
          'lang': LocaleService.current.languageCode,
          if (guest != null) 'guest': guest,
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

        if (data['source'] == 'needs_contact' && !signedIn.value) {
          pendingContactText.value = text;
        }
        final esc = data['escalation'];
        final token = esc is Map ? esc['guestToken']?.toString() : null;
        if (token != null && token.isNotEmpty && !signedIn.value) {
          _guestToken = token;
          await AppPreferences.saveSupportGuestToken(token);
        }
        if (data['source'] == 'escalated') _startPolling();
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

  /// Team replies to an escalated question (signed in, or guest with token).
  Future<void> pollTeamReplies() async {
    try {
      final res = await _client.get(
        ApiConstants.chatbotConversation,
        queryParameters: {
          if (_since != null) 'since': _since,
          if (!signedIn.value && _guestToken != null) 'guestToken': _guestToken,
        },
        requiresAuth: signedIn.value,
      );
      final body = res.data;
      dynamic data = body is Map ? body['data'] : null;
      final serverTime = data is Map ? data['serverTime']?.toString() : null;
      if (data is Map && data.containsKey('conversation')) {
        data = data['conversation'];
      }
      if (data is Map) data = data['messages'];
      if (data is List) {
        for (final m in data) {
          if (m is! Map) continue;
          final from = (m['from'] ?? m['sender'] ?? m['role'])?.toString();
          if (from != 'admin' && from != 'team' && from != 'support') continue;
          final id = (m['_id'] ?? m['id'])?.toString();
          if (id != null && !_seenTeamIds.add(id)) continue;
          final text = (m['text'] ?? m['body'] ?? m['message'])?.toString();
          if (text == null || text.isEmpty) continue;
          final at = DateTime.tryParse(
                  (m['at'] ?? m['createdAt'])?.toString() ?? '')
              ?.toLocal();
          messages.add(ChatEntry(author: ChatAuthor.team, text: text, at: at, id: id));
        }
      }
      // Advance only after a successful read, using the server's clock.
      if (serverTime != null && serverTime.isNotEmpty) _since = serverTime;
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
