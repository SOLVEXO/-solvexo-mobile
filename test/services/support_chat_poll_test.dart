import 'package:book_store_app/app/modules/support_chat/controllers/support_chat_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClient extends BaseClient {
  _FakeClient(this.body);
  final Object? body;

  @override
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool requiresAuth = false,
    ResponseType? responseType,
  }) async =>
      Response(
        requestOptions: RequestOptions(path: url),
        statusCode: 200,
        data: body,
      );
}

Future<List<ChatEntry>> _poll(Object? body) async {
  // Constructed directly (not via Get.put) so onInit/polling never start.
  final c = SupportChatController(client: _FakeClient(body));
  await c.pollTeamReplies();
  return c.messages.toList();
}

void main() {
  test('live body with no conversation adds nothing', () async {
    // Real response of GET /api/chatbot/conversation, 2026-11-17.
    final out = await _poll({
      'success': true,
      'data': {'conversation': null, 'serverTime': '2026-11-17T07:15:33.879Z'},
    });
    expect(out, isEmpty);
  });

  test('team replies inside data.conversation.messages are read', () async {
    final out = await _poll({
      'success': true,
      'data': {
        'conversation': {
          '_id': 'c1',
          'messages': [
            {'_id': 'm1', 'from': 'user', 'text': 'Where is my file?'},
            {
              '_id': 'm2',
              'from': 'admin',
              'text': 'It is in your Library now.',
              'createdAt': '2026-11-17T07:20:00.000Z',
            },
          ],
        },
        'serverTime': '2026-11-17T07:21:00.000Z',
      },
    });
    expect(out, hasLength(1));
    expect(out.single.author, ChatAuthor.team);
    expect(out.single.text, 'It is in your Library now.');
  });

  test('older flat data.messages shape still works', () async {
    final out = await _poll({
      'data': {
        'messages': [
          {'id': 'x', 'sender': 'support', 'body': 'Hi'},
        ],
      },
    });
    expect(out.single.text, 'Hi');
  });
}
