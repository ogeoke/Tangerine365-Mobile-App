import 'package:sevenup_mobile/models/course_item.dart';
import 'package:sevenup_mobile/views/about_page.dart';
import 'package:sevenup_mobile/views/activatekey_page.dart';
import 'package:sevenup_mobile/views/category_page.dart';
import 'package:sevenup_mobile/views/contact_page.dart';
import 'package:sevenup_mobile/views/courses_hub_page.dart';
import 'package:sevenup_mobile/views/courses_page.dart';
import 'package:sevenup_mobile/views/dashboard_page.dart';
import 'package:sevenup_mobile/views/faq_page.dart';
import 'package:sevenup_mobile/views/knowledge_repo.dart';
import 'package:sevenup_mobile/views/login_page.dart';
import 'package:sevenup_mobile/views/my_courses_full_page.dart';
import 'package:sevenup_mobile/views/mystat_page.dart';
import 'package:sevenup_mobile/views/onboarding_screen.dart';
import 'package:sevenup_mobile/views/quick_tour_page.dart';
import 'package:sevenup_mobile/views/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return FadeRoute(page: const SplashScreen(), settings: settings);
      // return FadeRoute(page: DashboardPage(), settings: settings);

      case ContactPage.routeName:
        return MaterialPageRoute(
            builder: (c) => const ContactPage(), settings: settings);

      case ActivateKeyPage.routeName:
        return MaterialPageRoute(
            builder: (c) => const ActivateKeyPage(), settings: settings);

      // case CategoryPage.routeName:
      //   return MaterialPageRoute(
      //       builder: (c) =>
      //           CategoryPage(item: settings.arguments as DashboardItem),
      //       settings: settings);

      // case CoursesPage.routeName:
      //   if (settings.arguments is CourseItem) {
      //     return MaterialPageRoute(
      //         builder: (c) =>
      //             CoursesPage(item: settings.arguments as CourseItem),
      //         settings: settings);
      //   }
      //   break;
      case MyStatPage.routeName:
        return MaterialPageRoute(
            builder: (c) => const MyStatPage(), settings: settings);
      case KnowledgeRepo.routeName:
        return MaterialPageRoute(
            builder: (c) => const KnowledgeRepo(), settings: settings);

      //  case KnowledgeRepoDetails.routeName:
      //   if (settings.arguments is DashboardItem)
      //     return MaterialPageRoute(
      //         builder: (c) => KnowledgeRepoDetails(item: settings.arguments),
      //         settings: settings);
      //   break;
      case FaqPage.routeName:
        return SlideUpRoute(page: const FaqPage(), settings: settings);
      case AboutPage.routeName:
        return SlideUpRoute(page: const AboutPage(), settings: settings);
      case QuickTourPage.routeName:
        return SlideUpRoute(page: const QuickTourPage(), settings: settings);
      case OnboardinScreen.routeName:
        return SlideUpRoute(page: const OnboardinScreen(), settings: settings);
      case LoginPage.routeName:
        String message = '';
        if (settings.arguments is Map) {
          Map m = settings.arguments as Map;
          // print(m);
          message = m['message'];
        }
        return FadeRoute(page: LoginPage(message: message), settings: settings);
      // break;
      // OTP is reached only from LoginPage with a 2FA challenge, not by route.
      case CoursesHubPage.routeName:
        return MaterialPageRoute(
            builder: (c) => const CoursesHubPage(), settings: settings);
      case MyCoursesFullPage.routeName:
        return MaterialPageRoute(
            builder: (c) => const MyCoursesFullPage(), settings: settings);
      default:
        return FadeRoute(page: const DashboardPage(), settings: settings);
    }
    return FadeRoute(page: const DashboardPage(), settings: settings);
  }
}

class SlideUpRoute extends PageRouteBuilder {
  final Widget page;
  @override
  final RouteSettings settings;

  SlideUpRoute({required this.page, required this.settings})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              page,
          settings: settings,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
                  opacity: animation.drive(Tween<double>(
                    begin: 0.5,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeIn))),
                  child: SlideTransition(
                      position: animation.drive(Tween<Offset>(
                        begin: const Offset(0.0, 1.0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.decelerate))),
                      child: child)),
        );
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  @override
  final RouteSettings settings;
  final double beginOpacity;
  FadeRoute(
      {required this.page, required this.settings, this.beginOpacity = 0.5})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          settings: settings,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation.drive(Tween<double>(
              begin: beginOpacity.clamp(0.0, 1.0),
              end: 1.0,
            ).chain(CurveTween(curve: Curves.decelerate))),
            child: child,
          ),
        );
}
