import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/course_card.dart';
import 'package:sevenup_mobile/gen/assets.gen.dart';
import 'package:sevenup_mobile/views/course/cubit/course_cubit.dart';
import 'package:sevenup_mobile/views/course/cubit/search_cubit.dart';
import 'package:sevenup_mobile/views/my_courses_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class CourseList extends StatefulWidget {
  // final bool isRecentlyViewed;
  final MyCourseType myCourseType;
  // final String? title;

  // final List<Course> courses;
  final CourseCubit courseCubit;
  const CourseList({
    super.key,
    required this.myCourseType,
    required this.courseCubit,
  });

  @override
  State<CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  @override
  void initState() {
    controller = RefreshController();
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), refresh);
  }

  late RefreshController controller;

  refresh() {
    switch (widget.myCourseType) {
      case MyCourseType.recentlyViewed:
        {
          widget.courseCubit.loadRecentlyViewedCourses();
        }
        break;
      case MyCourseType.recomended:
      case MyCourseType.enrollment:
      case MyCourseType.completed:
        widget.courseCubit.loadRecomended();

        break;
      case MyCourseType.searchCourse:
        if (context.read<SearchCubit>().state.isNotEmpty) {
          widget.courseCubit.search(context.read<SearchCubit>().state);
        }

        break;
      case MyCourseType.myCourses:
      default:
        context.read<CourseCubit>().loadCourses();
    }

    controller.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      appBar: widget.myCourseType == MyCourseType.searchCourse
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: BlocBuilder<CourseCubit, CourseState>(
                bloc: widget.courseCubit,
                builder: (context, state) => Text(
                  switch (widget.myCourseType) {
                    MyCourseType.searchCourse => '',
                    MyCourseType.myCourses => 'My Courses',
                    MyCourseType.recentlyViewed => 'Recently Viewed Courses',
                    MyCourseType.completed => state.recomended?.completed !=
                            null
                        ? 'Because you completed ${state.recomended!.recommended ?? ''}'
                        : 'Recommended for you',
                    MyCourseType.enrollment => state.recomended?.enrollment !=
                            null
                        ? 'Because you enrolled ${state.recomended!.recommended ?? ''}'
                        : 'Because you enrolled in related courses',
                    MyCourseType.recomended => 'Recommended for you'
                    // _ => ''
                  },
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              )),
      body: BlocBuilder<CourseCubit, CourseState>(
        bloc: widget.courseCubit,
        builder: (context, state) {
          var data = switch (widget.myCourseType) {
            MyCourseType.myCourses =>
              state.myCourses?.map((f) => f.course).toList(),
            MyCourseType.recentlyViewed => state.recentlyViewed?.toList(),
            MyCourseType.recomended =>
              state.recomended?.recommended?.courselist?.toList(),
            MyCourseType.completed =>
              state.recomended?.completed?.courselist?.toList(),
            MyCourseType.enrollment =>
              state.recomended?.enrollment?.courselist?.toList(),
            MyCourseType.searchCourse => state.search?.toList(),
            // _ => []
          };
          // var data = widget.isRecentlyViewed
          //     ? state.recentlyViewed?.toList()
          //     : state.myCourses?.map((f) => f.course).toList();
          return SmartRefresher(
              enablePullDown: true,
              header: const MaterialClassicHeader(),
              controller: controller,
              onRefresh: refresh,
              child: ((data?.isNotEmpty != true) &&
                      context.watch<CourseCubit>().state.isLoading)
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            color: Colors.white,
                            elevation: 5,
                            clipBehavior: Clip.antiAlias,
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: 600,
                              height: 100,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: MaterialButton(
                                  color: Colors.white,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          )))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      itemCount: data?.length ?? 0,
                      itemBuilder: (c, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 11.0),
                            child: CourseCardAlt(course: data![i]),
                          )));
        },
      ),
    );
  }
}
