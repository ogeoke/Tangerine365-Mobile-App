import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/gen/assets.gen.dart';
import 'package:sevenup_mobile/models/faq.dart';
import 'package:flutter/material.dart';

import 'html_builder.dart';

class FaqDetails extends StatelessWidget {
  final Faq faq;
  const FaqDetails({super.key, required this.faq});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      bottomNavigationBar: const AppBottomNav(),
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          primary: true,
          title: Text('Knowledge Repository',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500)),
          leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        child: HtmlBuilder(html: faq.description ?? ''),
      ),
    );
  }
}
