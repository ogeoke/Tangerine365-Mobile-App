import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/models/course.dart';
import 'package:sevenup_mobile/models/course_item.dart';
import 'package:sevenup_mobile/views/course/cubit/course_item_cubit.dart';
import 'package:sevenup_mobile/views/course_item_list.dart';

/// Approved Course Content screen (Figma 04). Presentation only — the lesson
/// data, progress source, and lesson-launch behaviour are unchanged.
class CourseDetails extends StatefulWidget {
  final Course course;

  const CourseDetails({super.key, required this.course});

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late CourseItemCubit cubit;
  late RefreshController controller;

  refresh() {
    cubit
      ..load()
      ..loadPercentage();
    controller.refreshCompleted();
  }

  @override
  void initState() {
    controller = RefreshController();
    cubit = CourseItemCubit(
      widget.course.courseId ?? widget.course.idCourse ?? '',
    );
    super.initState();
    refresh();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return BlocProvider(
      create: (context) => cubit,
      child: Builder(
        builder: (context) {
          final state = context.watch<CourseItemCubit>().state;
          final lessons = state.data?.toList() ?? const <CourseItem>[];
          final total = lessons.length;
          final completed = lessons
              .where((e) => e.status == CourseItemStatus.completed)
              .length;
          final pct = state.progress?.completePercentage ?? 0;
          final pctValue = (pct.toDouble() / 100).clamp(0.0, 1.0);

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppTokens.screenBg,
            drawer: NavDrawer(),
            bottomNavigationBar: const AppBottomNav(currentIndex: 1),
            body: SafeArea(
              child: Column(
                children: [
                  ModuleHeader(
                    title: 'Course Content',
                    subtitle: course.courseName ?? course.name ?? '',
                    onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  Expanded(
                    child: SmartRefresher(
                      enablePullDown: true,
                      header: const MaterialClassicHeader(),
                      controller: controller,
                      onRefresh: refresh,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                            AppTokens.screenPadding, 12, AppTokens.screenPadding, 40),
                        children: [
                          Hero(
                            tag: course.courseId ?? course.idCourse ?? '',
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppTokens.cardRadius),
                              child: SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: CachedNetworkImage(
                                  imageUrl: course.courseImage ??
                                      course.imgCourse ??
                                      ' ',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: AppTokens.lightGreen),
                                  errorWidget: (context, url, error) =>
                                      Container(color: AppTokens.lightGreen),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            course.courseName ?? course.name ?? '',
                            style: AppTokens.manrope(
                              size: 23,
                              weight: 700,
                              color: AppTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Course progress',
                                style: AppTokens.manrope(
                                  size: 13,
                                  weight: 400,
                                  color: AppTokens.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$pct%',
                                style: AppTokens.manrope(
                                  size: 14,
                                  weight: 700,
                                  color: AppTokens.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: pctValue,
                              minHeight: 6,
                              backgroundColor: AppTokens.border,
                              valueColor: const AlwaysStoppedAnimation(
                                AppTokens.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Text(
                                'Lessons',
                                style: AppTokens.manrope(
                                  size: 20,
                                  weight: 700,
                                  color: AppTokens.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$completed of $total completed',
                                style: AppTokens.manrope(
                                  size: 12,
                                  weight: 400,
                                  color: AppTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          CourseItemList(course: course),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
