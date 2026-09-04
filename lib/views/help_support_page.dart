import 'package:data_repository/data_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/app_dialog.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/common/success_dialog.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/main.dart';
import 'package:sevenup_mobile/models/error_model/error_model.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:sevenup_mobile/views/courses_hub_page.dart';

/// Help & Support (Figma 15 / 15A). Contact-support form that submits to the
/// existing SendSupport endpoint (username + useremail + content). The subject
/// and phone are folded into the message content, since the endpoint takes a
/// single content field.
class HelpSupportPage extends StatefulWidget {
  static const routeName = '/help-support';
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = ApiRepository();
  final _formKey = GlobalKey<FormState>();

  final _subject = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _email.text = GetIt.I<AuthBloc>().state.user?.email ?? '';
  }

  @override
  void dispose() {
    _subject.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  String get _userName {
    final u = GetIt.I<AuthBloc>().state.user;
    final n = '${u?.firstName ?? ''} ${u?.lastName ?? ''}'.trim();
    return n.isEmpty ? (u?.username ?? '') : n;
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _submitting = true);
    final content = [
      if (_subject.text.trim().isNotEmpty) 'Subject: ${_subject.text.trim()}',
      if (_phone.text.trim().isNotEmpty) 'Phone: ${_phone.text.trim()}',
      '',
      _message.text.trim(),
    ].join('\n');

    final res = await _repository.contactAdmin(content, email: _email.text.trim());
    if (!mounted) return;
    setState(() => _submitting = false);

    if (res.isSuccessful) {
      showDialog(
        context: App.navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (c) => AppSuccessDialog(
          title: 'Message sent successfully',
          message:
              'Your support request has been submitted. An administrator will get back to you shortly.',
          buttonLabel: 'Back to Courses',
          onButton: () {
            Navigator.of(c).pop();
            App.navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => const CoursesHubPage()),
            );
          },
        ),
      );
    } else {
      final message = res.body is ApiError
          ? (res.body as ApiError?)?.message ?? 'Could not send your message.'
          : (res.error is ErrorModel
              ? (res.error as ErrorModel).message
              : 'Could not send your message.');
      AppDialog.buildErrorDialog(App.navigatorKey.currentContext!, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Help & Support',
              subtitle: 'Send a message to your administrator',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppTokens.screenPadding, 16, AppTokens.screenPadding, 24),
                  children: [
                    Text('Contact Support',
                        style: AppTokens.manrope(
                            size: 22,
                            weight: 700,
                            color: AppTokens.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                        'Tell us what you need help with and we will get back to you.',
                        style: AppTokens.manrope(
                            size: 13,
                            weight: 400,
                            color: AppTokens.textSecondary)),
                    const SizedBox(height: 20),
                    _Label('User'),
                    _ReadOnlyField(value: _userName),
                    const SizedBox(height: 16),
                    _Label('Helpdesk Subject'),
                    _Field(
                      controller: _subject,
                      hint: 'Enter the subject of your request',
                      validator: (v) => (v?.trim().isNotEmpty == true)
                          ? null
                          : 'Please enter a subject',
                    ),
                    const SizedBox(height: 16),
                    _Label('Email'),
                    _Field(
                      controller: _email,
                      hint: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v?.trim().isNotEmpty == true)
                          ? null
                          : 'Please enter your email',
                    ),
                    const SizedBox(height: 16),
                    _Label('Phone Number'),
                    _Field(
                      controller: _phone,
                      hint: '+234',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _Label('Message'),
                    _Field(
                      controller: _message,
                      hint: 'Describe how we can help you…',
                      minLines: 4,
                      maxLines: 8,
                      validator: (v) => (v?.trim().isNotEmpty == true)
                          ? null
                          : 'Please enter a message',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.primary,
                          disabledBackgroundColor: AppTokens.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text('Submit',
                                style: AppTokens.manrope(
                                    size: 15,
                                    weight: 600,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTokens.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: Text('Cancel',
                            style: AppTokens.manrope(
                                size: 15,
                                weight: 600,
                                color: AppTokens.primary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: AppTokens.manrope(
              size: 14, weight: 600, color: AppTokens.textPrimary)),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  const _ReadOnlyField({required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFEC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.border),
      ),
      child: Text(value,
          style: AppTokens.manrope(
              size: 14, weight: 500, color: AppTokens.textPrimary)),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _Field({
    required this.controller,
    required this.hint,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTokens.manrope(
          size: 14, weight: 400, color: AppTokens.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTokens.manrope(
            size: 13, weight: 400, color: AppTokens.placeholder),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTokens.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTokens.statusNotStarted),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTokens.statusNotStarted),
        ),
      ),
    );
  }
}
