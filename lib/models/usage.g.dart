// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usage _$UsageFromJson(Map<String, dynamic> json) => Usage(
      lastIp: json['last_ip'] as String?,
      meanDuration: json['mean_duration'] as String?,
      monthMeanDuration: json['month_mean_duration'] as String?,
      weekMeanDuration: json['week_mean_duration'] as String?,
      lastLoginTimestamp: json['last_login_timestamp'] as String?,
      totalLogins: (json['total_logins'] as num?)?.toInt(),
      totalMonthLogins: (json['total_month_logins'] as num?)?.toInt(),
      totalWeekLogins: (json['total_week_logins'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UsageToJson(Usage instance) => <String, dynamic>{
      'last_ip': instance.lastIp,
      'mean_duration': instance.meanDuration,
      'month_mean_duration': instance.monthMeanDuration,
      'week_mean_duration': instance.weekMeanDuration,
      'last_login_timestamp': instance.lastLoginTimestamp,
      'total_logins': instance.totalLogins,
      'total_month_logins': instance.totalMonthLogins,
      'total_week_logins': instance.totalWeekLogins,
    };
