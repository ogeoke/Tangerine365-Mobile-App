// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      appName: json['app_name'] as String,
      appDescription: json['app_description'] as String,
      appSupportEmail: json['app_support_email'] as String?,
      enableBanner: json['enable_banner'] as String?,
      maintenanceMode: json['maintenance_mode'] as String?,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'app_name': instance.appName,
      'app_description': instance.appDescription,
      'app_support_email': instance.appSupportEmail,
      'enable_banner': instance.enableBanner,
      'maintenance_mode': instance.maintenanceMode,
    };
