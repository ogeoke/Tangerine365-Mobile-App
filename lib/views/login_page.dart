import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/common/app_dialog.dart';
import 'package:sevenup_mobile/common/authlistener.dart';
import 'package:sevenup_mobile/constants/app_assets.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/services/biometrics_service.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:sevenup_mobile/state/login/index.dart';
import 'package:sevenup_mobile/views/biometric_flow.dart';
import 'package:sevenup_mobile/views/two_factor_flow.dart';

/// Approved Login screen (Figma 00 • Login): blurred e-learning background with
/// a soft veil, the Tangerine365 logo, email/staff-ID + password fields, and a
/// biometrics option. Authentication logic (LoginBloc) is unchanged.
class LoginPage extends StatefulWidget {
  static const routeName = '/login_page';
  final String? message;
  final bool isError;

  const LoginPage({super.key, this.message, this.isError = true});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  late LoginBloc _bloc;

  @override
  void initState() {
    _bloc = LoginBloc(message: widget.message);
    _passwordNode = FocusNode();
    _usernameNode = FocusNode();
    _usernameController = TextEditingController(
      text: GetIt.I<AuthBloc>().state.user?.username,
    );
    _passwordController = TextEditingController();
    super.initState();

    if (GetIt.I<AuthBloc>().state.user != null) {
      _usernameController.text = GetIt.I<AuthBloc>().state.user?.username ?? '';
    }
  }

