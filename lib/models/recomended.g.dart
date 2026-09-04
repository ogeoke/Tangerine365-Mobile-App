// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recomended.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recomended _$RecomendedFromJson(Map<String, dynamic> json) => Recomended(
      success: json['success'] as bool,
      enrollment: json['enrollment'] == null
          ? null
          : Enrollment.fromJson(json['enrollment'] as Map<String, dynamic>),
      completed: json['completed'] == null
          ? null
          : Enrollment.fromJson(json['completed'] as Map<String, dynamic>),
      recommended: json['recommended'] == null
          ? null
          : Enrollment.fromJson(json['recommended'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecomendedToJson(Recomended instance) =>
    <String, dynamic>{
      'success': instance.success,
      'enrollment': instance.enrollment,
      'completed': instance.completed,
      'recommended': instance.recommended,
    };
