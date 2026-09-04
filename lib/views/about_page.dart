import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/constants/env.dart';

/// About (Figma 16): static information about the app.
class AboutPage extends StatefulWidget {
  static const routeName = '/about_page';
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _appVersion = '1.0.0';
  static const _description =
      'Tangerine365 is a learning management platform that helps you access '
      'courses, develop valuable skills, and track your learning progress '
      'conveniently from your mobile device.\n\n'
      'Explore recommended courses, complete lessons, earn certificates and '
      'badges, stay informed through communications, and receive support '
      'whenever you need it.';

  @override
  Widget build(BuildContext context) {
    final title = GetIt.I<Env>().appTitle.toUpperCase();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: NavDrawer(),
      bottomNavigationBar: const AppBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'About',
              subtitle: 'About your learning application',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 40, AppTokens.screenPadding, 24),
                children: [
                  Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTokens.manrope(
                          size: 32,
                          weight: 700,
                          color: AppTokens.primary,
                          letterSpacing: 6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Learning made accessible',
                      style: AppTokens.manrope(
                          size: 15,
                          weight: 400,
                          color: AppTokens.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTokens.lightGreen,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'App Version: $_appVersion',
                        style: AppTokens.manrope(
                            size: 15, weight: 600, color: AppTokens.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    _description,
                    style: AppTokens.manrope(
                        size: 15,
                        weight: 400,
                        height: 24,
                        color: AppTokens.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFDDE2DA)),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Powered by Tangerine365',
                      style: AppTokens.manrope(
                          size: 15, weight: 700, color: AppTokens.primary),
                    ),
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
