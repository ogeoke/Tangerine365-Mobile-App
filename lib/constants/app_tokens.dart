import 'dart:ui' show FontVariation;

import 'package:flutter/material.dart';
import 'package:sevenup_mobile/gen/fonts.gen.dart';

/// Centralized design tokens for the approved Tangerine365 Figma design.
///
/// Source of truth: `design/figma_export/TOKENS.md`, extracted from the
/// approved Figma file (WEMA Bank Mobile Assets and Design, page 48:284).
/// Do not hand-pick colors/sizes in widgets — reference these tokens so every
/// screen stays consistent with Figma.
class AppTokens {
  AppTokens._();

  // ---------------------------------------------------------------------------
  // Brand colors
  // ---------------------------------------------------------------------------
  /// Primary Tangerine green. Replaces legacy `#48B401`.
  static const Color primary = Color(0xFF397B27);

  /// Accent Tangerine orange. Replaces legacy `#FB562A`.
  static const Color accent = Color(0xFFE83312);

  static const Color lightGreen = Color(0xFFEBF6E7);
  static const Color lightGreenAlt = Color(0xFFE8F7E3); // success icon bg
  static const Color lightOrange = Color(0xFFFBE4D6);
  static const Color darkSupportGreen = Color(0xFF406E2B);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF141A21);
  static const Color textPrimaryDeep =
      Color(0xFF0E1217); // analytics/auth headings
  static const Color textSecondary = Color(0xFF6B7385);
  static const Color textSecondaryAlt =
      Color(0xFF747D8B); // analytics/auth support
  static const Color placeholder = Color(0xFF99A3A1);
  static const Color fieldLabel = Color(0xFF30383B);
  static const Color fieldValue = Color(0xFF404F45);

  // ---------------------------------------------------------------------------
  // Surfaces
  // ---------------------------------------------------------------------------
  static const Color surface = Color(0xFFFFFFFF);
  static const Color screenBg = Color(0xFFF7FAF7);
  static const Color screenBgAlt = Color(0xFFF8FAF8);
  static const Color authBg = Color(0xFFF6F4E9);
  static const Color border = Color(0xFFE3E8E3);
  static const Color authInputBorder = Color(0xFFD5DAD5);
  static const Color supportInputBorder = Color(0xFFD4DBD4);
  static const Color readOnlyField = Color(0xFFF0F2F0);

  // ---------------------------------------------------------------------------
  // Semantic / status
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF397B27);
  static const Color statusNotStarted = Color(0xFFE53935); // red
  static const Color statusInProgress = Color(0xFFF2A511); // yellow
  static const Color statusCompleted = Color(0xFF397B27); // green

  // Analytics chart series (distinct from lesson-status colors — do not mix).
  static const Color analyticsCompleted = Color(0xFF4FA633);
  static const Color analyticsInProgress = Color(0xFFEDB01F);
  static const Color analyticsNotStarted = Color(0xFF59B2D1);
  static const Color analyticsWaiting = Color(0xFFEC380E);

  // ---------------------------------------------------------------------------
  // Home service-module cards (from the approved `01 • Home` frame)
  // ---------------------------------------------------------------------------
  static const Color moduleCoursesBg = Color(0xFF397B27);
  static const Color moduleCoursesIcon = Color(0xFF679756);
  static const Color moduleCoursesText = Color(0xFFFFFFFF);

  static const Color moduleKnowledgeBg = Color(0xFFE2ECD9);
  static const Color moduleKnowledgeBorder = Color(0xFFCADBBE);
  static const Color moduleKnowledgeIcon = Color(0xFFCDDEC1);
  static const Color moduleKnowledgeText = Color(0xFF4C6248);

  static const Color moduleBankingBg = Color(0xFFFBE4D6);
  static const Color moduleBankingBorder = Color(0xFFF0CCB5);
  static const Color moduleBankingIcon = Color(0xFFF1CEB6);
  static const Color moduleBankingText = Color(0xFF785942);

  static const Color moduleInfoBg = Color(0xFFDDEFE6);
  static const Color moduleInfoBorder = Color(0xFFC2DCD0);
  static const Color moduleInfoIcon = Color(0xFFC5DDD1);
  static const Color moduleInfoText = Color(0xFF47695D);

  // New Home (Figma 01): inactive/"coming soon" service cards are grey with
  // white icon art + text; only the active Courses card is green.
  static const Color moduleComingSoonBg = Color(0xFFC0C4C1);

  // ---------------------------------------------------------------------------
  // Overlays
  // ---------------------------------------------------------------------------
  static const Color authVeil = Color(0xFFFFFDF6); // use at 18% opacity
  static const double authVeilOpacity = 0.18;
  static const Color modalScrim = Color(0xFF050A08); // use at 48% opacity
  static const double modalScrimOpacity = 0.48;
  static const double authBlurSigma = 11.0;

  // ---------------------------------------------------------------------------
  // Shape & spacing
  // ---------------------------------------------------------------------------
  static const double screenPadding = 20.0;
  static const double authPadding = 40.0;
  static const double cardRadius = 14.0;
  static const double moduleCardRadius = 20.0;
  static const double analyticsCardRadius = 16.0;
  static const double authButtonRadius = 25.0;
  static const double secondaryButtonRadius = 23.0;
  static const double subscriptionButtonRadius = 14.0;
  static const double loginInputRadius = 12.0;
  static const double supportInputRadius = 8.0;
  static const double otpBoxRadius = 11.0;
  static const double subscriptionInputRadius = 14.0;

  static const double authButtonHeight = 50.0;
  static const double secondaryButtonHeight = 46.0;
  static const double subscriptionButtonHeight = 54.0;
  static const double loginInputHeight = 50.0;
  static const double supportInputHeight = 42.0;

  static const double drawerWidth = 304.0;
  static const Size moduleCardSize = Size(156, 164);
  static const Size otpBoxSize = Size(40, 54);

  // ---------------------------------------------------------------------------
  // Shadows
  // ---------------------------------------------------------------------------
  static const List<BoxShadow> catalogueCardShadow = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 4)),
  ]; // 0 4 10 rgba(0,0,0,0.12)

  static const List<BoxShadow> recommendationCardShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4)),
  ]; // 0 4 8 rgba(0,0,0,0.10)

  static const List<BoxShadow> analyticsCardShadow = [
    BoxShadow(color: Color(0x140A1A0A), blurRadius: 10, offset: Offset(0, 3)),
  ]; // 0 3 10 rgba(10,26,10,0.08)

  static const List<BoxShadow> authButtonShadow = [
    BoxShadow(color: Color(0x38174112), blurRadius: 12, offset: Offset(0, 5)),
  ]; // 0 5 12 rgba(23,65,18,0.22)

  static const List<BoxShadow> successModalShadow = [
    BoxShadow(color: Color(0x2E000000), blurRadius: 24, offset: Offset(0, 10)),
  ]; // 0 10 24 rgba(0,0,0,0.18)

  // ---------------------------------------------------------------------------
  // Typography (Manrope variable font)
  // ---------------------------------------------------------------------------
  static const String fontFamily = FontFamily.manrope;

  /// Build a Manrope [TextStyle]. Because Manrope ships as a single variable
  /// font, we set both [fontWeight] and the `wght` [FontVariation] so the
  /// correct weight renders reliably across Flutter versions.
  static TextStyle manrope({
    required double size,
    double weight = 400,
    double? height,
    Color color = textPrimary,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: height == null ? null : height / size,
      color: color,
      letterSpacing: letterSpacing,
      fontWeight: _weightOf(weight),
      fontVariations: [FontVariation('wght', weight)],
    );
  }

  static FontWeight _weightOf(double w) {
    if (w >= 700) return FontWeight.w700;
    if (w >= 600) return FontWeight.w600;
    if (w >= 500) return FontWeight.w500;
    return FontWeight.w400;
  }

  // Named styles used across screens (see TOKENS.md "Exact ... text styles").
  static TextStyle get moduleTitle =>
      manrope(size: 23, weight: 600, color: textPrimary);
  static TextStyle get loginHeading =>
      manrope(size: 23, weight: 600, height: 31, color: textPrimaryDeep);
  static TextStyle get otpHeading =>
      manrope(size: 21, weight: 600, height: 29, color: textPrimaryDeep);
  static TextStyle get hubSectionHeading =>
      manrope(size: 15, weight: 600, color: textPrimary);
  static TextStyle get homeServiceHeading =>
      manrope(size: 17, weight: 600, color: textPrimary);
  static TextStyle get analyticsSectionHeading =>
      manrope(size: 16, weight: 700, color: textPrimaryDeep);
  static TextStyle get analyticsCardHeading =>
      manrope(size: 14, weight: 700, color: textPrimaryDeep);
  static TextStyle get screenSubtitle =>
      manrope(size: 12, weight: 400, color: textSecondary);
  static TextStyle get loginSubtitle =>
      manrope(size: 11, weight: 400, height: 16, color: textSecondaryAlt);
  static TextStyle get courseCardTitle =>
      manrope(size: 10, weight: 600, color: textPrimary);
  static TextStyle get courseCardMeta =>
      manrope(size: 9, weight: 400, color: textSecondary);
  static TextStyle get formLabel =>
      manrope(size: 11, weight: 600, color: fieldLabel);
  static TextStyle get formValue =>
      manrope(size: 10, weight: 400, color: fieldValue);
  static TextStyle get authButtonLabel =>
      manrope(size: 12, weight: 600, height: 17, color: Colors.white);
  static TextStyle get otpDigit =>
      manrope(size: 20, weight: 600, color: textPrimaryDeep);
}
