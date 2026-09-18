import 'package:json_annotation/json_annotation.dart';

import 'general.dart';
import 'learning.dart';

part 'stats.g.dart';

@JsonSerializable()
class Stats {
  Stats({
    this.general,
    this.competenciesAttained,
    this.certificatesAttained,
    this.lastLogin,
    this.courseAttendance,
    this.timeSpentMinutes,
    this.avgAssessmentScore,
    this.learningStreakDays,
    this.recentAssessmentScores,
    this.weeklyActivity,
  });

  @JsonKey(name: 'general')
  final General? general;
  @JsonKey(name: 'competencies_attained')
  final int? competenciesAttained;
  @JsonKey(name: 'certificates_attained')
  final int? certificatesAttained;
  @JsonKey(name: 'last_login')
  final String? lastLogin;
  @JsonKey(name: 'course_attendance')
  final Learning? courseAttendance;

  /// Total learning time in minutes (added to userStats 2026-09).
  @JsonKey(name: 'time_spent_minutes')
  final int? timeSpentMinutes;

  /// Average assessment score (0–100).
  @JsonKey(name: 'avg_assessment_score')
  final num? avgAssessmentScore;

  /// Consecutive-day learning streak.
  @JsonKey(name: 'learning_streak_days')
  final int? learningStreakDays;

  /// Most recent assessment scores, newest-last (for the trend chart).
  @JsonKey(name: 'recent_assessment_scores')
  final List<num>? recentAssessmentScores;

  /// Minutes of activity per weekday, keys: mon,tue,wed,thu,fri,sat,sun.
  @JsonKey(name: 'weekly_activity')
  final Map<String, int>? weeklyActivity;

  Map<String, dynamic> toJson() => _$StatsToJson(this);

  static Stats fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);
}
