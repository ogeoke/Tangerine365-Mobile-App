import 'package:data_repository/data_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/common/app_dialog.dart';
import 'package:sevenup_mobile/common/success_dialog.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/main.dart';
import 'package:sevenup_mobile/services/alert.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:sevenup_mobile/views/courses_hub_page.dart';

import '../models/error_model/error_model.dart';

/// Shared form for the Subscription Code screen (group key) and Help & Support
/// (message). Presentation matches the approved design; the submission logic
/// (activateKey / contactAdmin) is unchanged.
class ContactForm extends StatefulWidget {
  final bool showTitle;
  final bool showMessage;
  final bool showGroupKey;

  const ContactForm({
    super.key,
    this.showTitle = true,
    this.showMessage = true,
    this.showGroupKey = false,
  });
  @override
  ContactFormState createState() => ContactFormState();
}

class ContactFormState extends State<ContactForm> {
  late TextEditingController _titleController;
  late TextEditingController _groupKeyController;
  late FocusNode _messageFocusNode;
  bool isSubmiting = false;
  final _repository = ApiRepository();
  String text = '';

  void _send() async {
    setState(() {
      isSubmiting = true;
    });
    var res = widget.showGroupKey
        ? await _repository.activateKey(_groupKeyController.text)
        : await _repository.contactAdmin(text);

    if (res.isSuccessful) {
      if (widget.showGroupKey) {
        // Approved subscription-success popup (Figma 09A).
        showDialog(
          context: App.navigatorKey.currentContext!,
          barrierDismissible: false,
          builder: (c) => AppSuccessDialog(
            title: 'Subscription successful',
            message:
                'Your subscription code has been activated successfully. You can now access your assigned courses.',
            buttonLabel: 'Go to Courses',
            onButton: () {
              Navigator.of(c).pop();
              if (mounted) Navigator.of(context).maybePop();
              App.navigatorKey.currentState?.push(
                MaterialPageRoute(builder: (_) => const CoursesHubPage()),
              );
            },
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        Alert.showFormDialog(
          App.navigatorKey.currentContext!,
          title: 'Message Sent',
          barrierDismissible: false,
          message: 'Your message has been sent successfully',
          actions: <Widget>[
            TextButton(
              child: const Text('Got It'),
              onPressed: () {
                App.navigatorKey.currentState?.pop();
              },
            ),
          ],
        );
      }
    } else {
      String message = '';
      if (res.body != null) {
        message = (res.body as ApiError?)?.message ??
            'An unexpected error occured could not send message';
      } else {
        var e = res.error as ErrorModel;
        message = e.message;
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        AppDialog.buildErrorDialog(App.navigatorKey.currentContext!, message);
      });
    }
    if (mounted) {
      setState(() {
        isSubmiting = false;
      });
    }
  }

  @override
  void initState() {
    _titleController = TextEditingController();
    _groupKeyController = TextEditingController();
    _messageFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageFocusNode.dispose();
    _groupKeyController.dispose();
    super.dispose();
  }

  bool get canPop =>
      _groupKeyController.text.isEmpty && _titleController.text.isEmpty;
  bool get isValid => !isSubmiting && text.length > 3;

  InputDecoration _decoration(String hint, {double radius = 12}) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle:
          AppTokens.manrope(size: 13, weight: 400, color: AppTokens.placeholder),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(AppTokens.border),
      disabledBorder: border(AppTokens.border),
      focusedBorder: border(AppTokens.primary, 1.4),
      errorBorder: border(AppTokens.statusNotStarted),
      focusedErrorBorder: border(AppTokens.statusNotStarted),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 16),
        child: Text(
          text,
          style:
              AppTokens.manrope(size: 13, weight: 600, color: AppTokens.fieldLabel),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.showMessage) ...[
                _label('User'),
                TextFormField(
                  controller: TextEditingController(
                    text: GetIt.I<AuthBloc>().state.user?.username ?? '',
                  ),
                  enabled: false,
                  style: AppTokens.manrope(
                      size: 14, weight: 400, color: AppTokens.textPrimary),
                  decoration: _decoration('').copyWith(
                    fillColor: AppTokens.readOnlyField,
                    filled: true,
                  ),
                ),
                _label('Email'),
                TextFormField(
                  controller: TextEditingController(
                    text: GetIt.I<AuthBloc>().state.user?.email ?? '',
                  ),
                  enabled: false,
                  style: AppTokens.manrope(
                      size: 14, weight: 400, color: AppTokens.textPrimary),
                  decoration: _decoration('').copyWith(
                    fillColor: AppTokens.readOnlyField,
                    filled: true,
                  ),
                ),
                _label('Message'),
                TextFormField(
                  focusNode: _messageFocusNode,
                  onChanged: (t) => setState(() => text = t),
                  validator: (text) =>
                      (text?.isNotEmpty == true) ? null : 'Please enter a message',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.newline,
                  minLines: 3,
                  maxLines: 100,
                  style: AppTokens.manrope(
                      size: 14, weight: 400, color: AppTokens.textPrimary),
                  decoration: _decoration('Type your message'),
                ),
              ],
              if (widget.showGroupKey)
                TextFormField(
                  controller: _groupKeyController,
                  onChanged: (t) => setState(() => text = t),
                  validator: (t) => (t?.isNotEmpty == true)
                      ? null
                      : 'Please enter your subscription code',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.go,
                  onFieldSubmitted: (_) => _submit(context),
                  style: AppTokens.manrope(
                      size: 14, weight: 400, color: AppTokens.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Subscription code',
                    hintStyle: AppTokens.manrope(
                        size: 13, weight: 400, color: AppTokens.placeholder),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTokens.subscriptionInputRadius),
                      borderSide: BorderSide(
                          color: AppTokens.primary.withOpacity(0.35)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTokens.subscriptionInputRadius),
                      borderSide:
                          const BorderSide(color: AppTokens.primary, width: 1.4),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTokens.subscriptionInputRadius),
                      borderSide:
                          const BorderSide(color: AppTokens.statusNotStarted),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: AppTokens.subscriptionButtonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTokens.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppTokens.subscriptionButtonRadius),
                    ),
                  ),
                  onPressed: isSubmiting ? null : () => _submit(context),
                  child: isSubmiting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: AppTokens.manrope(
                              size: 15, weight: 600, color: Colors.white),
                        ),
                ),
              ),
              if (!widget.showGroupKey) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: AppTokens.secondaryButtonHeight,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTokens.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppTokens.secondaryButtonRadius),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(
                      'Cancel',
                      style: AppTokens.manrope(
                          size: 15,
                          weight: 600,
                          color: AppTokens.textSecondary),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    if (Form.of(context).validate()) {
      _send();
    }
  }
}
