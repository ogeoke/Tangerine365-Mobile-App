import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/common/auth_widgets.dart';
import 'package:sevenup_mobile/services/biometrics_service.dart';
import 'package:sevenup_mobile/state/auth/index.dart';

/// Biometric result screens + the post–sign-in "enable biometrics" prompt.
/// These reuse the green [AuthStatusScreen] and follow the approved Figma
/// states 00F (enable), 00G (enabled), 00H (unsuccessful), 00N (permission
/// denied) and 00O (device unsupported).

void _toHome(BuildContext context) =>
    Navigator.of(context).popUntil((r) => r.isFirst);

/// Called once sign-in (incl. 2FA) has succeeded. Finalizes the session first,
/// then offers to enable biometrics when the device supports them and they are
/// not already on; otherwise goes straight Home.
Future<void> continueAfterAuth(
  BuildContext context,
  VoidCallback onComplete,
) async {
  onComplete(); // finalize sign-in so AuthBloc has the user before we branch
  final already = GetIt.I<AuthBloc>().state.useBiometrics;
  final available = !already && await BiometricService.isAvailable();
  if (!context.mounted) return;
  if (available) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EnableBiometricsPage()),
    );
  } else {
    _toHome(context);
  }
}

/// The green result screen for a failed/blocked biometric attempt (00H/N/O).
/// [onRetry] is wired to the "Try Again" button.
Widget biometricResultScreen(
  BiometricOutcome outcome, {
  required VoidCallback onRetry,
}) {
  const footer = 'Biometrics may be unavailable or temporarily locked.';
  switch (outcome) {
    case BiometricOutcome.permissionDenied:
      return AuthStatusScreen(
        isError: true,
        title: 'Biometric permission denied',
        message:
            'Enable biometric access in your device settings, or sign in with your password.',
        primaryLabel: 'Try Again',
        onPrimary: onRetry,
        footer: footer,
      );
    case BiometricOutcome.unavailable:
      return AuthStatusScreen(
        isError: true,
        title: 'Biometrics unavailable',
        message:
            'This device does not support biometric sign-in. Continue with your password.',
        primaryLabel: 'Try Again',
        onPrimary: onRetry,
        footer: footer,
      );
    case BiometricOutcome.failed:
    case BiometricOutcome.success:
      return AuthStatusScreen(
        title: 'Biometric sign-in unsuccessful',
        message:
            "We couldn't verify your identity. Try again or sign in with your password.",
        primaryLabel: 'Try Again',
        onPrimary: onRetry,
        footer: footer,
      );
  }
}

// -----------------------------------------------------------------------------
// 00F — Enable biometrics (offered after first successful sign-in)
// -----------------------------------------------------------------------------
class EnableBiometricsPage extends StatefulWidget {
  const EnableBiometricsPage({super.key});

  @override
  State<EnableBiometricsPage> createState() => _EnableBiometricsPageState();
}

class _EnableBiometricsPageState extends State<EnableBiometricsPage> {
  bool _busy = false;

  Future<void> _enable() async {
    setState(() => _busy = true);
    final outcome = await BiometricService.authenticate();
    if (!mounted) return;
    setState(() => _busy = false);
    if (outcome == BiometricOutcome.success) {
      if (!GetIt.I<AuthBloc>().state.useBiometrics) {
        GetIt.I<AuthBloc>().add(SetBiometrics());
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BiometricsEnabledPage()),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => biometricResultScreen(
          outcome,
          onRetry: () {
            Navigator.of(context).pop();
            _enable();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthStatusScreen(
      title: 'Enable biometric login?',
      message:
          'Use Face ID or fingerprint for faster, secure sign-in on this device.',
      primaryLabel: 'Enable Biometrics',
      primaryLoading: _busy,
      onPrimary: _enable,
      secondaryLabel: 'Not now',
      onSecondary: () => _toHome(context),
      footer: 'You can change this later in Profile settings.',
    );
  }
}

// -----------------------------------------------------------------------------
// 00G — Biometrics enabled
// -----------------------------------------------------------------------------
class BiometricsEnabledPage extends StatelessWidget {
  const BiometricsEnabledPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStatusScreen(
      title: 'Biometrics enabled',
      message: 'You can now sign in securely using Face ID or fingerprint.',
      primaryLabel: 'Continue to Home',
      onPrimary: () => _toHome(context),
      footer: 'Your biometric data remains protected by your device.',
    );
  }
}
