// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'can_enter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CanEnter _$CanEnterFromJson(Map<String, dynamic> json) => CanEnter(
      can: json['can'] as bool?,
      reason: json['reason'] as String?,
      expiringIn: json['expiring_in'] as bool?,
    );

Map<String, dynamic> _$CanEnterToJson(CanEnter instance) => <String, dynamic>{
      'can': instance.can,
      'reason': instance.reason,
      'expiring_in': instance.expiringIn,
    };
