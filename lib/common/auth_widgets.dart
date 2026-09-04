import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevenup_mobile/constants/app_assets.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';

/// Blurred e-learning background + soft veil used by every auth screen.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: AppTokens.authBlurSigma,
            sigmaY: AppTokens.authBlurSigma,
          ),
          child: Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
        ),
        Container(
          color: AppTokens.authVeil.withOpacity(AppTokens.authVeilOpacity),
        ),
      ],
    );
  }
}

/// Shared chrome for the approved auth screens: logo, back + heading, subtitle,
/// scrollable content, and a footer line.
class AuthScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> children;
  final String? footer;
  final bool showBack;
  final VoidCallback? onBack;

  const AuthScaffold({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
    this.footer,
    this.showBack = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTokens.authBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    children: [
                      const SizedBox(height: 32),
                      Center(
                        child: Image.asset(AppAssets.tangerineLogo,
                            height: 120, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 34),
                      if (title != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showBack)
                              GestureDetector(
                                onTap: onBack ??
                                    () => Navigator.of(context).maybePop(),
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 2, right: 6),
                                  child: Icon(Icons.chevron_left,
                                      color: AppTokens.primary, size: 28),
                                ),
                              ),
                            Expanded(
                              child: Text(title!, style: AppTokens.otpHeading),
                            ),
                          ],
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          subtitle!,
                          style: AppTokens.manrope(
                            size: 13,
                            weight: 400,
                            height: 20,
                            color: AppTokens.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ...children,
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 8),
                    child: Text(
                      footer!,
                      textAlign: TextAlign.center,
                      style: AppTokens.manrope(
                          size: 12, weight: 600, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary green pill button for the auth screens.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.authButtonRadius),
        boxShadow: AppTokens.authButtonShadow,
      ),
      child: SizedBox(
        height: AppTokens.authButtonHeight,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTokens.primary,
            disabledBackgroundColor: AppTokens.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.authButtonRadius),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(label,
                  style: AppTokens.manrope(
                      size: 15, weight: 600, color: Colors.white)),
        ),
      ),
    );
  }
}

/// A full-screen status result (success check or error "!") used by the
/// verification-successful and biometric result screens.
class AuthStatusScreen extends StatelessWidget {
  final bool isError;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool primaryLoading;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? footer;

  const AuthStatusScreen({
    super.key,
    this.isError = false,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryLoading = false,
    this.secondaryLabel,
    this.onSecondary,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: false,
      footer: footer,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTokens.lightGreen,
            ),
            child: isError
                ? Text('!',
                    style: AppTokens.manrope(
                        size: 46, weight: 700, color: AppTokens.statusNotStarted))
                : const Icon(Icons.check, color: AppTokens.primary, size: 52),
          ),
        ),
        const SizedBox(height: 24),
        Text(title,
            textAlign: TextAlign.center,
            style: AppTokens.manrope(
                size: 24, weight: 700, color: AppTokens.textPrimary)),
        const SizedBox(height: 10),
        Text(message,
            textAlign: TextAlign.center,
            style: AppTokens.manrope(
                size: 13,
                weight: 400,
                height: 20,
                color: AppTokens.textSecondary)),
        const SizedBox(height: 28),
        AuthPrimaryButton(
            label: primaryLabel, isLoading: primaryLoading, onPressed: onPrimary),
        if (secondaryLabel != null) ...[
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: onSecondary,
              child: Text(secondaryLabel!,
                  style: AppTokens.manrope(
                      size: 14, weight: 600, color: AppTokens.primary)),
            ),
          ),
        ],
      ],
    );
  }
}

/// Six-box OTP input with auto-advance. Reports the joined code on change and
/// fires [onCompleted] when all six digits are entered.
class AuthOtpInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onCompleted;
  const AuthOtpInput({super.key, required this.onChanged, this.onCompleted});

  @override
  State<AuthOtpInput> createState() => _AuthOtpInputState();
}

class _AuthOtpInputState extends State<AuthOtpInput> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final filled = _controllers[i].text.isNotEmpty;
        return SizedBox(
          width: AppTokens.otpBoxSize.width,
          height: AppTokens.otpBoxSize.height,
          child: TextField(
            controller: _controllers[i],
            focusNode: _nodes[i],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: AppTokens.otpDigit,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.otpBoxRadius),
                borderSide: BorderSide(
                    color:
                        filled ? AppTokens.primary : AppTokens.authInputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.otpBoxRadius),
                borderSide:
                    const BorderSide(color: AppTokens.primary, width: 1.6),
              ),
            ),
            onChanged: (v) {
              if (v.isNotEmpty && i < 5) {
                _nodes[i + 1].requestFocus();
              } else if (v.isEmpty && i > 0) {
                _nodes[i - 1].requestFocus();
              }
              setState(() {});
              widget.onChanged(_code);
              if (_code.length == 6) widget.onCompleted?.call();
            },
          ),
        );
      }),
    );
  }
}
