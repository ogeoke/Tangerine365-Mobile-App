import 'package:data_repository/data_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/data/api.dart';
import 'package:sevenup_mobile/models/assigned_course.dart';
import 'package:sevenup_mobile/models/banners.dart';
import 'package:sevenup_mobile/models/course_item.dart';
import 'package:sevenup_mobile/models/course_progress.dart';
import 'package:sevenup_mobile/models/recomended.dart';
import 'package:sevenup_mobile/models/settings.dart';
import 'package:sevenup_mobile/state/auth/index.dart';

import '../models/categories.dart';
import '../models/course.dart';
import '../models/faq.dart';
import '../models/stats.dart';
import '../models/test.dart';
import '../models/unit.dart';
import '../models/user.dart';

class ApiRepository extends DataRepository {
  final _api = Api();

  ApiRepository()
      : super(GetIt.I<LocalRepository>(), GetIt.I<RemoteRepository>());

  Future<ApiResponse<User, User>> login({
    String? username,
    String? password,
  }) async {
    return await handleRequest(
      _api.login({"username": username, "password": password}),
      timeout: 100,
    );
  }

  Future<ApiResponse<Map<String, dynamic>, Map<String, dynamic>>>
      logout() async {
    return await handleRequest(_api.logout());
  }

  Future<ApiResponse<List<Categories>, Categories>> getCategories() async {
    return await handleRequest(
      _api.categories(),
      cache: CacheDescription(
        'app_categories',
        lifeSpan: CacheDescription.oneHour,
      ),
    );
  }

  // Future<ApiResponse<List<Course>, Course>> getCourses(
  //     String categoryId) async {
  //   return await handleRequest(_api.courses(categoryId));
  // }

  Future<ApiResponse<List<AssignedCourse>, AssignedCourse>>
      getMyCourses() async {
    return await handleRequest(_api.myCourses());
  }

  Future<ApiResponse<List<CourseItem>, CourseItem>> getCourseItem(
    String id,
  ) async {
    return await handleRequest(_api.getCourseItem(id));
  }

  Future<ApiResponse<List<Course>, Course>> loadRecentlyViewedCourses() async {
    return await handleRequest(_api.loadRecentlyViewedCourses());
  }

  Future<ApiResponse<List<Course>, Course>> searchCouse(String query) async {
    return await handleRequest(_api.search(query));
  }

  Future<ApiResponse<List<Banners>, Banners>> getBanners(
    bool forceCache,
  ) async {
    return await handleRequest(
      _api.getBanners(),
      cache: CacheDescription(
        'repository_banners',
        overrideTime: forceCache,
        lifeSpan: CacheDescription.oneHour,
      ),
    );
  }

  Future<ApiResponse<Recomended, Recomended>> getRecommended() async {
    return await handleRequest(_api.getRecomended());
  }

  Future<ApiResponse<List<Course>, Course>> courses(
    int page,
    String? id,
  ) async {
    return await handleRequest(_api.courses(page, id));
  }

  Future<ApiResponse<List<Course>, Course>> selfEnrollment() async {
    return await handleRequest(_api.selfEnrollment());
  }

  Future<ApiResponse<Settings, Settings>> settings(bool forceCache) async {
    return await handleRequest(
      _api.settings(),
      cache: CacheDescription(
        'repository_sesttings',
        invalidateCache: !forceCache,
        overrideTime: forceCache,
        lifeSpan: CacheDescription.oneHour,
      ),
    );
  }

  Future<ApiResponse<CourseProgress, CourseProgress>> progress(
    String courseId,
  ) async {
    return await handleRequest(_api.progress(courseId));
  }

  // Future<ApiResponse<List<Course>, Course>> getLessons(
  //     String courseId) async {
  //   return await handleRequest(_api.lessons(courseId));
  // }

  Future<ApiResponse<Map<String, dynamic>, Map<String, dynamic>>> contactAdmin(
    String message, {
    String? email,
  }) async {
    return await handleRequest(
      _api.contact({
        'content': message,
        'useremail': (email != null && email.isNotEmpty)
            ? email
            : (GetIt.I<AuthBloc>().state.user?.email ?? ''),
        'username': GetIt.I<AuthBloc>().state.user?.username ?? '',
      }),
    );
  }

  Future<ApiResponse<Map<String, dynamic>, Map<String, dynamic>>> subscribe(
    String courseId,
  ) async {
    return await handleRequest(
      _api.subscribe({
        'user_level': 'student',
        'course_id': courseId,
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
      }),
    );
  }

  Future<ApiResponse<Map<String, dynamic>, Map<String, dynamic>>> activateKey(
    String key,
  ) async {
    return await handleRequest(
      _api.activateKey({
        'reg_code': key,
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
      }),
    );
  }

  Future<ApiResponse<Stats, Stats>> getStats() async {
    return await handleRequest(_api.stats());
  }

  Future<ApiResponse<List<Unit>, Unit>> getUnits(String lessonId) async {
    return await handleRequest(_api.units(lessonId));
  }

  Future<ApiResponse<List<Test>, Test>> getTests(String lessonId) async {
    return await handleRequest(_api.tests(lessonId));
  }

  Future<ApiResponse<List<Faq>, Faq>> getFaq(bool useCache) async {
    return await handleRequest(
      _api.getFaq(),
      cache: CacheDescription(
        'app_faq11',
        lifeSpan: CacheDescription.oneDay,
        invalidateCache: !useCache,
      ),
    );
  }

  Future<ApiResponse<Map<String, dynamic>, Map<String, dynamic>>>
      getKnowledgeRepo(bool useCache) async {
    return await handleRequest(
      _api.getKnoledgeRepo(),
      cache: CacheDescription(
        'knowledge_repo',
        lifeSpan: CacheDescription.oneDay,
      ),
    );
  }
}
