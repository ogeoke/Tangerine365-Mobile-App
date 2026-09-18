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
    this.enableForgotPassword,
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

  /// Admin switch for "Forgot password?" on the login screen. Hidden unless
  /// the backend explicitly sends it as on.
  @JsonKey(name: 'enable_forgot_password')
  final String? enableForgotPassword;

  bool get forgotPasswordEnabled {
    final v = enableForgotPassword?.trim().toLowerCase();
    return v == 'true' || v == '1' || v == 'yes' || v == 'on';
  }

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static Settings fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}
