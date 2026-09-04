// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Test _$TestFromJson(Map<String, dynamic> json) => Test(
      id: json['id'] as String,
      name: json['name'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      options: json['options'] == null
          ? null
          : Options.fromJson(json['options'] as Map<String, dynamic>),
      metadata: json['metadata'] == null
          ? null
          : Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TestToJson(Test instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'duration': instance.duration,
      'options': instance.options,
      'metadata': instance.metadata,
    };
