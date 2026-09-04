import 'package:data_repository/data_repository.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:sevenup_mobile/state/settings/settings_cubit.dart';
import 'package:sevenup_mobile/views/course/cubit/category_cubit.dart';
import 'package:sevenup_mobile/views/course/cubit/course_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'constants/env.dart';
import 'data/local/hive_repository.dart';
import 'views/course/cubit/banner_cubit.dart';

/// dependency injection class
class DI {
  static Future<void> setUp() async {
    // initialize hive database
    // await Hive.initFlutter();

    // HttpOverrides.global = MyHttpOverrides();
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    GetIt getIt = GetIt.I;

    getIt.registerSingleton<RemoteRepository>(
        RemoteRepository(HttpApiProvider(), 'An error occured'));
    getIt.registerSingleton<LocalRepository>(HiveRepository());
    getIt.registerSingleton<Env>(kDebugMode ? Production() : Production());
    getIt.registerSingleton<AuthBloc>(AuthBloc());
    getIt<AuthBloc>().add(AppStarted());

    await GetIt.instance.allReady();

    // var env = getIt.get<Env>();
  }

  static Widget providers(Widget child) => MultiProvider(
        providers: [
          BlocProvider(create: (_) => GetIt.I<AuthBloc>()),
          BlocProvider(create: (_) => CourseCubit()),
          // BlocProvider(create: (_) => RecentlyViewedCourseCubit()),
          // BlocProvider(create: (_) => SelfEnrollmentViewedCourseCubit()),
          // BlocProvider(create: (_) => RecommendedCourseCubit()),
          // BlocProvider(create: (_) => SearchCourseCubit()),
          BlocProvider(create: (_) => CategoryCubit()),
          BlocProvider(create: (_) => SettingsCubit()),
          BlocProvider(create: (_) => BannerCubit()..load()),
          // ChangeNotifierProvider(create: (c) => CourseCubit()),
        ],
        child: child,
      );
}
