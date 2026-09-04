///created by Wisdom Ekeh ekeh.wisdom@gmail.com
///c 2020 Wed Jan 22
library;

import 'package:sevenup_mobile/state/settings/settings_cubit.dart';
import 'package:sevenup_mobile/utils/simple_bloc_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'common/theme.dart';
import 'constants/env.dart';
import 'di.dart';
import 'services/app_router.dart';
import 'services/klogger.dart';
import 'views/maintenance_mode_view.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KLogger.setupLogging();
  await DI.setUp();
  Bloc.observer = SimpleBlocDelegate();
  runApp(DI.providers(const App()));
}

class App extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    var env = GetIt.I<Env>();
    return GestureDetector(
        onTap: () {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: env.appTitle,
          theme: AppTheme.data,
          initialRoute: '/',
          navigatorKey: navigatorKey,
          builder: (c, w) =>
              context.watch<SettingsCubit>().state.data?.maintenanceMode ==
                      'true'
                  ? const MaintenaceModeScreen()
                  : Stack(
                      children: <Widget>[w!, const SizedBox.expand()],
                    ),
          home: const SplashScreen(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ));
  }
}
