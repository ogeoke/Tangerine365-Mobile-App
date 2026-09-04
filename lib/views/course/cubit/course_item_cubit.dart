import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/course_item.dart';
import 'package:sevenup_mobile/models/course_progress.dart';

part 'course_item_state.dart';

class CourseItemCubit extends Cubit<CourseItemState> {
  final String courseId;
  CourseItemCubit(this.courseId) : super(const CourseItemState());

  final _repository = ApiRepository();

  reset() {
    emit(const CourseItemState());
  }

  load() async {
    emit(state.copyWith(isLoading: true));

    final response = await _repository.getCourseItem(courseId);
    if (response.body is List<CourseItem>) {
      emit(state.copyWith(data: response.body));
    }

    emit(state.copyWith(isLoading: false));
  }

  loadPercentage() async {
    emit(state.copyWith(isLoading: true));

    final response = await _repository.progress(courseId);
    if (response.body is CourseProgress) {
      emit(state.copyWith(progress: response.body));
    }

    emit(state.copyWith(isLoading: false));
  }
}
