import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/constants/app_urls.dart';
import 'package:sevenup_mobile/constants/env.dart';
import 'package:sevenup_mobile/data/session_store.dart';
import 'package:sevenup_mobile/models/user.dart';

/// A ready-to-verify 2FA challenge (built from authenticate + init2fa).
class TwoFactorChallenge {
  final String token; // pending token, unlocked after verify
  final String method; // 'email' | 'authenticator' | 'both'
  final int expirySeconds;
  final bool requiresSetup; // authenticator not yet configured
  final bool methodSelectionRequired; // 'both' — user must choose
  final List<String> availableMethods;
  final String? secret; // authenticator setup
  final String? qrCode;
  final String? manualEntryKey;
  final User user;
  final String username;
  final String password;
  final String? message;

  const TwoFactorChallenge({
    required this.token,
    required this.method,
    required this.expirySeconds,
    required this.requiresSetup,
    required this.methodSelectionRequired,
    required this.availableMethods,
    required this.user,
    required this.username,
    required this.password,
    this.secret,
    this.qrCode,
    this.manualEntryKey,
    this.message,
  });

  String get email => user.email;

  /// Narrow a `both` challenge to a chosen method (email/authenticator).
  TwoFactorChallenge choose(String chosen) => TwoFactorChallenge(
        token: token,
        method: chosen,
        expirySeconds: expirySeconds,
        requiresSetup: requiresSetup,
        methodSelectionRequired: false,
        availableMethods: availableMethods,
        secret: secret,
        qrCode: qrCode,
        manualEntryKey: manualEntryKey,
        user: user,
        username: username,
        password: password,
        message: message,
      );
}

/// Result of `authenticate`. When 2FA applies, [challenge] is populated
/// directly from the authenticate response (the source of truth).
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? token;
  final TwoFactorChallenge? challenge;

  const AuthResult._({
    required this.success,
    this.message,
    this.user,
    this.token,
    this.challenge,
  });

  bool get requires2fa => challenge != null;

  factory AuthResult.failure(String? message) =>
      AuthResult._(success: false, message: message);
  factory AuthResult.ok({User? user, String? token, String? message}) =>
      AuthResult._(success: true, user: user, token: token, message: message);
  factory AuthResult.needs2fa(TwoFactorChallenge c) =>
      AuthResult._(
          success: true,
          user: c.user,
          token: c.token,
          challenge: c,
          message: c.message);
}

/// Result of `init2fa` — the source of truth for whether 2FA is required.
class TwoFactorInit {
  final bool success;
  final String? message;
  final bool requires2fa;
  final String method; // email | authenticator | both
  final bool methodSelectionRequired;
  final List<String> availableMethods;
  final bool authenticatorSetupRequired;
  final bool requiresSetup;
  final String? secret;
  final String? qrCode;
  final String? manualEntryKey;
  final int expirySeconds;

  const TwoFactorInit({
    required this.success,
    this.message,
    this.requires2fa = false,
    this.method = 'email',
    this.methodSelectionRequired = false,
    this.availableMethods = const [],
    this.authenticatorSetupRequired = false,
    this.requiresSetup = false,
    this.secret,
    this.qrCode,
    this.manualEntryKey,
    this.expirySeconds = 600,
  });
}

/// Result of a verify / resend / setup call.
class TwoFactorResult {
  final bool success;
  final String? message;
  final bool requiresSetup;
  final String? secret;
  final String? qrCode;
  final String? manualEntryKey;
  const TwoFactorResult({
    required this.success,
    this.message,
    this.requiresSetup = false,
    this.secret,
    this.qrCode,
    this.manualEntryKey,
  });
}

