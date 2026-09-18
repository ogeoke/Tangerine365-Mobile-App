/// a manifest for all static string resource
class AppStrings {
  static const contactMessage =
      'You can contact an admin in the event that you need support or assistance using the system or you\'re experiencing any technical issues.';
  static const aboutMessage =
      'SABI learn is an all-in-one mobile learning platform that was designed to give users a fascinating learning experience by giving them access to acquire and share knowledge at their own pace, anytime, anywhere, and most importantly on-the-go. As an organization, it gives our staff round-the-clock access to training and learning materials.';
  static const multipleLogins =
      'You are not authorized. \n Simultaneous logins on multiple mobile devices not allowed';

  /// Shown when a request returns 401 — the session is no longer valid, which
  /// can mean it expired, or was ended by signing in on another device. Neutral
  /// wording avoids the misleading "simultaneous logins" claim for plain
  /// expiries.
  static const sessionEnded =
      'Your session has ended. Please sign in again.';
}
