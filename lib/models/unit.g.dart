// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
      name: json['name'] as String?,
      id: json['id'] as String,
      url: json['url'] as String?,
      type: json['type'] as String?,
      status: json['status'] as String?,
      next: json['next'] as String?,
    );

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'url': instance.url,
      'type': instance.type,
      'status': instance.status,
      'next': instance.next,
    };
