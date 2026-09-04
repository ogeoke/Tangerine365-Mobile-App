import 'package:data_repository/data_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'course_action_state.dart';

class CourseActionCubit extends Cubit<CourseActionState> {
  CourseActionCubit() : super(CourseActionInitial());

  final _repository = ApiRepository();

  subscribe(String id) async {
    emit(CourseActionLoading());

    final response = await _repository.subscribe(id);
    if (response.isSuccessful) {
      emit(CourseActionSuccess());
    } else {
      emit(CourseActionError(response.error as ApiError));
    }
  }
}
