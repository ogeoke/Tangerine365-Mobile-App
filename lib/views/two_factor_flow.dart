import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/auth_widgets.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/services/two_factor_api.dart';
import 'package:sevenup_mobile/views/biometric_flow.dart';

/// Entry point for the 2FA flow: returns the correct first screen for a
/// challenge. [onComplete] finalizes sign-in once verification succeeds.
Widget twoFactorEntry(TwoFactorChallenge challenge, VoidCallback onComplete) {
  if (challenge.methodSelectionRequired) {
    return Choose2FAMethodPage(challenge: challenge, onComplete: onComplete);
  }
  if (challenge.method == 'authenticator') {
    return challenge.requiresSetup
        ? AuthenticatorSetupPage(challenge: challenge, onComplete: onComplete)
        : AuthenticatorVerifyPage(challenge: challenge, onComplete: onComplete);
  }
  return EmailOtpPage(challenge: challenge, onComplete: onComplete);
}

String maskEmail(String id) {
  if (id.isEmpty) return 'your registered email';
  if (id.contains('@')) {
    final p = id.split('@');
    final masked = p[0].isEmpty ? '' : '${p[0][0]}***';
    return '$masked@${p.length > 1 ? p[1] : ''}';
  }
  return id.length <= 1 ? '$id***' : '${id[0]}***';
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

// -----------------------------------------------------------------------------
// 00A — Choose verification method
// -----------------------------------------------------------------------------
class Choose2FAMethodPage extends StatefulWidget {
  final TwoFactorChallenge challenge;
  final VoidCallback onComplete;
  const Choose2FAMethodPage({
    super.key,
    required this.challenge,
    required this.onComplete,
  });

  @override
  State<Choose2FAMethodPage> createState() => _Choose2FAMethodPageState();
}

class _Choose2FAMethodPageState extends State<Choose2FAMethodPage> {
  final _api = TwoFactorApi();
  String _method = 'email';
  bool _loading = false;

  Future<void> _continue() async {
    final c = widget.challenge.choose(_method);
    if (_method == 'authenticator') {
      _push(
        context,
        c.requiresSetup
            ? AuthenticatorSetupPage(challenge: c, onComplete: widget.onComplete)
            : AuthenticatorVerifyPage(
                challenge: c, onComplete: widget.onComplete),
      );
      return;
    }
    // Email chosen on a "both" account: the OTP is not sent yet — trigger it.
    setState(() => _loading = true);
    await _api.resend(token: c.token);
    if (!mounted) return;
    setState(() => _loading = false);
    _push(context, EmailOtpPage(challenge: c, onComplete: widget.onComplete));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Select verification method',
      subtitle: 'Choose how you want to verify your account.',
      footer: 'Secure verification by Tangerine365',
      children: [
        _MethodCard(
          icon: Icons.mail_outline,
          title: 'Verify by email',
          subtitle: 'Receive a six-digit code at your registered email address.',
          selected: _method == 'email',
          onTap: () => setState(() => _method = 'email'),
        ),
        const SizedBox(height: 14),
        _MethodCard(
          icon: Icons.shield_outlined,
          title: 'Authenticator app',
          subtitle: 'Use your preferred authenticator app.',
          selected: _method == 'authenticator',
          onTap: () => setState(() => _method = 'authenticator'),
        ),
        const SizedBox(height: 28),
        AuthPrimaryButton(
            label: 'Continue', isLoading: _loading, onPressed: _continue),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTokens.lightGreen : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTokens.primary : AppTokens.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTokens.primary, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTokens.manrope(
                            size: 15,
                            weight: 700,
                            color: AppTokens.textPrimary)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: AppTokens.manrope(
                            size: 12,
                            weight: 400,
                            height: 16,
                            color: AppTokens.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppTokens.primary : AppTokens.border,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 00B — Email OTP verification
// -----------------------------------------------------------------------------
class EmailOtpPage extends StatefulWidget {
  final TwoFactorChallenge challenge;
  final VoidCallback onComplete;
  const EmailOtpPage({
    super.key,
    required this.challenge,
    required this.onComplete,
  });

  @override
  State<EmailOtpPage> createState() => _EmailOtpPageState();
}

class _EmailOtpPageState extends State<EmailOtpPage> {
  final _api = TwoFactorApi();
  String _code = '';
  bool _loading = false;
  String? _error;

  int get _minutes => (widget.challenge.expirySeconds / 60).round().clamp(1, 60);

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _error = 'Please enter the 6-digit code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _api.verify(
      token: widget.challenge.token,
      method: 'email',
      code: _code,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success) {
      _push(context,
          VerificationSuccessPage(onComplete: widget.onComplete));
    } else {
      setState(() => _error = res.message ?? 'Invalid or expired code.');
    }
  }

  Future<void> _resend() async {
    final res = await _api.resend(token: widget.challenge.token);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res.success
          ? 'A new code has been sent to your email.'
          : (res.message ?? 'Could not resend the code.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Verify your email',
      subtitle: _error ??
          'Enter the six-digit code sent to your registered email address.',
      footer: 'Secure verification by Tangerine365',
      children: [
        _Pill('Code sent to ${maskEmail(widget.challenge.email)}'),
        const SizedBox(height: 20),
        AuthOtpInput(
          onChanged: (v) => _code = v,
          onCompleted: _verify,
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'OTP expires in $_minutes minutes',
            textAlign: TextAlign.center,
            style: AppTokens.manrope(
                size: 12, weight: 600, color: AppTokens.accent),
          ),
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(
            label: 'Verify and continue', isLoading: _loading, onPressed: _verify),
        const SizedBox(height: 20),
        _ResendRow(onResend: _resend),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 00C — Authenticator setup (QR + manual key)
// -----------------------------------------------------------------------------
class AuthenticatorSetupPage extends StatelessWidget {
  final TwoFactorChallenge challenge;
  final VoidCallback onComplete;
  const AuthenticatorSetupPage({
    super.key,
    required this.challenge,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Set up authenticator',
      subtitle: 'Scan this QR code with your preferred authenticator app.',
      footer: 'Authenticator setup by Tangerine365',
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _QrImage(qrCode: challenge.qrCode),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'QR code is generated securely for each account.',
            style: AppTokens.manrope(
                size: 12, weight: 400, color: AppTokens.textSecondary),
          ),
        ),
        const SizedBox(height: 20),
        _ManualKeyBox(
            value: challenge.manualEntryKey ?? challenge.secret ?? ''),
        const SizedBox(height: 20),
        AuthPrimaryButton(
          label: "I've added the account",
          onPressed: () => _push(
            context,
            VerifyAuthenticatorSetupPage(
                challenge: challenge, onComplete: onComplete),
          ),
        ),
      ],
    );
  }
}

class _QrImage extends StatelessWidget {
  final String? qrCode;
  const _QrImage({required this.qrCode});

  @override
  Widget build(BuildContext context) {
    final data = qrCode;
    if (data != null && data.contains('base64,')) {
      try {
        final bytes = base64Decode(data.split('base64,').last);
        return Image.memory(bytes, width: 220, height: 220, gaplessPlayback: true);
      } catch (_) {}
    }
    return const SizedBox(
      width: 220,
      height: 220,
      child: Center(child: Icon(Icons.qr_code_2, size: 120)),
    );
  }
}

class _ManualKeyBox extends StatelessWidget {
  final String value;
  const _ManualKeyBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTokens.lightGreen.withOpacity(.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.primary.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manual entry key',
              style: AppTokens.manrope(
                  size: 11, weight: 500, color: AppTokens.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTokens.manrope(
                  size: 16, weight: 600, color: AppTokens.textPrimary)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 00C1 — Verify authenticator setup
// -----------------------------------------------------------------------------
class VerifyAuthenticatorSetupPage extends StatefulWidget {
  final TwoFactorChallenge challenge;
  final VoidCallback onComplete;
  const VerifyAuthenticatorSetupPage({
    super.key,
    required this.challenge,
    required this.onComplete,
  });

  @override
  State<VerifyAuthenticatorSetupPage> createState() =>
      _VerifyAuthenticatorSetupPageState();
}

class _VerifyAuthenticatorSetupPageState
    extends State<VerifyAuthenticatorSetupPage> {
  final _api = TwoFactorApi();
  String _code = '';
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _error = 'Please enter the 6-digit code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _api.verifySetup(
      token: widget.challenge.token,
      secret: widget.challenge.secret ?? widget.challenge.manualEntryKey ?? '',
      code: _code,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success) {
      _push(context,
          VerificationSuccessPage(onComplete: widget.onComplete));
    } else {
      setState(() => _error = res.message ?? 'Invalid code for setup.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Verify setup',
      subtitle: _error ??
          'Enter the six-digit code from your authenticator app to confirm setup.',
      footer: 'Authenticator setup by Tangerine365',
      children: [
        AuthOtpInput(onChanged: (v) => _code = v, onCompleted: _verify),
        const SizedBox(height: 20),
        AuthPrimaryButton(
            label: 'Verify setup', isLoading: _loading, onPressed: _verify),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 00D — Authenticator verification (already configured)
// -----------------------------------------------------------------------------
class AuthenticatorVerifyPage extends StatefulWidget {
  final TwoFactorChallenge challenge;
  final VoidCallback onComplete;
  const AuthenticatorVerifyPage({
    super.key,
    required this.challenge,
    required this.onComplete,
  });

  @override
  State<AuthenticatorVerifyPage> createState() =>
      _AuthenticatorVerifyPageState();
}

class _AuthenticatorVerifyPageState extends State<AuthenticatorVerifyPage> {
  final _api = TwoFactorApi();
  String _code = '';
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _error = 'Please enter the 6-digit code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _api.verify(
      token: widget.challenge.token,
      method: 'authenticator',
      code: _code,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success) {
      _push(context,
          VerificationSuccessPage(onComplete: widget.onComplete));
    } else {
      setState(() => _error = res.message ?? 'Invalid authenticator code.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Verify authenticator',
      subtitle: _error ??
          'Enter the six-digit code from your authenticator app.',
      footer: 'Secure verification by Tangerine365',
      children: [
        AuthOtpInput(onChanged: (v) => _code = v, onCompleted: _verify),
        const SizedBox(height: 20),
        AuthPrimaryButton(
            label: 'Verify and continue',
            isLoading: _loading,
            onPressed: _verify),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 00E — Verification successful
// -----------------------------------------------------------------------------
class VerificationSuccessPage extends StatelessWidget {
  final VoidCallback onComplete;
  const VerificationSuccessPage({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: false,
      footer: 'Secure verification by Tangerine365',
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
            child: const Icon(Icons.check, color: AppTokens.primary, size: 52),
          ),
        ),
        const SizedBox(height: 24),
        Text('Verification successful',
            textAlign: TextAlign.center,
            style: AppTokens.manrope(
                size: 24, weight: 700, color: AppTokens.textPrimary)),
        const SizedBox(height: 10),
        Text(
          'Your account is now fully authenticated. You will be taken to Home.',
          textAlign: TextAlign.center,
          style: AppTokens.manrope(
              size: 13, weight: 400, height: 20, color: AppTokens.textSecondary),
        ),
        const SizedBox(height: 28),
        AuthPrimaryButton(
          label: 'Continue to Home',
          onPressed: () => continueAfterAuth(context, onComplete),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Small shared pieces
// -----------------------------------------------------------------------------
class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTokens.lightGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.primary.withOpacity(.2)),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: AppTokens.manrope(
              size: 13, weight: 600, color: AppTokens.primary)),
    );
  }
}

class _ResendRow extends StatelessWidget {
  final VoidCallback onResend;
  const _ResendRow({required this.onResend});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Didn't receive the code? ",
              style: AppTokens.manrope(
                  size: 13, weight: 400, color: AppTokens.textSecondary)),
          GestureDetector(
            onTap: onResend,
            child: Text('Resend',
                style: AppTokens.manrope(
                    size: 13, weight: 600, color: AppTokens.accent)),
          ),
        ],
      ),
    );
  }
}