  @override
  void dispose() {
    _passwordNode.dispose();
    _usernameNode.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late FocusNode _passwordNode;
  late FocusNode _usernameNode;
  bool _navigating2fa = false;

  void _login() {
    _usernameNode.unfocus();
    _passwordNode.unfocus();
    if (_formKey.currentState?.validate() == true) {
      _bloc.add(
        LoginPressedEvent(_usernameController.text, _passwordController.text),
      );
    }
  }

  Future<void> _biometricLogin() async {
    final outcome = await BiometricService.authenticate();
    if (!mounted) return;
    if (outcome == BiometricOutcome.success) {
      _bloc.add(LoginBiometricsPressedEvent());
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => biometricResultScreen(
          outcome,
          onRetry: () {
            Navigator.of(context).pop();
            _biometricLogin();
          },
        ),
      ),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please contact your administrator to reset your password.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      backgroundColor: AppTokens.authBg,
      body: AuthListener(
        page: widget,
        child: BlocListener<LoginBloc, LoginState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state.errorMessage != null) {
              AppDialog.buildErrorDialog(context, state.errorMessage!);
            }
            // 2FA required → open the verification flow with the challenge.
            final challenge = state.challenge;
            if (challenge != null && !_navigating2fa) {
              _navigating2fa = true;
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (_) => twoFactorEntry(
                      challenge,
                      () => _bloc.add(TwoFactorVerifiedEvent(challenge)),
                    ),
                  ))
                  .then((_) => _navigating2fa = false);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _AuthBackground(),
              SafeArea(
                child: Form(
                  key: _formKey,
                  child: BlocBuilder<LoginBloc, LoginState>(
                    bloc: _bloc,
                    buildWhen: (p, s) => s != p,
                    builder: (c, state) => Column(
                      children: [
                        Expanded(
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
                              Text('Welcome back',
                                  style: AppTokens.loginHeading),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to continue your learning journey.',
                                style: AppTokens.loginSubtitle,
                              ),
                              const SizedBox(height: 28),
                              _AuthField(
                                label: 'Email or staff ID',
                                hint: 'Enter your email or staff ID',
                                icon: Icons.mail_outline,
                                controller: _usernameController,
                                focusNode: _usernameNode,
                                keyboardType: TextInputType.emailAddress,
                                onSubmitted: () => _passwordNode.requestFocus(),
                              ),
                              const SizedBox(height: 18),
                              _AuthField(
                                label: 'Password',
                                hint: 'Enter your password',
                                icon: Icons.lock_outline,
                                controller: _passwordController,
                                focusNode: _passwordNode,
                                isPassword: true,
                                onSubmitted: _login,
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: _forgotPassword,
                                  child: Text(
                                    'Forgot password?',
                                    style: AppTokens.manrope(
                                      size: 12,
                                      weight: 600,
                                      color: AppTokens.accent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _PrimaryButton(
                                label: 'Sign in',
                                isLoading: state.isLoading,
                                onPressed: _login,
                              ),
                              // Only offer biometric sign-in once the user has
                              // enabled it (toggled on after a prior sign-in).
                              if (GetIt.I<AuthBloc>().state.useBiometrics) ...[
                                const SizedBox(height: 16),
                                _BiometricButton(
                                  onPressed:
                                      state.isLoading ? null : _biometricLogin,
                                ),
                              ],
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 8),
                          child: Text(
                            'Secure access to Tangerine365',
                            textAlign: TextAlign.center,
                            style: AppTokens.manrope(
                              size: 12,
                              weight: 600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen blurred e-learning background with the approved soft veil.
class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

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

/// Primary green pill button used across the auth screens.
class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
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
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: AppTokens.manrope(
                    size: 15,
                    weight: 600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Outlined "Use biometrics" button.
class _BiometricButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _BiometricButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTokens.authButtonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.fingerprint, color: AppTokens.primary, size: 22),
        label: Text(
          'Use biometrics',
          style: AppTokens.manrope(
            size: 15,
            weight: 600,
            color: AppTokens.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.35),
          side: const BorderSide(color: AppTokens.primary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.authButtonRadius),
          ),
        ),
      ),
    );
  }
}

/// Auth text field with a leading icon, label, and (for passwords) an eye
/// toggle — matching the approved login/OTP field styling.
class _AuthField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isPassword;
  final TextInputType? keyboardType;
  final VoidCallback? onSubmitted;
  const _AuthField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.focusNode,
    this.isPassword = false,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTokens.manrope(
            size: 13,
            weight: 600,
            color: AppTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword && _obscure,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction:
              widget.isPassword ? TextInputAction.done : TextInputAction.next,
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          validator: (t) => (t?.isNotEmpty == true)
              ? null
              : 'Please enter your ${widget.label.toLowerCase()}',
          style: AppTokens.manrope(
            size: 13,
            weight: 400,
            color: AppTokens.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTokens.manrope(
              size: 12,
              weight: 400,
              color: AppTokens.placeholder,
            ),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            prefixIcon: Icon(widget.icon, color: AppTokens.primary, size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppTokens.textSecondary,
                      size: 20,
                    ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.loginInputRadius),
              borderSide: const BorderSide(color: AppTokens.authInputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.loginInputRadius),
              borderSide:
                  const BorderSide(color: AppTokens.primary, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.loginInputRadius),
              borderSide: const BorderSide(color: AppTokens.statusNotStarted),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.loginInputRadius),
              borderSide: const BorderSide(color: AppTokens.statusNotStarted),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Preserved widgets used elsewhere in the app. AppTextField is also used by
// common/contact_form.dart; ExpandContainerState is referenced by LoginBloc.
// -----------------------------------------------------------------------------

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.icon,
    this.focusNode,
    this.isPassword = false,
    required this.autoValidate,
    this.onFieldSubmitted,
    this.onChanged,
    this.radius = 12,
    this.label,
    this.textAlign,
  });
  final TextEditingController? controller;
  final String? hint, label;
  final IconData? icon;
  final FocusNode? focusNode;
  final bool isPassword, autoValidate;
  final double radius;
  final TextAlign? textAlign;
  final Function(String?)? onFieldSubmitted, onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.radius),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          validator: (text) => (text?.isNotEmpty == true)
              ? null
              : 'Please enter a valid ${widget.hint?.toLowerCase()}',
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: widget.onFieldSubmitted,
          obscureText: widget.isPassword && !visible,
          textAlign: widget.textAlign ?? TextAlign.start,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
          decoration: InputDecoration(
            labelText: widget.hint,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            hintText: widget.hint,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            hintMaxLines: 1,
            isDense: true,
            border: border,
            alignLabelWithHint: true,
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        visible = !visible;
                      });
                    },
                    icon: visible
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                  )
                : null,
            enabledBorder: border.copyWith(
              borderSide: const BorderSide(
                width: 0.9,
                color: Color(0xffCECECE),
              ),
            ),
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                width: 1,
                color: Theme.of(context).primaryColor,
              ),
            ),
            errorBorder: border.copyWith(
              borderSide: const BorderSide(width: 0.9, color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

class ExpandContainer extends StatefulWidget {
  const ExpandContainer({super.key});
  @override
  ExpandContainerState createState() => ExpandContainerState();
}

class ExpandContainerState extends State<ExpandContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0,
      upperBound: 50,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (c, w) => AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: controller.value * 1000,
        color: Theme.of(context).primaryColor,
        height: controller.value * 1000,
      ),
    );
  }
}
