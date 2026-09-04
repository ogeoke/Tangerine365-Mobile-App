import 'dart:io';

/// Holds the backend session cookie (`PHPSESSID`). The Tangerine365 API ties the
/// auth token + 2FA-verified state to the PHP session, so the SAME cookie from
/// login must be carried on every subsequent request (init2fa, verify2fa, and
/// all data endpoints). Shared by [TwoFactorApi] (dart:io) and the Chopper
/// [ApiClient].
class SessionStore {
  SessionStore._();
  static final SessionStore instance = SessionStore._();

  /// e.g. `PHPSESSID=abc123` — ready to use as a `Cookie` header value.
  String? cookie;

  /// Capture the session cookie from a dart:io response's cookies.
  void captureFrom(List<Cookie> cookies) {
    for (final c in cookies) {
      if (c.name.toUpperCase() == 'PHPSESSID' && c.value.isNotEmpty) {
        cookie = 'PHPSESSID=${c.value}';
      }
    }
  }

  void clear() => cookie = null;
}
