import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/constants/env.dart';
import 'package:sevenup_mobile/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Application theme, aligned to the approved Tangerine365 Figma design.
/// Colors, typography, and shapes come from [AppTokens]
/// (see `design/figma_export/TOKENS.md`).
class AppTheme {
  static final env = GetIt.I<Env>();

  // Legacy tenant colors retained for compatibility with any older references.
  static const Color jaiz = Color(0xff0e4c28);
  static const Color heritage = Color(0xff4dc243);
  static const Color union = Color.fromRGBO(17, 153, 211, 1.0);

  /// Manrope is the approved font family (replaces Inter/Jost/Mulish).
  static const String font = FontFamily.manrope;

  static final Color accentColor = env.accentColor;
  static final Color primaryColor = env.primaryColor;

  static final TextTheme textTheme = TextTheme(
    // Screen titles / large headings.
    displayMedium: AppTokens.manrope(
        size: 29, weight: 700, color: AppTokens.textPrimaryDeep),
    headlineMedium: AppTokens.moduleTitle,
    titleLarge: AppTokens.homeServiceHeading,
    titleMedium: AppTokens.hubSectionHeading,
    // Body / supporting.
    bodyLarge:
        AppTokens.manrope(size: 14, weight: 400, color: AppTokens.textPrimary),
    bodyMedium:
        AppTokens.manrope(size: 12, weight: 400, color: AppTokens.textPrimary),
    bodySmall: AppTokens.screenSubtitle,
    labelLarge:
        AppTokens.authButtonLabel.copyWith(color: AppTokens.textPrimary),
  );

  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppTokens.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle:
        AppTokens.manrope(size: 12, weight: 400, color: AppTokens.placeholder),
    labelStyle: AppTokens.formLabel,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.loginInputRadius),
      borderSide: const BorderSide(color: AppTokens.border, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.loginInputRadius),
      borderSide: const BorderSide(color: AppTokens.primary, width: 1.4),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.loginInputRadius),
      borderSide: const BorderSide(color: AppTokens.border, width: 1),
    ),
  );

  static ThemeData get data => ThemeData(
        useMaterial3: true,
        primaryColor: AppTokens.primary,
        scaffoldBackgroundColor: AppTokens.screenBg,
        fontFamily: font,
        canvasColor: AppTokens.surface,
        cardColor: AppTokens.surface,
        textTheme: textTheme,
        inputDecorationTheme: inputDecorationTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppTokens.screenBg,
          foregroundColor: AppTokens.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: AppTokens.textPrimary),
          titleTextStyle: AppTokens.moduleTitle,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTokens.primary,
          primary: AppTokens.primary,
          secondary: AppTokens.accent,
          surface: AppTokens.surface,
        ),
      );
}
