import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/stats.dart';

// Course-status colours (Figma 08).
const _cCompleted = Color(0xFF4CA23A);
const _cInProgress = Color(0xFFF3B01C);
const _cNotStarted = Color(0xFF5AAAD9);
const _cWaiting = Color(0xFFE8412C);

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'
];

/// My Learning (Figma 08) — the redesign of the former "My Activity" screen.
/// Uses the same `POST /api/user/userStats` endpoint (via [ApiRepository.getStats]).
///
/// Wired from userStats: Total courses, Completion % (completed/total) and the
/// course-status donut (completed / in-progress / not-started / waiting).
/// NOT available from any endpoint yet: total time spent, and per-day weekly
/// learning time — those areas show an "unavailable" state until a backend
/// learning-time endpoint exists.
class MyLearningPage extends StatefulWidget {
  static const routeName = '/my-learning';
  const MyLearningPage({super.key});

  @override
  State<MyLearningPage> createState() => _MyLearningPageState();
}

class _MyLearningPageState extends State<MyLearningPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = ApiRepository();

  Stats? _stats;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    final res = await _repository.getStats();
    if (!mounted) return;
    setState(() {
      if (res.body is Stats) {
        _stats = res.body as Stats;
      } else {
        _error = true;
      }
      _loading = false;
    });
  }

  int _val(int? v) => v ?? 0;

  static const _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
    'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _fmtDate(String? s) {
    final d = DateTime.tryParse(s ?? '');
    if (d == null) return '—';
    return '${d.day} ${_monthAbbr[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final ca = _stats?.courseAttendance;
    final completed = _val(ca?.completed);
    final inProgress = _val(ca?.inProgress);
    final notStarted = _val(ca?.notStarted);
    final waiting = _val(ca?.waiting);
    final total = _val(ca?.totalCourses) == 0
        ? completed + inProgress + notStarted + waiting
        : _val(ca?.totalCourses);
    final completion = total > 0 ? ((completed / total) * 100).round() : 0;
    final now = DateTime.now();
    final month = '${_monthNames[now.month - 1]} ${now.year}';
    final certificates = _val(_stats?.certificatesAttained);
    final competencies = _val(_stats?.competenciesAttained);
    final lastLogin = _fmtDate(_stats?.lastLogin);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'My Learning',
              subtitle: 'Your learning progress and insights',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTokens.primary))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                            AppTokens.screenPadding,
                            16,
                            AppTokens.screenPadding,
                            24),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Overview',
                                    style: AppTokens.manrope(
                                        size: 22,
                                        weight: 700,
                                        color: AppTokens.textPrimary)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTokens.lightGreen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(month,
                                    style: AppTokens.manrope(
                                        size: 13,
                                        weight: 600,
                                        color: AppTokens.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _OverviewCard(
                                  value: '$total',
                                  label: 'Total courses',
                                  bg: const Color(0xFFEAF3E6),
                                  valueColor: AppTokens.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _OverviewCard(
                                  value: '$completion%',
                                  label: 'Completion',
                                  bg: const Color(0xFFF7EFE0),
                                  valueColor: AppTokens.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _OverviewCard(
                                  // No time-spent field in userStats.
                                  value: '—',
                                  label: 'Time spent',
                                  bg: const Color(0xFFE7EEF5),
                                  valueColor: AppTokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _CourseActivityCard(
                            completed: completed,
                            inProgress: inProgress,
                            notStarted: notStarted,
                            waiting: waiting,
                            total: completed +
                                inProgress +
                                notStarted +
                                waiting,
                            hasError: _error,
                          ),
                          const SizedBox(height: 18),
                          const _WeeklyLearningCard(),
                          const SizedBox(height: 22),
                          Text('Performance',
                              style: AppTokens.manrope(
                                  size: 22,
                                  weight: 700,
                                  color: AppTokens.textPrimary)),
                          const SizedBox(height: 16),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // No assessment-score endpoint yet.
                                Expanded(
                                  child: _PerfCard(
                                    value: '—',
                                    label: 'Average assessment score',
                                    bg: const Color(0xFFEAF3E6),
                                    valueColor: AppTokens.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // No learning-streak endpoint yet.
                                Expanded(
                                  child: _PerfCard(
                                    value: '—',
                                    label: 'Current learning streak',
                                    bg: const Color(0xFFFBEDE6),
                                    valueColor: AppTokens.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const _AssessmentTrendCard(),
                          const SizedBox(height: 18),
                          _LearningHighlightsCard(
                            certificates: certificates,
                            competencies: competencies,
                            lastLogin: lastLogin,
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

class _OverviewCard extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
  const _OverviewCard({
    required this.value,
    required this.label,
    required this.bg,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(value,
                style: AppTokens.manrope(
                    size: 22, weight: 700, color: valueColor)),
          ),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 12, weight: 400, color: AppTokens.textSecondary)),
        ],
      ),
    );
  }
}

class _CourseActivityCard extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int notStarted;
  final int waiting;
  final int total;
  final bool hasError;
  const _CourseActivityCard({
    required this.completed,
    required this.inProgress,
    required this.notStarted,
    required this.waiting,
    required this.total,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Course activity',
              style: AppTokens.manrope(
                  size: 20, weight: 700, color: AppTokens.textPrimary)),
          const SizedBox(height: 4),
          Text('Status of all assigned and enrolled courses',
              style: AppTokens.manrope(
                  size: 13, weight: 400, color: AppTokens.textSecondary)),
          const SizedBox(height: 20),
          if (total == 0)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  hasError
                      ? "Couldn't load your activity."
                      : 'No course activity yet.',
                  style: AppTokens.manrope(
                      size: 14, weight: 500, color: AppTokens.textSecondary),
                ),
              ),
            )
          else
            Row(
              children: [
                _DonutChart(
                  size: 150,
                  total: total,
                  segments: [
                    (completed, _cCompleted),
                    (inProgress, _cInProgress),
                    (notStarted, _cNotStarted),
                    (waiting, _cWaiting),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _LegendRow(
                          color: _cCompleted,
                          label: 'Completed',
                          count: completed),
                      const SizedBox(height: 14),
                      _LegendRow(
                          color: _cInProgress,
                          label: 'In progress',
                          count: inProgress),
                      const SizedBox(height: 14),
                      _LegendRow(
                          color: _cNotStarted,
                          label: 'Not started',
                          count: notStarted),
                      const SizedBox(height: 14),
                      _LegendRow(
                          color: _cWaiting, label: 'Waiting', count: waiting),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  const _LegendRow(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: AppTokens.manrope(
                  size: 15, weight: 500, color: AppTokens.textPrimary)),
        ),
        Text('$count',
            style: AppTokens.manrope(
                size: 15, weight: 700, color: AppTokens.textSecondary)),
      ],
    );
  }
}

class _DonutChart extends StatelessWidget {
  final double size;
  final int total;
  final List<(int, Color)> segments;
  const _DonutChart(
      {required this.size, required this.total, required this.segments});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(segments, total),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$total',
                  style: AppTokens.manrope(
                      size: 28, weight: 700, color: AppTokens.textPrimary)),
              Text('courses',
                  style: AppTokens.manrope(
                      size: 12, weight: 400, color: AppTokens.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<(int, Color)> segments;
  final int total;
  _RingPainter(this.segments, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 20.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke,
        size.height - stroke);
    // Track.
    final track = Paint()
      ..color = const Color(0xFFEDEFEC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    if (total <= 0) return;

    const gap = 0.06; // radians between segments
    var start = -math.pi / 2 + gap / 2;
    for (final (value, color) in segments) {
      if (value <= 0) continue;
      final sweep = (value / total) * (2 * math.pi) - gap;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.segments != segments || old.total != total;
}

/// A left-aligned Performance stat card (Figma 08).
class _PerfCard extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
  const _PerfCard({
    required this.value,
    required this.label,
    required this.bg,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: AppTokens.manrope(
                  size: 28, weight: 700, color: valueColor)),
          const SizedBox(height: 6),
          Text(label,
              style: AppTokens.manrope(
                  size: 12, weight: 400, color: AppTokens.textSecondary)),
        ],
      ),
    );
  }
}

