// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Metadata _$MetadataFromJson(Map<String, dynamic> json) => Metadata(
      status: json['status'] as String?,
      attempts: (json['attempts'] as num?)?.toInt(),
      attemptsLeft: (json['attempts_left'] as num?)?.toInt(),
      completed: json['completed'] == null
          ? null
          : Completed.fromJson(json['completed'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
      'status': instance.status,
      'attempts': instance.attempts,
      'attempts_left': instance.attemptsLeft,
      'completed': instance.completed,
    };
