import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings {
  Settings({
    required this.appName,
    required this.appDescription,
    this.appSupportEmail,
    this.enableBanner,
    this.maintenanceMode,
  });

  @JsonKey(name: 'app_name')
  final String appName;
  @JsonKey(name: 'app_description')
  final String appDescription;
  @JsonKey(name: 'app_support_email')
  final String? appSupportEmail;
  @JsonKey(name: 'enable_banner')
  final String? enableBanner;
  @JsonKey(name: 'maintenance_mode')
  final String? maintenanceMode;

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static Settings fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}
