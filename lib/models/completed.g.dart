// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Completed _$CompletedFromJson(Map<String, dynamic> json) => Completed(
      status: json['status'] as String?,
      score: (json['score'] as num?)?.toInt(),
      pending: json['pending'] as String?,
    );

Map<String, dynamic> _$CompletedToJson(Completed instance) => <String, dynamic>{
      'status': instance.status,
      'score': instance.score,
      'pending': instance.pending,
    };
