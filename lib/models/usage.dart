import 'package:json_annotation/json_annotation.dart';

part 'usage.g.dart';

@JsonSerializable()
class Usage {
  Usage({
    this.lastIp,
    this.meanDuration,
    this.monthMeanDuration,
    this.weekMeanDuration,
    this.lastLoginTimestamp,
    this.totalLogins,
    this.totalMonthLogins,
    this.totalWeekLogins,
  });

  @JsonKey(name: 'last_ip')
  final String? lastIp;
  @JsonKey(name: 'mean_duration')
  final String? meanDuration;
  @JsonKey(name: 'month_mean_duration')
  final String? monthMeanDuration;
  @JsonKey(name: 'week_mean_duration')
  final String? weekMeanDuration;
  @JsonKey(name: 'last_login_timestamp')
  final String? lastLoginTimestamp;
  @JsonKey(name: 'total_logins')
  final int? totalLogins;
  @JsonKey(name: 'total_month_logins')
  final int? totalMonthLogins;
  @JsonKey(name: 'total_week_logins')
  final int? totalWeekLogins;

  Map<String, dynamic> toJson() => _$UsageToJson(this);

  static Usage fromJson(Map<String, dynamic> json) => _$UsageFromJson(json);
}
