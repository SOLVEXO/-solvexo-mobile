import 'package:book_store_app/app/modules/support_chat/controllers/support_chat_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClient extends BaseClient {
  _FakeClient({this.getBody, List<Object?>? postBodies})
      : _postBodies = postBodies ?? [];
  final Object? getBody;
  final List<Object?> _postBodies;
  final List<Map<String, dynamic>?> getQueries = [];
  final List<dynamic> postData = [];

  @override
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool requiresAuth = false,
    ResponseType? responseType,
  }) async {
    getQueries.add(queryParameters);
    return Response(
        requestOptions: RequestOptions(path: url), statusCode: 200, data: getBody);
  }

  @override
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    Map<String, dynamic>? headers,
  }) async {
    postData.add(data);
    return Response(
        requestOptions: RequestOptions(path: url),
        statusCode: 200,
        data: _postBodies.removeAt(0));
  }
}

// Real response of GET /api/chatbot/conversation?guestToken= (2026-11-17),
// plus one team reply added for the test.
Map<String, dynamic> _liveConversation({bool withTeamReply = true}) => {
      'success': true,
      'data': {
        'conversation': {
          'id': '6afc0d190dc07bc52c576948',
          'shortCode': 'RFQC',
          'status': 'open',
          'unreadForUser': 0,
          'lastMessageAt': '2026-11-17T08:15:21.204Z',
          'messages': [
            {
              'id': '885692f0b245',
              'from': 'user',
              'text': 'TEST from Edudeen mobile app developer - please ignore.',
              'at': '2026-11-17T08:15:20.915Z',
            },
            if (withTeamReply)
              {
                'id': 'a1',
                'from': 'admin',
                'text': 'It is in your Library now.',
                'at': '2026-11-17T08:20:00.000Z',
              },
          ],
        },
        'serverTime': '2026-11-17T08:15:39.823Z',
      },
    };

void main() {
  test('live body with no conversation adds nothing but keeps serverTime', () async {
    final client = _FakeClient(getBody: {
      'success': true,
      'data': {'conversation': null, 'serverTime': '2026-11-17T07:15:33.879Z'},
    });
    final c = SupportChatController(client: client);
    await c.pollTeamReplies();
    expect(c.messages, isEmpty);
    expect(c.since, '2026-11-17T07:15:33.879Z');
  });

  test('team replies are read from conversation.messages with `at`', () async {
    final c = SupportChatController(client: _FakeClient(getBody: _liveConversation()));
    await c.pollTeamReplies();
    expect(c.messages, hasLength(1), reason: "the user's own message is skipped");
    expect(c.messages.single.author, ChatAuthor.team);
    expect(c.messages.single.at, DateTime.parse('2026-11-17T08:20:00.000Z').toLocal());
  });

  test('next poll sends the server time as since, not the device clock', () async {
    final client = _FakeClient(getBody: _liveConversation());
    final c = SupportChatController(client: client);
    await c.pollTeamReplies();
    await c.pollTeamReplies();
    expect(client.getQueries.first?['since'], isNull);
    expect(client.getQueries.last?['since'], '2026-11-17T08:15:39.823Z');
    expect(c.messages, hasLength(1), reason: 'same reply is not added twice');
  });

  test('guest polls with guestToken in the query', () async {
    final client = _FakeClient(getBody: _liveConversation(withTeamReply: false));
    final c = SupportChatController(client: client)..guestToken = 'tok';
    await c.pollTeamReplies();
    expect(client.getQueries.single?['guestToken'], 'tok');
  });

  test('needs_contact -> contact form -> re-sent with guest, token kept', () async {
    final client = _FakeClient(
      getBody: _liveConversation(withTeamReply: false),
      postBodies: [
        // Real guest responses of POST /api/chatbot/message (2026-11-17).
        {
          'success': true,
          'data': {
            'reply': 'So we can reply to you, please share your name and an email or phone number.',
            'quickReplies': [],
            'actions': [],
            'source': 'needs_contact',
          },
        },
        {
          'success': true,
          'data': {
            'reply': 'Thank you! Your question has been sent to the Edudeen team.',
            'source': 'escalated',
            'conversationId': '6afc0d190dc07bc52c576948',
            'escalation': {
              'conversationId': '6afc0d190dc07bc52c576948',
              'status': 'open',
              'guestToken': 'tok-123',
            },
          },
        },
      ],
    );
    final c = SupportChatController(client: client);
    await c.send('Where is my file?');
    expect(c.pendingContactText.value, 'Where is my file?');

    await c.submitContact('Ali', 'ali@example.com');
    final sent = client.postData.last as Map;
    expect(sent['text'], 'Where is my file?');
    expect(sent['guest'], {'name': 'Ali', 'email': 'ali@example.com'});
    expect(c.pendingContactText.value, isNull);
    // Escalation starts polling with the new token.
    await Future<void>.delayed(Duration.zero);
    expect(client.getQueries.last?['guestToken'], 'tok-123');
    c.onClose();
  });

  test('contact validation', () {
    expect(SupportChatController.validateContact('', 'a@b.co'), isNotNull);
    expect(SupportChatController.validateContact('Ali', 'nope'), isNotNull);
    expect(SupportChatController.validateContact('Ali', 'a@b.co'), isNull);
    expect(SupportChatController.validateContact('Ali', '+92 300 1234567'), isNull);
  });

  test('older flat data.messages shape still works', () async {
    final c = SupportChatController(client: _FakeClient(getBody: {
      'data': {
        'messages': [
          {'id': 'x', 'sender': 'support', 'body': 'Hi'},
        ],
      },
    }));
    await c.pollTeamReplies();
    expect(c.messages.single.text, 'Hi');
  });
}
