import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/models/course.dart';
import 'package:sevenup_mobile/views/course/cubit/course_cubit.dart';
import 'package:sevenup_mobile/views/course/cubit/search_cubit.dart';
import 'package:sevenup_mobile/views/courses_hub_page.dart';
import 'package:sevenup_mobile/views/my_courses_page.dart';

/// "See all" screen for a Courses Hub section (Recommended for you, Because
/// you are enrolled in / completed, Recently viewed). Uses the app's module
/// header and the same 2-column course cards as the hub. Also renders search
/// results (without the header) for the search screen.
class CourseList extends StatefulWidget {
  final MyCourseType myCourseType;
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _isSearch => widget.myCourseType == MyCourseType.searchCourse;

  bool get _isRecommendation => const {
        MyCourseType.recomended,
        MyCourseType.enrollment,
        MyCourseType.completed,
      }.contains(widget.myCourseType);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    switch (widget.myCourseType) {
      case MyCourseType.recentlyViewed:
        await widget.courseCubit.loadRecentlyViewedCourses();
      case MyCourseType.recomended:
      case MyCourseType.enrollment:
      case MyCourseType.completed:
        await widget.courseCubit.loadRecomended();
      case MyCourseType.searchCourse:
        final q = context.read<SearchCubit>().state;
        if (q.isNotEmpty) await widget.courseCubit.search(q);
      case MyCourseType.myCourses:
        await widget.courseCubit.loadCourses();
    }
  }

  List<Course>? _data(CourseState s) => switch (widget.myCourseType) {
        MyCourseType.myCourses => s.enrolledCourses,
        MyCourseType.recentlyViewed => s.recentlyViewed?.toList(),
        MyCourseType.recomended =>
          s.recomended?.recommended?.courselist?.toList(),
        MyCourseType.completed =>
          s.recomended?.completed?.courselist?.toList(),
        MyCourseType.enrollment =>
          s.recomended?.enrollment?.courselist?.toList(),
        MyCourseType.searchCourse => s.search?.toList(),
      };

  String get _title => switch (widget.myCourseType) {
        MyCourseType.myCourses => 'My Courses',
        MyCourseType.recentlyViewed => 'Recently Viewed',
        MyCourseType.completed => 'Because you completed',
        MyCourseType.enrollment => 'Because you are enrolled in',
        MyCourseType.recomended => 'Recommended for you',
        MyCourseType.searchCourse => 'Search results',
      };

  /// The course the recommendation is based on (when the API provides it).
  String? _basedOn(CourseState s) {
    final name = switch (widget.myCourseType) {
      MyCourseType.completed => s.recomended?.completed?.recommendByCourseName,
      MyCourseType.enrollment =>
        s.recomended?.enrollment?.recommendByCourseName,
      MyCourseType.recomended =>
        s.recomended?.recommended?.recommendByCourseName,
      _ => null,
    };
    return (name != null && name.trim().isNotEmpty) ? name.trim() : null;
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocBuilder<CourseCubit, CourseState>(
      bloc: widget.courseCubit,
      builder: (context, state) {
        final data = _data(state) ?? const <Course>[];
        if (data.isEmpty && state.isLoading) return const _GridSkeleton();
        return RefreshIndicator(
          color: AppTokens.primary,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (!_isSearch)
                SliverToBoxAdapter(
                  child: _Intro(count: data.length, basedOn: _basedOn(state)),
                ),
              if (data.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(recommendation: _isRecommendation),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppTokens.screenPadding,
                      8, AppTokens.screenPadding, 24),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                    children: [
                      for (final c in data)
                        HubCourseCard(
                            course: c, recommended: _isRecommendation),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (_isSearch) return body;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: _title,
              subtitle: _isRecommendation ? 'Courses picked for you' : 'Courses',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// Context above the grid: the course the list is based on + a count.
class _Intro extends StatelessWidget {
  final int count;
  final String? basedOn;
  const _Intro({required this.count, required this.basedOn});

  @override
  Widget build(BuildContext context) {
    if (count == 0 && basedOn == null) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTokens.screenPadding, 14, AppTokens.screenPadding, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (basedOn != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTokens.lightGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppTokens.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BASED ON',
                            style: AppTokens.manrope(
                                size: 11,
                                weight: 700,
                                color: AppTokens.primary,
                                letterSpacing: 0.6)),
                        const SizedBox(height: 2),
                        Text(basedOn!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTokens.manrope(
                                size: 15,
                                weight: 700,
                                color: AppTokens.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (count > 0)
            Text(
              '$count ${count == 1 ? 'course' : 'courses'}',
              style: AppTokens.manrope(
                  size: 13, weight: 600, color: AppTokens.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool recommendation;
  const _EmptyState({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppTokens.lightGreen, shape: BoxShape.circle),
            child: const Icon(Icons.school_outlined,
                color: AppTokens.primary, size: 30),
          ),
          const SizedBox(height: 18),
          Text(
            recommendation ? 'No recommendations yet' : 'No courses yet',
            textAlign: TextAlign.center,
            style: AppTokens.manrope(
                size: 18, weight: 700, color: AppTokens.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            recommendation
                ? 'Enrol in or complete courses and we’ll suggest what to '
                    'learn next.'
                : 'Pull down to refresh.',
            textAlign: TextAlign.center,
            style: AppTokens.manrope(
                size: 14,
                weight: 400,
                height: 20,
                color: AppTokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Shimmering 2-column placeholder matching the course card grid.
class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.count(
        padding: const EdgeInsets.fromLTRB(
            AppTokens.screenPadding, 20, AppTokens.screenPadding, 24),
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
        children: List.generate(
          6,
          (_) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
