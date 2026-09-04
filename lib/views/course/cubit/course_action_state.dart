part of 'course_action_cubit.dart';

sealed class CourseActionState extends Equatable {
  final String name;

  const CourseActionState(this.name);

  @override
  List<Object> get props => [name];
}

class CourseActionInitial extends CourseActionState {
  const CourseActionInitial() : super('CourseActionInitial');
}

class CourseActionLoading extends CourseActionState {
  const CourseActionLoading() : super('CourseActionLoading');
}

class CourseActionSuccess extends CourseActionState {
  const CourseActionSuccess() : super('CourseActionSuccess');
}

class CourseActionError extends CourseActionState {
  final ApiError error;
  const CourseActionError(this.error) : super('CourseActionError');
}
