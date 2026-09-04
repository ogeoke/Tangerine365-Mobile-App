// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Progress _$ProgressFromJson(Map<String, dynamic> json) => Progress(
      total: (json['total'] as num?)?.toInt(),
      completed: (json['completed'] as num?)?.toInt(),
      percentage: (json['percentage'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProgressToJson(Progress instance) => <String, dynamic>{
      'total': instance.total,
      'completed': instance.completed,
      'percentage': instance.percentage,
    };
