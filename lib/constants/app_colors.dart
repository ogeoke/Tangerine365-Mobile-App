import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/constants/env.dart';

/// Thin facade kept for backwards compatibility. New screens should prefer
/// [AppTokens] directly for the full approved palette.
class AppColors {
  /// Neutral grey retained for existing screens that used it as a muted color.
  static const accent = Color(0xff676767);

  /// Brand primary (Tangerine green), env-driven so white-label builds can
  /// override it. Currently resolves to [AppTokens.primary].
  static final primary = GetIt.I<Env>().primaryColor;

  /// Brand accent (Tangerine orange).
  static const brandAccent = AppTokens.accent;
}
