// import 'package:built_collection/built_collection.dart';
// import 'package:sevenup_mobile/models/course.dart';

// import '../data/api_repository.dart';
// import 'my_provider.dart';

// class CoursesProvider extends MyProvider {
//   final String courseId;
//   List<Course>? course;
//   final bool isLesson;
//   bool isLoading = true;
//   final _repository = ApiRepository();

//   CoursesProvider(this.courseId, {this.isLesson = false});

//   @override
//   Future<void> onRefresh() async {
//     useCache = false;
//     loadCourses();
//   }

//   Future<void> loadCourses() async {
//     isLoading = true;
//     notifyListeners();
//     // print('refreshing courses');
//     final response = isLesson
//         ? await _repository.getLessons(courseId)
//         : await _repository.getCourses(courseId);
//     // log('CoursesProvider', course, response?.body );
//     if (response.body is List<Course>) course = response.body;
//     refreshController.refreshCompleted();
//     isLoading = false;
//     notify(course);
//   }
// }
