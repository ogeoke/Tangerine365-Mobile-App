import 'package:flutter/material.dart';

/// Navigation conventions for the approved Tangerine365 flow.
///
/// - The Home screen has **no** side-menu icon; the menu appears only on
///   module screens (Courses Hub and its feature screens).
/// - The side menu is a standard [Drawer]: opening it overlays the current
///   screen, and closing it (the `×` icon → [Navigator.pop]) returns the user
///   to the exact screen they were on. Do not route the close action to Home.
/// - Module feature screens' back buttons return to the Courses Hub, except for
///   onboarding/login/OTP, modal dismissals, menu close, and any nested flow
///   where the approved prototype specifies a different destination.
class AppNav {
  AppNav._();

  /// Canonical Courses Hub route (wired in [AppRouter] when the hub is built).
  static const String coursesHubRoute = '/courses';

  /// Standard back behavior for module feature screens.
  static void backToCoursesHub(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      coursesHubRoute,
      (route) => route.isFirst,
    );
  }

  /// Closes the side menu, returning to the screen it was opened over.
  static void closeMenu(BuildContext context) => Navigator.of(context).pop();
}
