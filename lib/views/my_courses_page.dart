import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/common/course_card.dart';
import 'package:sevenup_mobile/gen/assets.gen.dart';
import 'package:sevenup_mobile/models/course.dart';
import 'package:sevenup_mobile/views/course/cubit/course_cubit.dart';
import 'package:sevenup_mobile/views/course_list.dart';
import 'package:shimmer/shimmer.dart';

enum MyCourseType {
  recentlyViewed,
  recomended,
  completed,
  enrollment,
  myCourses,
  searchCourse
}

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage(
      {super.key,
      required this.recentlyViwedCourseCubit,
      required this.justForYouCourseCubit});
  final CourseCubit recentlyViwedCourseCubit, justForYouCourseCubit;

  @override
  Widget build(BuildContext context) {
    // print(context.watch<CourseCubit>().state.recentlyViewed);
    return Column(
      children: [
        if (context.watch<CourseCubit>().state.myCourses?.isNotEmpty == true)
          CourseHorizontalList(
            myCourseType: MyCourseType.myCourses,
            courseCubit: context.read<CourseCubit>(),
            title: '',
            courses: context
                    .watch<CourseCubit>()
                    .state
                    .myCourses
                    ?.map((e) => e.course)
                    .toList() ??
                [],
          ),
        const SizedBox(height: 11),
        BlocBuilder<CourseCubit, CourseState>(
            bloc: recentlyViwedCourseCubit,
            builder: (context, state) {
              var courses =
                  recentlyViwedCourseCubit.state.recentlyViewed?.toList() ?? [];
              if (courses.isEmpty) {
                return const SizedBox.shrink();
              }
              return CourseHorizontalList(
                courseCubit: recentlyViwedCourseCubit,
                // courseCubit: ,
                myCourseType: MyCourseType.recentlyViewed,
                title: 'Recently Viewed Courses',
                courses: courses,
              );
            }),
        // const SizedBox(height: 11),
        BlocBuilder<CourseCubit, CourseState>(
            bloc: justForYouCourseCubit,
            builder: (context, state) {
              var recomended = state.recomended;
              var courses = recomended?.completed?.courselist?.toList() ?? [];
              if (courses.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 11.0),
                child: CourseHorizontalList(
                    myCourseType: MyCourseType.completed,
                    courseCubit: justForYouCourseCubit,
                    title: recomended?.completed?.recommendByCourseName != null
                        ? 'Because you completed ${recomended!.completed?.recommendByCourseName ?? ''}'
                        : 'Because you completed related courses',
                    courses: courses),
              );
            }),
        BlocBuilder<CourseCubit, CourseState>(
            bloc: justForYouCourseCubit,
            builder: (context, state) {
              var recomended = state.recomended;
              var courses = recomended?.enrollment?.courselist?.toList() ?? [];
              if (courses.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 11.0),
                child: CourseHorizontalList(
                    myCourseType: MyCourseType.enrollment,
                    courseCubit: justForYouCourseCubit,
                    title: recomended?.enrollment?.recommendByCourseName != null
                        ? 'Because you are enrolled in ${recomended!.enrollment?.recommendByCourseName ?? ''}'
                        : 'Because you are enrolled in related courses',
                    // isRecentlyViewed: true,
                    courses: courses),
              );
            }),
        BlocBuilder<CourseCubit, CourseState>(
            bloc: justForYouCourseCubit,
            builder: (context, state) {
              var recomended = state.recomended;
              var courses = recomended?.recommended?.courselist?.toList() ?? [];
              if (courses.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 11.0),
                child: CourseHorizontalList(
                    myCourseType: MyCourseType.recomended,
                    courseCubit: justForYouCourseCubit,
                    title: 'Recommended for you',
                    // isRecentlyViewed: true,
                    courses: courses),
              );
            }),
      ],
    );
  }
}

class CourseHorizontalList extends StatelessWidget {
  final CourseCubit courseCubit;
  final List<Course> courses;
  final String title;
  // final bool isRecentlyViewed;
  final MyCourseType myCourseType;

  const CourseHorizontalList(
      {super.key,
      required this.courses,
      // this.isRecentlyViewed = false,
      required this.title,
      required this.courseCubit,
      required this.myCourseType});

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 20),
                // const Spacer(),
                CupertinoButton(
                  minSize: 1,
                  padding: const EdgeInsets.only(left: 10, top: 10, bottom: 0),
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (c) => CourseList(
                                  myCourseType: myCourseType,
                                  courseCubit: courseCubit,
                                  // isRecentlyViewed: isRecentlyViewed,

                                  // courses: context
                                  //         .read<CourseCubit>()
                                  //         .state
                                  //         .myCourses
                                  //         ?.map((f) => f.course)
                                  //         .toList() ??
                                )));
                  },
                  child: Row(
                    children: [
                      const Text(
                        'See all ',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Assets.svg.more.svg(),
                    ],
                  ),
                ),
              ],
            )),
        SizedBox(
            height: 216 + 20,
            child: (courses.isEmpty &&
                    context.watch<CourseCubit>().state.isLoading)
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 15),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Padding(
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
                                onPressed: () {},
                              ),
                            ),
                          ),
                        )))
                : ListView(scrollDirection: Axis.horizontal, children: [
                    Center(
                      child: SizedBox(
                          height: 216,
                          child: Row(
                            children: [
                              const SizedBox(width: 28),
                              for (var i = 0; i < min(5, courses.length); i++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 14.0),
                                  child: SizedBox(
                                      width: (MediaQuery.sizeOf(context).width /
                                              2) -
                                          (28),
                                      child: CourseCard(course: courses[i])),
                                )
                            ],
                          )),
                    ),
                  ])),
      ],
    );
  }
}
