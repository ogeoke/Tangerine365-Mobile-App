class AppUrls {
  static const login = 'auth/authenticate'; // legacy (unused; see authenticate)

  // Tangerine365 Enterprise auth + 2FA (used by TwoFactorApi, which prefixes the
  // base URL itself — so these carry the full `api/` path).
  static const authenticate = 'api/auth/authenticate';
  static const init2fa = 'api/twofa/init2fa';
  static const verify2fa = 'api/twofa/verify2fa';
  static const resend2fa = 'api/twofa/resend2fa';
  static const verify2faSetup = 'api/twofa/verify2fasetup';
  static const get2faConfig = 'api/twofa/get2FAConfig';

  // Data endpoints — the Chopper ApiClient base already appends `/api`, so these
  // stay un-prefixed (base + path => .../api/<path>).
  static const subscribe = 'course/addUserSubscription';
  static const sendSupport = 'auth/sendSupport';
  static const banners = 'app/banners';
  static const assignedCourses = 'user/userCourses';
  static const recentlyViewed = 'user/recentlyViewed';
  static const courseList = 'course/courses';
  static const courseInfo = 'course/course';
  static const catalogue = 'course/courses';
  static const selfEnrollment = 'user/myCourseList';
  static const recommended = 'user/recommended';
  static const searchCourse = 'course/searchCourseList';
  static const courseItem = 'course/getlo';
  static const categoryList = 'course/categories';
  static const search = 'course/searchCourseList';
  static const learningObj = 'course/getlo';
  static const userSubscription = 'course/addUserSubscription';
  static const subscribeWithCode = 'course/subscribeUserWithCode';
  static const unsubscribeUser = 'course/unsubscribe';
  static const recommendedCourses = 'user/recommended';
  static const rececentlyViewed = 'user/recentlyViewed';
  static const statistics = 'user/userStats';
  static const settings = 'app/settings';
  static const courseProgressPercentage = 'course/courseProgressPercentage';
  static const courseProgress = 'course/courseProgressPercentage';
  static const userProfile = 'user/userdetailsbyuserid';
  static const webpages = 'webpages/index';
  static const faq = "https://learningzone.fcmb.com/www/web/faq_web.php";
}
