import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart' as html;
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/course_state_card.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/extensions/date.dart';
import 'package:sevenup_mobile/models/course.dart';
import 'package:sevenup_mobile/views/course/cubit/category_cubit.dart';
import 'package:sevenup_mobile/views/course/cubit/course_cubit.dart';
import 'package:sevenup_mobile/views/course_details.dart';

enum _StatusTab { allOpen, completed, inProgress }

/// Approved My Courses screen (Figma 03): enrolled/assigned courses with
/// Category / Course Type / Year filters, All Open / Completed / In Progress
/// status tabs, and per-course Enter buttons.
class MyCoursesFullPage extends StatefulWidget {
  static const routeName = '/my-courses';
  const MyCoursesFullPage({super.key});

  @override
  State<MyCoursesFullPage> createState() => _MyCoursesFullPageState();
}

class _MyCoursesFullPageState extends State<MyCoursesFullPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _StatusTab _tab = _StatusTab.allOpen;
  String? _category; // null = All
  String? _type; // null = All ('elearning' | 'classroom')
  String? _year; // null = All

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<CourseCubit>().loadCourses());
  }

  // ---- status classification --------------------------------------------
  // The userCourses endpoint carries per-course progress in `course_stats`
  // (status + date_first_access + date_complete). Dates are the most reliable
  // signal: a completion date => completed; a first-access date without a
  // completion date => in progress. Fall back to the status strings otherwise.
  bool _completed(Course c) {
    if ((c.courseStats?.dateComplete ?? '').isNotEmpty) return true;
    final s =
        (c.courseStats?.status ?? c.userStatus ?? c.status ?? '').toLowerCase();
    return s.contains('complet');
  }

  bool _inProgress(Course c) {
    if (_completed(c)) return false;
    final started = (c.courseStats?.dateFirstAccess ?? '').isNotEmpty ||
        (c.dateFirstAccess ?? '').isNotEmpty;
    if (started) return true;
    final s =
        (c.courseStats?.status ?? c.userStatus ?? c.status ?? '').toLowerCase();
    return s.contains('progress') || s.contains('started');
  }

  String _typeLabel(Course c) {
    final t = (c.courseType ?? '').toLowerCase();
    if (t.contains('classroom') || t.contains('ilt')) return 'Classroom';
    if (t.contains('elearning') || t.contains('e-learning') || t.contains('e_learning')) {
      return 'eLearning';
    }
    return c.courseType?.isNotEmpty == true ? c.courseType! : 'eLearning';
  }

  String? _yearOf(Course c) {
    final raw = c.dateBegin ?? c.subStartDate ?? c.subEndDate ?? '';
    final d = DateTime.tryParse(raw);
    return d != null ? '${d.year}' : null;
  }

  List<Course> get _allCourses =>
      (context.watch<CourseCubit>().state.myCourses ?? const [])
          .map((e) => e.course)
          .whereType<Course>()
          .toList();

  List<Course> get _filtered {
    var list = _allCourses;
    switch (_tab) {
      case _StatusTab.completed:
        list = list.where(_completed).toList();
        break;
      case _StatusTab.inProgress:
        list = list.where(_inProgress).toList();
        break;
      case _StatusTab.allOpen:
        break;
    }
    if (_category != null) {
      list = list.where((c) => (c.category ?? '') == _category).toList();
    }
    if (_type != null) {
      list = list.where((c) => _typeLabel(c) == _type).toList();
    }
    if (_year != null) {
      list = list.where((c) => _yearOf(c) == _year).toList();
    }
    return list;
  }

  /// Returns the loading/error/empty status card when the list can't render
  /// rows yet (Figma 03D/03F/03E), or null when there are courses to show.
  Widget? _stateCard(BuildContext context, bool filteredEmpty) {
    final s = context.watch<CourseCubit>().state;
    if (s.isLoading && s.myCourses == null) {
      return const CourseStateCard.loading();
    }
    if (s.hasError && (s.myCourses == null || _allCourses.isEmpty)) {
      return CourseStateCard.error(
        onRetry: () => context.read<CourseCubit>().loadCourses(),
      );
    }
    if (filteredEmpty) return const CourseStateCard.empty();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final categories = (context.watch<CategoryCubit>().state.data ?? const [])
        .map((e) => e.name)
        .toList();
    final years = _allCourses
        .map(_yearOf)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    final courses = _filtered;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModuleHeader(
              title: 'My Courses',
              subtitle: 'Your enrolled and assigned courses',
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 16, AppTokens.screenPadding, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Category',
                      value: _category,
                      options: categories,
                      onChanged: (v) => setState(() => _category = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Course Type',
                      value: _type,
                      options: const ['eLearning', 'Classroom'],
                      onChanged: (v) => setState(() => _type = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Year',
                      value: _year,
                      options: years,
                      onChanged: (v) => setState(() => _year = v),
                    ),
                  ),
                ],
              ),
            ),
            // Horizontally scrollable so the pills never overflow on narrower
            // screens while staying on a single line per the design.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 16, AppTokens.screenPadding, 0),
              child: Row(
                children: [
                  _StatusPill(
                    label: 'All Open',
                    selected: _tab == _StatusTab.allOpen,
                    onTap: () => setState(() => _tab = _StatusTab.allOpen),
                  ),
                  const SizedBox(width: 10),
                  _StatusPill(
                    label: 'Completed',
                    selected: _tab == _StatusTab.completed,
                    onTap: () => setState(() => _tab = _StatusTab.completed),
                  ),
                  const SizedBox(width: 10),
                  _StatusPill(
                    label: 'In Progress',
                    selected: _tab == _StatusTab.inProgress,
                    onTap: () => setState(() => _tab = _StatusTab.inProgress),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 18, AppTokens.screenPadding, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _tab == _StatusTab.completed
                          ? 'Completed Courses'
                          : _tab == _StatusTab.inProgress
                              ? 'In Progress Courses'
                              : 'All Open Courses',
                      style: AppTokens.manrope(
                          size: 18, weight: 700, color: AppTokens.textPrimary),
                    ),
                  ),
                  Text(
                    '${courses.length} course${courses.length == 1 ? '' : 's'}',
                    style: AppTokens.manrope(
                        size: 12, weight: 400, color: AppTokens.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<CourseCubit>().loadCourses();
                },
                child: _stateCard(context, courses.isEmpty) != null
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 24),
                          _stateCard(context, courses.isEmpty)!,
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                            AppTokens.screenPadding,
                            4,
                            AppTokens.screenPadding,
                            24),
                        itemCount: courses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (c, i) => _MyCourseCard(
                          course: courses[i],
                          typeLabel: _typeLabel(courses[i]),
                          year: _yearOf(courses[i]),
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

class _MyCourseCard extends StatelessWidget {
  final Course course;
  final String typeLabel;
  final String? year;
  const _MyCourseCard({
    required this.course,
    required this.typeLabel,
    this.year,
  });

  String _plain(String? h) {
    if (h == null || h.isEmpty) return '';
    try {
      return html.parse(h).body?.text ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final closing =
        DateTime.tryParse(course.subEndDate ?? '')?.format() ?? 'N/A';
    return Material(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => CourseDetails(course: course)),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.cardRadius),
            boxShadow: AppTokens.recommendationCardShadow,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 118,
                  child: CachedNetworkImage(
                    imageUrl: course.courseImage ?? course.imgCourse ?? '',
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: AppTokens.lightGreen),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          course.courseName ?? course.name ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTokens.manrope(
                              size: 15,
                              weight: 700,
                              color: AppTokens.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _plain(course.courseDescription ??
                              course.courseBoxDescription),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTokens.manrope(
                              size: 12,
                              weight: 400,
                              color: AppTokens.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            text: 'Closing Date: ',
                            style: AppTokens.manrope(
                                size: 12,
                                weight: 700,
                                color: AppTokens.textPrimary),
                            children: [
                              TextSpan(
                                text: closing,
                                style: AppTokens.manrope(
                                    size: 12,
                                    weight: 700,
                                    color: AppTokens.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$typeLabel${year != null ? '  •  $year' : ''}',
                                style: AppTokens.manrope(
                                    size: 11,
                                    weight: 400,
                                    color: AppTokens.textSecondary),
                              ),
                            ),
                            _EnterButton(
                              onTap: () => Navigator.of(context).push(
                                CupertinoPageRoute(
                                    builder: (_) =>
                                        CourseDetails(course: course)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EnterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EnterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          child: Text(
            'Enter',
            style: AppTokens.manrope(size: 13, weight: 600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: onChanged,
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem<String?>(value: null, child: Text('All $label')),
        ...options.map((o) => PopupMenuItem<String?>(value: o, child: Text(o))),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTokens.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTokens.manrope(
                  size: 12,
                  weight: 500,
                  color: value == null
                      ? AppTokens.textSecondary
                      : AppTokens.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                size: 18, color: AppTokens.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _StatusPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTokens.primary : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppTokens.primary : AppTokens.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? Colors.white : AppTokens.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTokens.manrope(
                  size: 13,
                  weight: 600,
                  color: selected ? Colors.white : AppTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

