import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/assigned_course.dart';
import 'package:sevenup_mobile/models/categories.dart';
import 'package:sevenup_mobile/models/course.dart';
import 'package:sevenup_mobile/models/recomended.dart';

part 'course_state.dart';

class MyCourseCubit extends CourseCubit {
  MyCourseCubit();
}

class RecentlyViewedCourseCubit extends CourseCubit {
  RecentlyViewedCourseCubit();
}

class SelfEnrollmentViewedCourseCubit extends CourseCubit {
  SelfEnrollmentViewedCourseCubit();
}

class RecommendedCourseCubit extends CourseCubit {
  RecommendedCourseCubit();
}

class SearchCourseCubit extends CourseCubit {
  SearchCourseCubit();
}

class CourseCubit extends Cubit<CourseState> {
  CourseCubit() : super(const CourseState());

  final _repository = ApiRepository();

  reset() {
    emit(const CourseState());
  }

  search(String query) async {
    emit(state.copyWith(isLoading: true));

    final response = await _repository.searchCouse(query);
    if (response.body is List<Course>) {
      emit(state.copyWith(search: response.body));
    }

    emit(state.copyWith(isLoading: false));
  }

  loadCourses() async {
    emit(state.copyWith(isLoading: true, hasError: false));

    final response = await _repository.getMyCourses();
    if (response.body is List<AssignedCourse>) {
      emit(state.copyWith(myCourses: response.body, hasError: false));
    } else {
      emit(state.copyWith(hasError: true));
    }

    emit(state.copyWith(isLoading: false));
  }

  loadRecentlyViewedCourses() async {
    emit(state.copyWith(isLoading: true));

    final response = await _repository.loadRecentlyViewedCourses();
    if (response.body is List<Course>) {
      emit(state.copyWith(recentlyViewed: response.body));
    }

    emit(state.copyWith(isLoading: false));
  }

  selfEnrollment() async {
    emit(state.copyWith(isLoading: true));

    final response = await _repository.selfEnrollment();
    if (response.body is List<Course>) {
      emit(state.copyWith(selfEnrollment: response.body));
    }

    emit(state.copyWith(isLoading: false));
  }

  loadCatalogue(Categories? category) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    final response = await _repository.courses(1, category?.id);
    if (response.body is List<Course>) {
      emit(state.copyWith(courses: response.body, hasError: false));
    } else {
      emit(state.copyWith(hasError: true));
    }

    emit(state.copyWith(isLoading: false));
  }

  loadRecomended() async {
    emit(state.copyWith(isLoading: true));

    final response = await _repository.getRecommended();
    if (response.body is Recomended) {
      emit(state.copyWith(recomended: response.body));
    }

    emit(state.copyWith(isLoading: false));
  }
}
