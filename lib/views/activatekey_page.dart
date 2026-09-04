import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/contact_form.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';

/// Approved Subscription Code screen (Figma 09). Presentation only — the code
/// submission (ContactForm → activateKey) is unchanged.
class ActivateKeyPage extends StatelessWidget {
  static const routeName = '/activate_page';
  const ActivateKeyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: NavDrawer(),
      bottomNavigationBar: const AppBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Subscription Code',
              subtitle: 'Activate learning access with your code',
              onMenu: () => scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 12, AppTokens.screenPadding, 32),
                children: [
                  SvgPicture.asset(
                    'assets/svg/onboarding_subscription_code.svg',
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your subscription code',
                    textAlign: TextAlign.center,
                    style: AppTokens.manrope(
                      size: 22,
                      weight: 700,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the code provided by your administrator to activate access.',
                    textAlign: TextAlign.center,
                    style: AppTokens.manrope(
                      size: 13,
                      weight: 400,
                      height: 20,
                      color: AppTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Working submission logic (activateKey) is preserved.
                  const ContactForm(
                    showGroupKey: true,
                    showMessage: false,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
