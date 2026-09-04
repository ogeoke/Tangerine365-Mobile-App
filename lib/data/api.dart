import 'package:data_repository/data_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/data/interceptors/auth_interceptor.dart';
import 'package:sevenup_mobile/data/interceptors/token_interceptor.dart';
import 'package:sevenup_mobile/models/assigned_course.dart';
import 'package:sevenup_mobile/models/banners.dart';
import 'package:sevenup_mobile/models/course_item.dart';
import 'package:sevenup_mobile/models/course_progress.dart';
import 'package:sevenup_mobile/models/recomended.dart';
import 'package:sevenup_mobile/models/settings.dart';
import 'package:sevenup_mobile/models/stats.dart';
import 'package:sevenup_mobile/models/unit.dart';
import 'package:sevenup_mobile/models/user.dart';
import 'package:sevenup_mobile/state/auth/auth_bloc.dart';

import '../constants/app_urls.dart';
import '../models/categories.dart';
import '../models/course.dart';
import '../models/error_model/error_model.dart';
import '../models/faq.dart';
import '../models/test.dart';
import 'api_client.dart';
import 'interceptors/json_interceptor.dart';

class Api {
  ApiRequest<Map<String, dynamic>, Map<String, dynamic>> getKnoledgeRepo() {
    return ApiClient.baseRequest<Map<String, dynamic>, Map<String, dynamic>>()
        .copyWith(
      baseUrl: 'https://learning.sevenup.org/www',
      path: 'web/knowledge.php',
      method: ApiMethods.get,
      dataKey: 'data',
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<Map<String, dynamic>, Map<String, dynamic>> getResource(
    String id,
  ) {
    return ApiClient.baseRequest<Map<String, dynamic>, Map<String, dynamic>>()
        .copyWith(
      path: id,
      method: ApiMethods.get,
      dataKey: 'data',
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<List<Faq>, Faq> getFaq() {
    return ApiClient.baseRequest<List<Faq>, Faq>().copyWith(
      path: "webpages/index",
      method: ApiMethods.get,
      dataKey: 'data',
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<User, User> login(Map<String, dynamic> body) {
    return ApiClient.baseRequestNoAuth<User, User>().copyWith(
      path: AppUrls.login,
      body: body,
      method: ApiMethods.post,
      dataKey: 'data',
      isMultipart: true,
      error: ErrorDescription(key: ''),
      interceptors: [JsonInterceptor<ErrorModel>(), TokenInterceptor()],
    );
  }

  ApiRequest<List<Course>, Course> loadRecentlyViewedCourses() {
    return ApiClient.baseRequest<List<Course>, Course>().copyWith(
      path: AppUrls.rececentlyViewed,
      method: ApiMethods.post,
      dataKey: 'courses',
      isMultipart: true,
      body: {
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
      },
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<Recomended, Recomended> getRecomended() {
    return ApiClient.baseRequest<Recomended, Recomended>().copyWith(
      path: AppUrls.recommended,
      method: ApiMethods.post,
      dataKey: '',
      isMultipart: true,
      body: {
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '', //'133262',/
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
      },
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<List<Banners>, Banners> getBanners() {
    return ApiClient.baseRequest<List<Banners>, Banners>().copyWith(
      path: AppUrls.banners,
      method: ApiMethods.post,
      dataKey: 'data',
      isMultipart: true,
      body: {
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
      },
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<List<Course>, Course> search(String query) {
    return ApiClient.baseRequest<List<Course>, Course>().copyWith(
      path: AppUrls.search,
      method: ApiMethods.post,
      dataKey: 'data',
      isMultipart: true,
      body: {
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
        'key': query,
      },
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<List<Course>, Course> courses(int page, String? id) {
    var q = {
      'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
      'auth': GetIt.I<AuthBloc>().state.token ?? '',
      'limit': 40,
      'page': page,
    };
    if (id != null) {
      q['category'] = id;
    }

    return ApiClient.baseRequest<List<Course>, Course>().copyWith(
      path: AppUrls.catalogue,
      method: ApiMethods.post,
      dataKey: 'courses',
      isMultipart: true,
      body: q,
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<List<Course>, Course> selfEnrollment() {
    return ApiClient.baseRequest<List<Course>, Course>().copyWith(
      path: AppUrls.selfEnrollment,
      method: ApiMethods.post,
      // query: {'category_id': categoryId},
      dataKey: 'coursesForSelfEnrollment',
      isMultipart: true,
      body: {
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
        'limit': 40,
        'page': 1,
      },
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<List<AssignedCourse>, AssignedCourse> myCourses() {
    return ApiClient.baseRequest<List<AssignedCourse>, AssignedCourse>()
        .copyWith(
      path: AppUrls.assignedCourses,
      method: ApiMethods.post,
      body: {
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
      },
      dataKey: 'courses',
      isMultipart: true,
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<Stats, Stats> stats() {
    return ApiClient.baseRequest<Stats, Stats>().copyWith(
      path: AppUrls.statistics,
      method: ApiMethods.post,
      dataKey: 'data',
      body: {
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
      },
      isMultipart: true,
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<List<Unit>, Unit> units(String lessonId) {
    return ApiClient.baseRequest<List<Unit>, Unit>().copyWith(
      path: "units.php",
      method: ApiMethods.get,
      query: {'lesson_id': lessonId},
      dataKey: 'data',
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<List<Test>, Test> tests(String lessonId) {
    return ApiClient.baseRequest<List<Test>, Test>().copyWith(
      path: "tests.php",
      method: ApiMethods.get,
      query: {'lesson_id': lessonId},
      dataKey: 'data',
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<List<Categories>, Categories> categories() {
    return ApiClient.baseRequest<List<Categories>, Categories>().copyWith(
      path: AppUrls.categoryList,
      method: ApiMethods.post,
      dataKey: 'data',
      isMultipart: true,
      body: {'auth': GetIt.I<AuthBloc>().state.token ?? ''},
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<Categories, Categories> getCourseInfo(String courseId) {
    return ApiClient.baseRequest<Categories, Categories>().copyWith(
      path: AppUrls.courseInfo,
      method: ApiMethods.post,
      dataKey: 'course',
      isMultipart: true,
      body: {
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
        'course_id': courseId,
      },
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<List<CourseItem>, CourseItem> getCourseItem(String courseId) {
    return ApiClient.baseRequest<List<CourseItem>, CourseItem>().copyWith(
      path: AppUrls.courseItem,
      method: ApiMethods.post,
      dataKey: 'lo_course',
      isMultipart: true,
      body: {
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
        'course_id': courseId,
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
      },
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<Map<String, dynamic>, Map<String, dynamic>> contact(
    Map<String, String> body,
  ) {
    return ApiClient.baseRequest<Map<String, dynamic>, Map<String, dynamic>>()
        .copyWith(
      path: AppUrls.sendSupport,
      method: ApiMethods.post,
      dataKey: '',
      body: body,
      isMultipart: true,
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<Map<String, dynamic>, Map<String, dynamic>> activateKey(
    Map<String, String> body,
  ) {
    return ApiClient.baseRequest<Map<String, dynamic>, Map<String, dynamic>>()
        .copyWith(
      path: AppUrls.subscribeWithCode,
      method: ApiMethods.post,
      dataKey: '',
      body: {...body, 'auth': GetIt.I<AuthBloc>().state.token ?? ''},
      isMultipart: true,
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<Map<String, dynamic>, Map<String, dynamic>> subscribe(
    Map<String, String> body,
  ) {
    return ApiClient.baseRequest<Map<String, dynamic>, Map<String, dynamic>>()
        .copyWith(
      path: AppUrls.subscribe,
      method: ApiMethods.post,
      dataKey: '',
      body: body,
      isMultipart: true,
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<Map<String, dynamic>, Map<String, dynamic>> logout() {
    return ApiClient.baseRequest<Map<String, dynamic>, Map<String, dynamic>>()
        .copyWith(
      path: 'logout.php',
      method: ApiMethods.post,
      dataKey: '',
      body: {},
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<Map<String, dynamic>, Map<String, dynamic>> postFile(
    List<int> bytes,
  ) {
    return ApiClient.baseRequest<Map<String, dynamic>, Map<String, dynamic>>()
        .copyWith(
      path: 'file.php',
      method: ApiMethods.post,
      dataKey: '',
      isMultipart: true,
      body: {'file': FileFormField(bytes: bytes)},
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<Settings, Settings> settings() {
    return ApiClient.baseRequest<Settings, Settings>().copyWith(
      path: AppUrls.settings,
      method: ApiMethods.post,
      dataKey: 'data',
      body: {},
      isMultipart: true,
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }

  ApiRequest<CourseProgress, CourseProgress> progress(String courseId) {
    return ApiClient.baseRequest<CourseProgress, CourseProgress>().copyWith(
      path: AppUrls.courseProgressPercentage,
      method: ApiMethods.post,
      dataKey: 'data',
      body: {
        'auth': GetIt.I<AuthBloc>().state.token ?? '',
        'course_id': courseId,
        'idst': GetIt.I<AuthBloc>().state.user?.id ?? '',
      },
      isMultipart: true,
      error: ErrorDescription(),
      interceptors: [JsonInterceptor<ErrorModel>(), AuthInterceptor()],
    );
  }
}
