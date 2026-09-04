import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/constants/pref_keys.dart';
import 'package:sevenup_mobile/data/sharedpref_manager.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'dashboard_page.dart';

/// Approved five-screen onboarding (Figma 00P1–00P5). Routes to the
/// authentication guard (DashboardPage → LoginPage when unauthenticated).
class OnboardinScreen extends StatefulWidget {
  static const routeName = '/onboarding';

  const OnboardinScreen({super.key});
  @override
  OnboardinScreenState createState() => OnboardinScreenState();
}

class _Slide {
  final String title;
  final String message;
  final String asset;
  const _Slide(
      {required this.title, required this.message, required this.asset});
}

class OnboardinScreenState extends State<OnboardinScreen> {
  late final PageController _pageController;
  int _current = 0;

  static const List<_Slide> _slides = [
    _Slide(
      title: 'My Courses',
      message:
          'Access interactive e-learning courses and assessments wherever you are.',
      asset: 'assets/svg/onboarding_my_courses.svg',
    ),
    _Slide(
      title: 'Track Performance',
      message:
          'View your learning activity, track course progress, and monitor your performance.',
      asset: 'assets/svg/onboarding_track_performance.svg',
    ),
    _Slide(
      title: 'Contact Admin',
      message:
          'Get the support you need by messaging your administrator directly.',
      asset: 'assets/svg/onboarding_contact_admin.svg',
    ),
    _Slide(
      title: 'Subscription Code',
      message:
          'Enter your subscription code to activate access to assigned courses.',
      asset: 'assets/svg/onboarding_subscription_code.svg',
    ),
    _Slide(
      title: 'Biometrics',
      message:
          'Log in quickly and securely using fingerprint or facial authentication.',
      asset: 'assets/svg/onboarding_biometrics.svg',
    ),
  ];

  bool get _isLast => _current == _slides.length - 1;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await SharedPreferenceManager().setBoolData(PrefKeys.firstOpen, false);
    if (GetIt.I<AuthBloc>().state is AuthenticationUninitialized) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, DashboardPage.routeName);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (c, index) =>
                    _OnboardingSlide(slide: _slides[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _finish,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Text(
                        'Skip',
                        style: AppTokens.manrope(
                          size: 15,
                          weight: 500,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _slides.length,
                    effect: const WormEffect(
                      spacing: 6,
                      dotWidth: 8,
                      dotHeight: 8,
                      radius: 8,
                      activeDotColor: AppTokens.primary,
                      dotColor: AppTokens.lightGreen,
                    ),
                    onDotClicked: (page) => _pageController.animateToPage(
                      page,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuad,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _next,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isLast ? 'Get Started' : 'Next',
                            style: AppTokens.manrope(
                              size: 15,
                              weight: 600,
                              color: AppTokens.primary,
                            ),
                          ),
                          if (!_isLast)
                            const Padding(
                              padding: EdgeInsets.only(left: 2),
                              child: Icon(Icons.chevron_right,
                                  size: 20, color: AppTokens.primary),
                            ),
                        ],
                      ),
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

class _OnboardingSlide extends StatelessWidget {
  final _Slide slide;
  const _OnboardingSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 3),
          SvgPicture.asset(
            slide.asset,
            height: 300,
            fit: BoxFit.contain,
          ),
          const Spacer(flex: 2),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppTokens.manrope(
              size: 32,
              weight: 700,
              color: AppTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            slide.message,
            textAlign: TextAlign.center,
            style: AppTokens.manrope(
              size: 15,
              weight: 400,
              height: 24,
              color: AppTokens.textSecondary,
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}
