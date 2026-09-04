import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/course_card.dart';
import 'package:sevenup_mobile/common/course_state_card.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/models/course.dart';
import 'package:sevenup_mobile/views/course/cubit/banner_cubit.dart';
import 'package:sevenup_mobile/views/course/cubit/category_cubit.dart';
import 'package:sevenup_mobile/views/course/cubit/course_cubit.dart';
import 'package:sevenup_mobile/views/course_catalogue_page.dart';
import 'package:sevenup_mobile/views/course_details.dart';
import 'package:sevenup_mobile/views/course_list.dart';
import 'package:sevenup_mobile/views/my_courses_full_page.dart';
import 'package:sevenup_mobile/views/my_courses_page.dart';
import 'package:sevenup_mobile/state/settings/settings_cubit.dart';

/// Approved Courses Hub (Figma 02 / 05). Header with side-menu, a
/// My Courses / Course Catalogue control, and the course recommendation
/// sections. Catalogue is shown as an inline state of the hub (brief §13);
/// "My Courses" opens the dedicated My Courses screen.
class CoursesHubPage extends StatefulWidget {
  static const routeName = '/courses';
  const CoursesHubPage({super.key});

  @override
  State<CoursesHubPage> createState() => _CoursesHubPageState();
}

class _CoursesHubPageState extends State<CoursesHubPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _refreshController = RefreshController();
  late final CourseCubit _recentlyViewedCubit;
  late final CourseCubit _recommendationsCubit;

  /// false = recommendations (My Courses), true = Course Catalogue grid.
  final ValueNotifier<bool> _catalogue = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _recentlyViewedCubit = CourseCubit();
    _recommendationsCubit = CourseCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _recentlyViewedCubit.close();
    _recommendationsCubit.close();
    _catalogue.dispose();
    super.dispose();
  }

  void _refresh() {
    context.read<CourseCubit>()
      ..loadCourses()
      ..selfEnrollment()
      ..loadCatalogue(context.read<CategoryCubit>().state.selected);
    _recentlyViewedCubit.loadRecentlyViewedCourses();
    _recommendationsCubit.loadRecomended();
    context.read<CategoryCubit>().load();
    context.read<BannerCubit>().load();
    context.read<SettingsCubit>().load();
    _refreshController.refreshCompleted();
  }

  void _onMyCourses() {
    // Always open My Courses directly — even from the Catalogue tab (previously
    // this only switched back to the recommendations view, needing a 2nd tap).
    _catalogue.value = false;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyCoursesFullPage()),
    );
  }

  void _onCatalogue() {
    _catalogue.value = true;
    context
        .read<CourseCubit>()
        .loadCatalogue(context.read<CategoryCubit>().state.selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Courses',
              subtitle: 'Your courses and recommendations',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 16, AppTokens.screenPadding, 12),
              child: ValueListenableBuilder<bool>(
                valueListenable: _catalogue,
                builder: (context, catalogue, _) => Row(
                  children: [
                    Expanded(
                      child: _TabPill(
                        // Neither pill is "active" on the hub itself — My
                        // Courses opens its own screen and Catalogue toggles
                        // the inline view. Only highlight once tapped.
                        label: 'My Courses',
                        selected: false,
                        onTap: _onMyCourses,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TabPill(
                        label: 'Course Catalogue',
                        selected: catalogue,
                        onTap: _onCatalogue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                header: const MaterialClassicHeader(),
                onRefresh: _refresh,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _catalogue,
                  builder: (context, catalogue, _) => ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (catalogue)
                        const CourseCataloguePage(
                          key: ValueKey(CourseAction.subscribe),
                          action: CourseAction.subscribe,
                        )
                      else
                        _Recommendations(
                          recentlyViewedCubit: _recentlyViewedCubit,
                          recommendationsCubit: _recommendationsCubit,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The three approved recommendation sections in Figma order (02 • Courses
/// Hub): Recently Viewed → Because you are enrolled in → Because you completed.
/// Each renders as a 2-column grid of course cards.
class _Recommendations extends StatelessWidget {
  final CourseCubit recentlyViewedCubit;
  final CourseCubit recommendationsCubit;
  const _Recommendations({
    required this.recentlyViewedCubit,
    required this.recommendationsCubit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        // Loading state (Figma 03D) while the recommendation/recently-viewed
        // data is still being fetched and nothing is available yet.
        BlocBuilder<CourseCubit, CourseState>(
          bloc: recommendationsCubit,
          builder: (context, recState) => BlocBuilder<CourseCubit, CourseState>(
            bloc: recentlyViewedCubit,
            builder: (context, rvState) {
              final rvEmpty = (rvState.recentlyViewed ?? const []).isEmpty;
              final rec = recState.recomended;
              final recEmpty = rec == null ||
                  ((rec.enrollment?.courselist?.isEmpty ?? true) &&
                      (rec.completed?.courselist?.isEmpty ?? true) &&
                      (rec.recommended?.courselist?.isEmpty ?? true));
              if (rvEmpty &&
                  recEmpty &&
                  (rvState.isLoading || recState.isLoading)) {
                return const CourseStateCard.loading();
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        BlocBuilder<CourseCubit, CourseState>(
          bloc: recentlyViewedCubit,
          builder: (context, state) {
            final courses = state.recentlyViewed?.toList() ?? <Course>[];
            if (courses.isEmpty) return const SizedBox.shrink();
            return _GridSection(
              title: 'Recently Viewed Courses',
              courses: courses,
            );
          },
        ),
        BlocBuilder<CourseCubit, CourseState>(
          bloc: recommendationsCubit,
          builder: (context, state) {
            final rec = state.recomended;
            final courses = rec?.enrollment?.courselist?.toList() ?? <Course>[];
            if (courses.isEmpty) return const SizedBox.shrink();
            return _GridSection(
              title: 'Because you are enrolled in',
              subtitle: rec?.enrollment?.recommendByCourseName,
              recommended: true,
              courses: courses,
              onSeeAll: () => _seeAll(
                  context, recommendationsCubit, MyCourseType.enrollment),
            );
          },
        ),
        BlocBuilder<CourseCubit, CourseState>(
          bloc: recommendationsCubit,
          builder: (context, state) {
            final rec = state.recomended;
            final courses = rec?.completed?.courselist?.toList() ?? <Course>[];
            if (courses.isEmpty) return const SizedBox.shrink();
            return _GridSection(
              title: 'Because you completed',
              subtitle: rec?.completed?.recommendByCourseName,
              recommended: true,
              courses: courses,
              onSeeAll: () => _seeAll(
                  context, recommendationsCubit, MyCourseType.completed),
            );
          },
        ),
        BlocBuilder<CourseCubit, CourseState>(
          bloc: recommendationsCubit,
          builder: (context, state) {
            final rec = state.recomended;
            final courses = rec?.recommended?.courselist?.toList() ?? <Course>[];
            if (courses.isEmpty) return const SizedBox.shrink();
            final by = rec?.recommended?.recommendByCourseName;
            return _GridSection(
              title: (by != null && by.isNotEmpty)
                  ? 'Because you are enrolled in $by'
                  : 'Recommended for you',
              recommended: true,
              courses: courses,
              onSeeAll: () => _seeAll(
                  context, recommendationsCubit, MyCourseType.recomended),
            );
          },
        ),
      ],
    );
  }

  void _seeAll(BuildContext context, CourseCubit cubit, MyCourseType type) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (_) => CourseList(courseCubit: cubit, myCourseType: type),
    ));
  }
}

/// A titled 2-column grid of course cards used by the Courses Hub sections.
class _GridSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Course> courses;
  final VoidCallback? onSeeAll;

  /// Recommendation rails show "Recommended course" instead of a live status.
  final bool recommended;

  const _GridSection({
    required this.title,
    required this.courses,
    this.subtitle,
    this.onSeeAll,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTokens.screenPadding, 8, AppTokens.screenPadding, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTokens.manrope(
                      size: 16, weight: 700, color: AppTokens.textPrimary),
                ),
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Row(
                      children: [
                        Text('See all',
                            style: AppTokens.manrope(
                                size: 13,
                                weight: 600,
                                color: AppTokens.accent)),
                        const Icon(Icons.chevron_right,
                            color: AppTokens.accent, size: 18),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTokens.manrope(
                  size: 13, weight: 400, color: AppTokens.textSecondary),
            ),
          ],
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
            children: [
              for (final c in courses)
                _HubCourseCard(course: c, recommended: recommended),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single course card in the hub grid: image, title, a status/label line,
/// and a green "Continue ›" / "Enter ›" action.
class _HubCourseCard extends StatelessWidget {
  final Course course;
  final bool recommended;
  const _HubCourseCard({required this.course, required this.recommended});

  String get _statusText {
    if (recommended) return 'Recommended course';
    final s = (course.courseStats?.status ??
            course.userStatus ??
            course.status ??
            '')
        .toLowerCase();
    if (s.contains('complet')) return 'Completed';
    final started = course.courseStats?.dateFirstAccess != null &&
        (course.courseStats?.dateFirstAccess ?? '').isNotEmpty;
    final done = (course.courseStats?.dateComplete ?? '').isNotEmpty;
    if (s.contains('progress') || (started && !done)) return 'In Progress';
    return 'Not Completed';
  }

  bool get _inProgress => !recommended && _statusText == 'In Progress';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surface,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.10),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => CourseDetails(course: course)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: SizedBox(
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: course.courseImage ?? course.imgCourse ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Container(color: AppTokens.lightGreen),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseName ?? course.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.manrope(
                          size: 14, weight: 700, color: AppTokens.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.manrope(
                          size: 11,
                          weight: 400,
                          color: AppTokens.textSecondary),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          _inProgress ? 'Continue' : 'Enter',
                          style: AppTokens.manrope(
                              size: 13, weight: 600, color: AppTokens.primary),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppTokens.primary, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTokens.primary : Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: selected ? AppTokens.primary : AppTokens.border,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppTokens.manrope(
              size: 14,
              weight: selected ? 600 : 500,
              color: selected ? Colors.white : AppTokens.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
