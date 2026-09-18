// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stats _$StatsFromJson(Map<String, dynamic> json) => Stats(
      general: json['general'] == null
          ? null
          : General.fromJson(json['general'] as Map<String, dynamic>),
      competenciesAttained: (json['competencies_attained'] as num?)?.toInt(),
      certificatesAttained: (json['certificates_attained'] as num?)?.toInt(),
      lastLogin: json['last_login'] as String?,
      courseAttendance: json['course_attendance'] == null
          ? null
          : Learning.fromJson(
              json['course_attendance'] as Map<String, dynamic>),
      timeSpentMinutes: (json['time_spent_minutes'] as num?)?.toInt(),
      avgAssessmentScore: json['avg_assessment_score'] as num?,
      learningStreakDays: (json['learning_streak_days'] as num?)?.toInt(),
      recentAssessmentScores: (json['recent_assessment_scores'] as List<dynamic>?)
          ?.map((e) => e as num)
          .toList(),
      weeklyActivity: (json['weekly_activity'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$StatsToJson(Stats instance) => <String, dynamic>{
      'general': instance.general,
      'competencies_attained': instance.competenciesAttained,
      'certificates_attained': instance.certificatesAttained,
      'last_login': instance.lastLogin,
      'course_attendance': instance.courseAttendance,
      'time_spent_minutes': instance.timeSpentMinutes,
      'avg_assessment_score': instance.avgAssessmentScore,
      'learning_streak_days': instance.learningStreakDays,
      'recent_assessment_scores': instance.recentAssessmentScores,
      'weekly_activity': instance.weeklyActivity,
    };
