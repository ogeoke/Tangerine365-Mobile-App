part of 'course_cubit.dart';

class CourseState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final List<AssignedCourse>? myCourses;
  final List<Course>? courses;
  final List<Course>? search;
  final List<Course>? selfEnrollment;
  final List<Course>? recentlyViewed;
  final Recomended? recomended;

  const CourseState(
      {this.recomended,
      this.selfEnrollment,
      this.isLoading = false,
      this.hasError = false,
      this.courses,
      this.search,
      this.recentlyViewed,
      this.myCourses});

  /// My Courses as the learner should see them: only real enrolments. Courses
  /// whose request is still awaiting admin approval are excluded until the
  /// admin approves them. (The raw [myCourses] is still used by the catalogue
  /// to show those courses as "Waiting".)
  List<Course>? get enrolledCourses => myCourses
      ?.map((e) => e.course)
      .where((c) => !c.isAwaitingApproval)
      .toList();

  @override
  List<Object?> get props => [
        isLoading,
        hasError,
        selfEnrollment,
        myCourses,
        courses,
        recomended,
        recentlyViewed,
        search
      ];

  CourseState copyWith(
      {bool? isLoading,
      bool? hasError,
      List<AssignedCourse>? myCourses,
      List<Course>? courses,
      List<Course>? search,
      List<Course>? recentlyViewed,
      Recomended? recomended,
      List<Course>? selfEnrollment}) {
    return CourseState(
      isLoading: isLoading ?? false,
      hasError: hasError ?? this.hasError,
      myCourses: myCourses ?? this.myCourses,
      search: search ?? this.search,
      courses: courses ?? this.courses,
      recomended: recomended ?? this.recomended,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      selfEnrollment: selfEnrollment ?? this.selfEnrollment,
    );
  }
}
