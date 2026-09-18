part of 'login_page.dart';

enum _ResetStep { form, success, failed }

/// Forgot password (Figma 00Q form / 00Q1 success / 00Q2 failed). Uses the
/// login screen's background, field and button. Wired to
/// `POST api/auth/lostPassword`. Only reachable when the admin has enabled
/// password recovery.
class ForgotPasswordPage extends StatefulWidget {
  final String initialUsername;
  const ForgotPasswordPage({super.key, this.initialUsername = ''});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username =
      TextEditingController(text: widget.initialUsername);
  final _api = TwoFactorApi();
  _ResetStep _step = _ResetStep.form;
  bool _sending = false;

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _sending = true);
    final ok = await _api.lostPassword(_username.text.trim());
    if (!mounted) return;
    setState(() {
      _sending = false;
      _step = ok ? _ResetStep.success : _ResetStep.failed;
    });
  }

  void _backToSignIn() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.authBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AuthBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      children: [
                        const SizedBox(height: 32),
                        Center(
                          child: Image.asset(
                            AppAssets.tangerineLogo,
                            height: 128,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 34),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: switch (_step) {
                            _ResetStep.form => _buildForm(),
                            _ResetStep.success => _buildResult(
                                key: const ValueKey('success'),
                                success: true,
                              ),
                            _ResetStep.failed => _buildResult(
                                key: const ValueKey('failed'),
                                success: false,
                              ),
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 8),
                  child: Text(
                    'Secure access to Tangerine365',
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

  Widget _buildForm() {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Forgot password?', style: AppTokens.loginHeading),
        const SizedBox(height: 8),
        Text(
          'Enter your email or staff ID. We’ll send instructions to reset '
          'your password.',
          style: AppTokens.loginSubtitle,
        ),
        const SizedBox(height: 28),
        _AuthField(
          label: 'Email or staff ID',
          hint: 'Enter your email or staff ID',
          icon: Icons.mail_outline,
          controller: _username,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: _send,
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
          label: 'Send reset link',
          isLoading: _sending,
          onPressed: _send,
        ),
        const SizedBox(height: 20),
        _TextLink(label: 'Back to sign in', onTap: _backToSignIn),
      ],
    );
  }

  Widget _buildResult({required Key key, required bool success}) {
    final color = success ? AppTokens.primary : AppTokens.accent;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.07),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(success ? Icons.check_rounded : Icons.close_rounded,
                color: color, size: 44),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          success ? 'Check your email' : 'Couldn’t send reset link',
          textAlign: TextAlign.center,
          style: AppTokens.loginHeading,
        ),
        const SizedBox(height: 12),
        Text(
          success
              ? 'If an account matches the details provided, password reset '
                  'instructions have been sent.'
              : 'We couldn’t complete your request. Check your internet '
                  'connection and try again.',
          textAlign: TextAlign.center,
          style: AppTokens.loginSubtitle,
        ),
        const SizedBox(height: 40),
        _PrimaryButton(
          label: success ? 'Back to sign in' : 'Try again',
          isLoading: false,
          onPressed: success ? _backToSignIn : _send,
        ),
        const SizedBox(height: 20),
        _TextLink(
          label: success ? 'Resend instructions' : 'Back to sign in',
          onTap: success ? _send : _backToSignIn,
        ),
      ],
    );
  }
}

class _TextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TextLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Text(
            label,
            style: AppTokens.manrope(
                size: 14, weight: 600, color: AppTokens.accent),
          ),
        ),
      ),
    );
  }
}
