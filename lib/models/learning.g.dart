// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Learning _$LearningFromJson(Map<String, dynamic> json) => Learning(
      subscribed: (json['subscribed'] as num?)?.toInt(),
      totalCourses: (json['total_courses'] as num?)?.toInt(),
      waiting: (json['waiting'] as num?)?.toInt(),
      subscriptionToConfirm: (json['subscription_to_confirm'] as num?)?.toInt(),
      notStarted: (json['not-started'] as num?)?.toInt(),
      inProgress: (json['in-progress'] as num?)?.toInt(),
      completed: (json['completed'] as num?)?.toInt(),
      suspended: (json['suspended'] as num?)?.toInt(),
      overbooking: (json['overbooking'] as num?)?.toInt(),
      others: (json['others'] as num?)?.toInt(),
      totalNoCourseCatalog: (json['total_no_course_catalog'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LearningToJson(Learning instance) => <String, dynamic>{
      'subscribed': instance.subscribed,
      'total_courses': instance.totalCourses,
      'waiting': instance.waiting,
      'subscription_to_confirm': instance.subscriptionToConfirm,
      'not-started': instance.notStarted,
      'in-progress': instance.inProgress,
      'completed': instance.completed,
      'suspended': instance.suspended,
      'overbooking': instance.overbooking,
      'others': instance.others,
      'total_no_course_catalog': instance.totalNoCourseCatalog,
    };
