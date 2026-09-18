import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sevenup_mobile/common/course_card.dart';
import 'package:sevenup_mobile/models/course.dart';
import 'package:sevenup_mobile/views/course/cubit/course_cubit.dart';
import 'package:shimmer/shimmer.dart';

import 'course/cubit/category_cubit.dart';

class CourseGrid extends StatefulWidget {
  final CourseAction action;
  const CourseGrid({super.key, required this.action});

  @override
  State<CourseGrid> createState() => _CourseListState();
}

class _CourseListState extends State<CourseGrid> {
  @override
  void initState() {
    controller = RefreshController();
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), refresh);
  }

  late RefreshController controller;

  refresh() {
    context.read<CourseCubit>()
      ..loadCourses()
      ..selfEnrollment()
      ..loadCatalogue(context.read<CategoryCubit>().state.selected);
    controller.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseCubit, CourseState>(
      builder: (context, state) {
        var data = (widget.action == CourseAction.enroll
                    ? state.selfEnrollment
                    : state.courses)
                ?.toList() ??
            <Course>[];
        if ((data.isEmpty && context.watch<CourseCubit>().state.isLoading)) {
          return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                  crossAxisCount: 2,
                  childAspectRatio: 178 / 216),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              itemCount: (widget.action == CourseAction.enroll
                      ? state.selfEnrollment?.length
                      : state.courses?.length) ??
                  0,
              itemBuilder: (c, i) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Colors.white,
                    elevation: 5,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 150,
                      height: 200,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: MaterialButton(
                            color: Colors.white,
                            padding: EdgeInsets.zero,
                            onPressed: () {}),
                      ),
                    ),
                  )));
        }
        final waitingIds = {
          for (final a in state.myCourses ?? const [])
            if (a.course.isAwaitingApproval)
              a.course.courseId ?? a.course.idCourse ?? '',
        };
        return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                crossAxisCount: 2,
                childAspectRatio: 178 / 216),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            itemCount: data.length ?? 0,
            itemBuilder: (c, i) {
              var item = data[i];
              // subscribe_method: 0 = admin only, 1 = requires approval,
              // 2 = free/self-subscribe.
              final id = item.courseId ?? item.idCourse ?? '';
              final enrolled = item.enrolled == '1' || item.enrolled == 1;
              final method = item.subscribeMethod ?? '';
              final status = item.status ?? '';
              final type = (item.courseType ?? '').toLowerCase();
              final isClassroom =
                  type.contains('classroom') || type.contains('ilt');

              // The catalogue reports `enrolled: 1` for pending requests too
              // and has no `waiting` flag, so the pending-approval state comes
              // from My Courses (userCourses: waiting / can_enter.reason).
              // Until My Courses has loaded, fall back to the old heuristic.
              final bool waiting = state.myCourses != null
                  ? waitingIds.contains(id)
                  : (method == '1' && enrolled && status != '1');

              CourseAction courseAction;
              if (waiting) {
                // Approval requested but not yet granted — not an enrolment,
                // cannot be entered (LMS shows "Waiting").
                courseAction = CourseAction.waiting;
              } else if (enrolled) {
                courseAction = CourseAction.enter;
              } else if (method == '0') {
                courseAction = CourseAction.adminOnly;
              } else if (method == '1') {
                courseAction = CourseAction.enroll; // Request for access
              } else if (isClassroom && (item.dateBegin ?? '').isEmpty) {
                // Classroom/ILT course with no scheduled edition to join.
                courseAction = CourseAction.noEditions;
              } else {
                courseAction = CourseAction.subscribe;
              }
              return CourseCard(course: item, action: courseAction);
            });
      },
    );
  }
}
