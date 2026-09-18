class AppUrls {
  static const login = 'auth/authenticate'; // legacy (unused; see authenticate)

  // Tangerine365 Enterprise auth + 2FA (used by TwoFactorApi, which prefixes the
  // base URL itself — so these carry the full `api/` path).
  static const authenticate = 'api/auth/authenticate';
  static const lostPassword = 'api/auth/lostPassword'; // body: username
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
  static const profile =
      'user/profile'; // POST api/user/profile — extended learner profile
  static const certificates = 'certificates'; // POST api/certificates — list
  static const certificateRender =
      'certificates/render'; // POST api/certificates/render — Fabric.js payload
  static const certificateGenerate =
      'certificates/generate'; // POST: certificate_id + course_id → same data as render
  static const competencies = 'competencies'; // POST api/competencies — attained
  static const leaderboard =
      'gamification/leaderboard'; // POST api/gamification/leaderboard
  static const notificationCounts =
      'notifications/counts'; // POST api/notifications/counts — unread badge
  // Knowledge Repository (POST, body: auth + params)
  static const knowledge = 'knowledge'; // list (page, limit, search, type, category_id, tag_id, featured)
  static const knowledgeSearch = 'knowledge/search'; // q
  static const knowledgeCategories = 'knowledge/categories';
  static const knowledgeTypes = 'knowledge/types';
  static const knowledgeTags = 'knowledge/tags';
  static const knowledgeResource = 'knowledge/getResource'; // knowledgeId
  static const knowledgeRelated = 'knowledge/related'; // knowledgeId
  static const knowledgeAttachments = 'knowledge/attachments'; // knowledgeId
  static const knowledgeDownload = 'api/knowledge/download'; // /{id}, attachmentId
  static const announcements = 'announcements'; // POST api/announcements — list
  static const announcementRead =
      'announcements/read'; // POST api/announcements/read/{id}
  static const communications =
      'communications'; // POST api/communications — list (status filter)
  static const communicationRead =
      'communications/read'; // POST api/communications/read/{id}
  static const messagesInbox = 'messages/inbox'; // POST api/messages/inbox
  static const messagesSent = 'messages/sent'; // POST api/messages/sent
  static const messageDetail =
      'messages/getMessage'; // POST api/messages/getMessage (messageId)
  static const messageRead = 'messages/read'; // POST api/messages/read/{id}
  static const messageReply = 'messages/reply'; // POST api/messages/reply/{id}
  static const webpages = 'webpages/index';
  static const faq = "https://learningzone.fcmb.com/www/web/faq_web.php";
}
