import 'package:sevenup_mobile/common/contact_form.dart';
import 'package:sevenup_mobile/common/page_scaffold.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  static const routeName = '/contact_page';
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
        title: 'Contact Admin',
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 31.0),
          child: SingleChildScrollView(child: ContactForm()),
        ));
  }
}
