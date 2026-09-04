part of 'course_item_cubit.dart';

class CourseItemState extends Equatable {
  final bool isLoading;
  final List<CourseItem>? data;
  final CourseProgress? progress;

  const CourseItemState({
    this.isLoading = false,
    this.data,
    this.progress,
  });

  @override
  List<Object?> get props => [isLoading, data, progress];

  // double get progress => [...?data].isEmpty
  //     ? 0
  //     : ([...?data]
  //             .map((v) => v.loStatus == true ? 1 : 0)
  //             .reduce((a, b) => a + b)) /
  //         ((data?.length ?? 1));

  CourseItemState copyWith(
      {bool? isLoading, List<CourseItem>? data, CourseProgress? progress}) {
    return CourseItemState(
      isLoading: isLoading ?? false,
      data: data ?? this.data,
      progress: progress ?? this.progress,
    );
  }
}
