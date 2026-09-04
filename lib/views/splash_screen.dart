import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/constants/pref_keys.dart';
import 'package:sevenup_mobile/data/sharedpref_manager.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/main.dart';
import 'package:sevenup_mobile/services/app_router.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:sevenup_mobile/state/settings/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_page.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashAScreenState createState() => SplashAScreenState();
}

class SplashAScreenState extends State<SplashScreen> {
  @override
  void initState() {
    GetIt.I<AuthBloc>().add(AppStarted());
    _gotToPage();
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    context.read<SettingsCubit>().load();
  }

  _gotToPage() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(
        const Duration(milliseconds: 1000),
      );
      bool firstOpen =
          await SharedPreferenceManager().getBoolData(PrefKeys.firstOpen, true);
      if (GetIt.I<AuthBloc>().state is AuthenticationUninitialized) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // ignore: use_build_context_synchronously
      App.navigatorKey.currentState?.pushReplacement(FadeRoute(
          page: firstOpen ? const OnboardinScreen() : const DashboardPage(),
          // ignore: use_build_context_synchronously
          settings: ModalRoute.of(context)!.settings));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Approved Tangerine splash: green topographic texture background with the
    // white Tangerine365 logo centered. See design/figma_export 00P0.
    return Material(
      color: AppTokens.primary,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_texture.png',
            fit: BoxFit.cover,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: SizedBox(
                width: 240,
                child: Image.asset('assets/images/tangerine_logo_white.png')
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scaleXY(delay: 200.ms, begin: .92, end: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
