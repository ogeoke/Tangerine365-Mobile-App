import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/views/bank_forms_page.dart';
import 'package:sevenup_mobile/views/forex_rates_page.dart';
import 'package:sevenup_mobile/views/loan_calculator_page.dart';

/// Banking Tools hub (Figma 19A) — entry screen for the module. Three features:
/// Forex & Rates, Forms, and the (fully functional) Loan Calculator.
class BankingToolsPage extends StatelessWidget {
  static const routeName = '/banking-tools';
  const BankingToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Banking Tools',
              subtitle: 'Rates, forms and financial calculators',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 20, AppTokens.screenPadding, 24),
                children: [
                  Text('TOOLS',
                      style: AppTokens.manrope(
                          size: 13,
                          weight: 700,
                          color: AppTokens.primary,
                          letterSpacing: 0.6)),
                  const SizedBox(height: 6),
                  Text('What would you like to do?',
                      style: AppTokens.manrope(
                          size: 30,
                          weight: 700,
                          color: AppTokens.textPrimary)),
                  const SizedBox(height: 10),
                  Text(
                    'Access current rates, download bank forms or estimate loan '
                    'repayments.',
                    style: AppTokens.manrope(
                        size: 15,
                        weight: 400,
                        height: 22,
                        color: AppTokens.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  _ToolCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Forex & Rates',
                    description:
                        'View FX, deposits, Eurobonds and Treasury Bills.',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ForexRatesPage())),
                  )
                      .animate()
                      .fadeIn(duration: 360.ms)
                      .slideY(
                          begin: 0.10,
                          end: 0,
                          duration: 360.ms,
                          curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  _ToolCard(
                    icon: Icons.description_rounded,
                    title: 'Forms',
                    description:
                        'Browse categories and download bank-supplied files.',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const BankFormsPage())),
                  )
                      .animate(delay: 90.ms)
                      .fadeIn(duration: 360.ms)
                      .slideY(
                          begin: 0.10,
                          end: 0,
                          duration: 360.ms,
                          curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  _ToolCard(
                    icon: Icons.calculate_rounded,
                    title: 'Loan Calculator',
                    description:
                        'Estimate monthly repayment and total interest.',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const LoanCalculatorPage())),
                  )
                      .animate(delay: 180.ms)
                      .fadeIn(duration: 360.ms)
                      .slideY(
                          begin: 0.10,
                          end: 0,
                          duration: 360.ms,
                          curve: Curves.easeOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTokens.border),
          ),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTokens.lightGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTokens.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTokens.manrope(
                            size: 22,
                            weight: 700,
                            color: AppTokens.textPrimary)),
                    const SizedBox(height: 8),
                    Text(description,
                        style: AppTokens.manrope(
                            size: 14,
                            weight: 400,
                            height: 20,
                            color: AppTokens.textSecondary)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Open',
                            style: AppTokens.manrope(
                                size: 15,
                                weight: 700,
                                color: AppTokens.primary)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward,
                            color: AppTokens.primary, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