/// Assessment score trend (Figma 08). No assessment-score endpoint yet, so this
/// shows the card layout with an "unavailable" state.
class _AssessmentTrendCard extends StatelessWidget {
  const _AssessmentTrendCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Assessment score trend',
                    style: AppTokens.manrope(
                        size: 20, weight: 700, color: AppTokens.textPrimary)),
              ),
              Text('—',
                  style: AppTokens.manrope(
                      size: 16, weight: 700, color: AppTokens.primary)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Last five completed assessments',
              style: AppTokens.manrope(
                  size: 13, weight: 400, color: AppTokens.textSecondary)),
          const SizedBox(height: 28),
          Center(
            child: Text('Assessment data isn’t available yet.',
                style: AppTokens.manrope(
                    size: 12, weight: 500, color: AppTokens.textSecondary)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Learning highlights (Figma 08): certificates, competencies and last login —
/// all from the userStats endpoint.
class _LearningHighlightsCard extends StatelessWidget {
  final int certificates;
  final int competencies;
  final String lastLogin;
  const _LearningHighlightsCard({
    required this.certificates,
    required this.competencies,
    required this.lastLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Learning highlights',
              style: AppTokens.manrope(
                  size: 20, weight: 700, color: AppTokens.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value: '$certificates',
                  label: 'Certificates',
                  bg: const Color(0xFFEAF3E6),
                  valueColor: AppTokens.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  value: '$competencies',
                  label: 'Competencies',
                  bg: const Color(0xFFEAF3E6),
                  valueColor: AppTokens.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  value: lastLogin,
                  label: 'Last login',
                  bg: const Color(0xFFEFF1F4),
                  valueColor: AppTokens.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
  const _MiniStat({
    required this.value,
    required this.label,
    required this.bg,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(value,
                style: AppTokens.manrope(
                    size: 20, weight: 700, color: valueColor)),
          ),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 11, weight: 400, color: AppTokens.textSecondary)),
        ],
      ),
    );
  }
}

/// Weekly learning time (Figma 08). There is no per-day learning-time endpoint
/// yet, so this shows the layout with an "unavailable" state rather than fake
/// data.
class _WeeklyLearningCard extends StatelessWidget {
  const _WeeklyLearningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Weekly learning time',
                    style: AppTokens.manrope(
                        size: 20, weight: 700, color: AppTokens.textPrimary)),
              ),
              Text('—',
                  style: AppTokens.manrope(
                      size: 18, weight: 700, color: AppTokens.primary)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Minutes spent learning each day',
              style: AppTokens.manrope(
                  size: 13, weight: 400, color: AppTokens.textSecondary)),
          const SizedBox(height: 24),
          // Empty track bars — no learning-time data available yet.
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final d in _weekdays)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 18,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEFEC),
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(d,
                          style: AppTokens.manrope(
                              size: 11,
                              weight: 400,
                              color: AppTokens.textSecondary)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text('Learning-time data isn’t available yet.',
                style: AppTokens.manrope(
                    size: 12, weight: 500, color: AppTokens.textSecondary)),
          ),
        ],
      ),
    );
  }
}