/// Auth + Two-Factor Authentication API (Tangerine365 Enterprise).
///
/// The backend is PHP-session bound: the token and 2FA-verified state live in
/// the session, so every call carries the same `PHPSESSID` cookie (see
/// [SessionStore]). 2FA is detected via `init2fa`, not the authenticate body.
class TwoFactorApi {
  Env get _env => GetIt.I<Env>();

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> form,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final base =
          _env.baseUrl.endsWith('/') ? _env.baseUrl : '${_env.baseUrl}/';
      final req = await client.postUrl(Uri.parse('$base$path'));
      req.headers.set(HttpHeaders.contentTypeHeader,
          'application/x-www-form-urlencoded');
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final cookie = SessionStore.instance.cookie;
      if (cookie != null) {
        req.headers.set(HttpHeaders.cookieHeader, cookie);
      }
      req.write(form.entries
          .map((e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&'));
      final resp = await req.close();
      // Keep the session cookie in sync.
      SessionStore.instance.captureFrom(resp.cookies);
      final body = await resp.transform(utf8.decoder).join();
      final decoded = body.isEmpty ? const {} : jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'success': false, 'message': 'Unexpected server response.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    } finally {
      client.close(force: true);
    }
  }

  Future<AuthResult> authenticate({
    required String username,
    required String password,
  }) async {
    final json = await _post(AppUrls.authenticate, {
      'username': username,
      'password': password,
    });
    if (json['success'] != true) {
      return AuthResult.failure(
          json['message']?.toString() ?? 'Login failed.');
    }
    User? user;
    try {
      if (json['data'] is Map) {
        user = User.fromJson(Map<String, dynamic>.from(json['data'] as Map));
      }
    } catch (_) {}
    final token = json['token']?.toString();

    // authenticate returns the full 2FA challenge when it applies.
    if (json['requires_2fa'] == true && user != null && token != null) {
      return AuthResult.needs2fa(TwoFactorChallenge(
        token: token,
        method: (json['method'] ?? 'email').toString(),
        expirySeconds: _asInt(json['twofa_expiry_time']) ?? 600,
        requiresSetup: json['authenticator_setup_required'] == true ||
            json['requires_setup'] == true,
        methodSelectionRequired: json['method_selection_required'] == true,
        availableMethods: json['available_methods'] is List
            ? (json['available_methods'] as List)
                .map((e) => e.toString())
                .toList()
            : const [],
        secret: json['secret']?.toString(),
        qrCode: json['qr_code']?.toString(),
        manualEntryKey: json['manual_entry_key']?.toString(),
        user: user,
        username: username,
        password: password,
        message: json['message']?.toString(),
      ));
    }

    return AuthResult.ok(
      user: user,
      token: token,
      message: json['message']?.toString(),
    );
  }

  /// Initialize/detect 2FA for the authenticated session (authoritative).
  Future<TwoFactorInit> initTwoFactor({required String token}) async {
    final json = await _post(AppUrls.init2fa, {'auth': token});
    if (json['success'] != true) {
      return TwoFactorInit(
          success: false, message: json['message']?.toString());
    }
    return TwoFactorInit(
      success: true,
      message: json['message']?.toString(),
      requires2fa: json['requires_2fa'] == true,
      method: (json['method'] ?? 'email').toString(),
      methodSelectionRequired: json['method_selection_required'] == true,
      availableMethods: json['available_methods'] is List
          ? (json['available_methods'] as List).map((e) => e.toString()).toList()
          : const [],
      authenticatorSetupRequired: json['authenticator_setup_required'] == true,
      requiresSetup: json['requires_setup'] == true,
      secret: json['secret']?.toString(),
      qrCode: json['qr_code']?.toString(),
      manualEntryKey: json['manual_entry_key']?.toString(),
      expirySeconds: _asInt(json['twofa_expiry_time']) ?? 600,
    );
  }

  Future<TwoFactorResult> verify({
    required String token,
    required String method,
    required String code,
  }) async {
    return _result(await _post(AppUrls.verify2fa, {
      'auth': token,
      'method': method,
      'code': code,
    }));
  }

  Future<TwoFactorResult> resend({required String token}) async {
    return _result(await _post(AppUrls.resend2fa, {'auth': token}));
  }

  Future<TwoFactorResult> verifySetup({
    required String token,
    required String secret,
    required String code,
  }) async {
    return _result(await _post(AppUrls.verify2faSetup, {
      'auth': token,
      'secret': secret,
      'code': code,
    }));
  }

  TwoFactorResult _result(Map<String, dynamic> json) => TwoFactorResult(
        success: json['success'] == true,
        message: json['message']?.toString(),
        requiresSetup: json['requires_setup'] == true,
        secret: json['secret']?.toString(),
        qrCode: json['qr_code']?.toString(),
        manualEntryKey: json['manual_entry_key']?.toString(),
      );

  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
