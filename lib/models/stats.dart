import 'package:json_annotation/json_annotation.dart';

import 'general.dart';
import 'learning.dart';

part 'stats.g.dart';

@JsonSerializable()
class Stats {
  Stats({
    this.general,
    this.competenciesAttained,
    this.certificatesAttained,
    this.lastLogin,
    this.courseAttendance,
  });

  @JsonKey(name: 'general')
  final General? general;
  @JsonKey(name: 'competencies_attained')
  final int? competenciesAttained;
  @JsonKey(name: 'certificates_attained')
  final int? certificatesAttained;
  @JsonKey(name: 'last_login')
  final String? lastLogin;
  @JsonKey(name: 'course_attendance')
  final Learning? courseAttendance;

  Map<String, dynamic> toJson() => _$StatsToJson(this);

  static Stats fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);
}
