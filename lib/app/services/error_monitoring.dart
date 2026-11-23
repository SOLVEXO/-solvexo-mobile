import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

/// Optional crash/error reporting (R5). Off unless the build passes
/// `--dart-define=SENTRY_DSN=https://...` (empty = no SDK start, no network).
/// No personal data: no user, no request bodies, no print/UI breadcrumbs, and
/// every text that leaves the device is scrubbed of emails, phone numbers,
/// tokens and query strings.
class ErrorMonitoring {
  ErrorMonitoring._();

  static const String dsn = String.fromEnvironment('SENTRY_DSN');
  static const String environment = String.fromEnvironment('APP_ENV', defaultValue: 'production');
  static bool get enabled => dsn.isNotEmpty;

  static Future<void> run(FutureOr<void> Function() appRunner) async {
    if (!enabled) {
      await appRunner();
      return;
    }
    await SentryFlutter.init(
      (o) {
        o.dsn = dsn;
        o.environment = environment;
        o.sendDefaultPii = false;
        o.tracesSampleRate = 0; // errors only
        o.attachScreenshot = false;
        o.attachViewHierarchy = false;
        // debugPrint logs API responses (profile: email, phone) - never send them.
        o.enablePrintBreadcrumbs = false;
        // UI breadcrumbs carry widget labels/texts the user typed or saw.
        o.enableUserInteractionBreadcrumbs = false;
        o.maxBreadcrumbs = 50;
        o.beforeBreadcrumb = scrubBreadcrumb;
        o.beforeSend = scrubEvent;
      },
      appRunner: appRunner,
    );
  }

  static final _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');
  static final _phone = RegExp(r'\+?\d[\d\s-]{8,}\d');
  static final _jwt = RegExp(r'eyJ[\w-]+\.[\w-]+\.[\w-]+');
  static final _bearer = RegExp(r'(Bearer\s+)\S+', caseSensitive: false);
  static final _secretParam = RegExp(r'((?:token|code|password|otp|key)=)[^&\s]+', caseSensitive: false);

  /// Removes personal data and secrets from free text.
  static String scrub(String s) => s
      .replaceAll(_jwt, '[token]')
      .replaceAllMapped(_bearer, (m) => '${m[1]}[token]')
      .replaceAllMapped(_secretParam, (m) => '${m[1]}[redacted]')
      .replaceAll(_email, '[email]')
      .replaceAll(_phone, '[phone]');

  /// URL without query string or fragment (ids in paths are kept, they are not personal).
  static String stripQuery(String url) {
    final i = url.indexOf(RegExp(r'[?#]'));
    return i < 0 ? url : url.substring(0, i);
  }

  static Breadcrumb? scrubBreadcrumb(Breadcrumb? b, Hint hint) {
    if (b == null) return null;
    if (b.category == 'console' || b.type == 'user') return null;
    final data = <String, dynamic>{};
    b.data?.forEach((k, v) {
      if (k == 'url' && v is String) {
        data[k] = stripQuery(v);
      } else if (const {'method', 'status_code', 'reason', 'duration', 'from', 'to', 'state'}.contains(k)) {
        data[k] = v is String ? scrub(v) : v;
      }
      // Anything else (request/response bodies, route arguments, headers) is dropped.
    });
    return Breadcrumb(
      message: b.message == null ? null : scrub(b.message!),
      category: b.category,
      data: data,
      level: b.level,
      type: b.type,
      timestamp: b.timestamp,
    );
  }

  static SentryEvent? scrubEvent(SentryEvent e, Hint hint) => e.copyWith(
        message: e.message?.copyWith(formatted: scrub(e.message!.formatted)),
        exceptions: e.exceptions?.map((x) => x.copyWith(value: x.value == null ? null : scrub(x.value!))).toList(),
        breadcrumbs: e.breadcrumbs?.map((b) => scrubBreadcrumb(b, hint)).whereType<Breadcrumb>().toList(),
        // ignore: deprecated_member_use
        extra: const {},
      );
}
