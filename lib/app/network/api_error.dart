import 'package:dio/dio.dart';

/// Reads the `message` of an API error body.
///
/// Nest's global `ValidationPipe` returns `message` as either a string or a
/// list of strings, so every consumer must go through [msg] instead of casting
/// `data['message'] as String?` (which throws on a list).
class ApiError {
  ApiError._();

  /// Normalises a raw `message` value (String, List, or null) to a readable
  /// string. Returns null when there is nothing useful to show.
  static String? msg(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) {
      final parts = raw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
      return parts.isEmpty ? null : parts.join('\n');
    }
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// `message` of a decoded response body (`{success, message}`), or null.
  static String? fromBody(dynamic body) =>
      body is Map ? msg(body['message']) : null;

  /// `message` of a [DioException]'s response body, or null.
  static String? fromDio(DioException e) => fromBody(e.response?.data);
}
