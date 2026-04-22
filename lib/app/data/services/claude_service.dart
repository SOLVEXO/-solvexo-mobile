// lib/app/data/services/ai_chat_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClaudeService {
  static const _model = 'gemini-2.0-flash';
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _apiUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$_model:streamGenerateContent?alt=sse&key=$_apiKey';

  Stream<String> streamChat({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async* {
    if (_apiKey.isEmpty) {
      debugPrint('❌ GEMINI_API_KEY missing from .env');
      return;
    }

    final streamController = StreamController<String>();

    // ✅ Convert your existing message format to Gemini format
    final geminiMessages = messages
        .map(
          (m) => {
            'role': m['role'] == 'assistant'
                ? 'model'
                : 'user', // Gemini uses 'model' not 'assistant'
            'parts': [
              {'text': m['content']},
            ],
          },
        )
        .toList();

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        responseType: ResponseType.stream,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio
        .post(
          _apiUrl,
          data: {
            'system_instruction': {
              'parts': [
                {'text': systemPrompt},
              ], // system prompt
            },
            'contents': geminiMessages,
            'generationConfig': {'maxOutputTokens': 1024, 'temperature': 0.7},
          },
        )
        .then((response) async {
          final body = response.data as ResponseBody;
          final lineBuffer = StringBuffer();

          await for (final chunk in body.stream) {
            final decoded = utf8.decode(chunk, allowMalformed: true);
            lineBuffer.write(decoded);

            final lines = lineBuffer.toString().split('\n');
            lineBuffer.clear();
            lineBuffer.write(lines.last);

            for (final line in lines.sublist(0, lines.length - 1)) {
              final trimmed = line.trim();
              if (!trimmed.startsWith('data: ')) continue;

              final data = trimmed.substring(6).trim();
              if (data == '[DONE]') {
                streamController.close();
                return;
              }

              try {
                final json = jsonDecode(data) as Map<String, dynamic>;
                // ✅ Gemini response structure
                final candidates = json['candidates'] as List?;
                if (candidates != null && candidates.isNotEmpty) {
                  final parts = candidates[0]['content']?['parts'] as List?;
                  if (parts != null && parts.isNotEmpty) {
                    final text = parts[0]['text'] as String?;
                    if (text != null && text.isNotEmpty) {
                      streamController.add(text);
                    }
                  }
                }
              } catch (_) {}
            }
          }

          streamController.close();
        })
        .catchError((e) async {
          if (e is DioException && e.response?.data is ResponseBody) {
            try {
              final body = e.response!.data as ResponseBody;
              final bytes = <int>[];
              await for (final chunk in body.stream) bytes.addAll(chunk);
              final errorText = utf8.decode(bytes);
              debugPrint('❌ Gemini error: $errorText');
            } catch (_) {}
          } else {
            debugPrint('❌ Error: $e');
          }
          streamController.addError(e);
          streamController.close();
        });

    yield* streamController.stream;
  }
}
