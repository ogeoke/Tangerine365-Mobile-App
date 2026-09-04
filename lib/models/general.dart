import 'package:json_annotation/json_annotation.dart';

part 'general.g.dart';

@JsonSerializable()
class General {
  General({
    this.login,
    this.name,
    this.surname,
    this.fullname,
    this.userType,
    this.userTypesID,
    this.totalLessons,
    this.totalCourses,
    this.language,
    this.active,
    this.activeStr,
    this.joined,
    this.joinedStr,
    this.avatar,
    this.totalLoginTimeUnformated,
    this.totalLoginTime,
    this.memberSince,
  });

  @JsonKey(name: 'login')
  final String? login;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'surname')
  final String? surname;
  @JsonKey(name: 'fullname')
  final String? fullname;
  @JsonKey(name: 'user_type')
  final String? userType;
  @JsonKey(name: 'user_types_ID')
  final String? userTypesID;
  @JsonKey(name: 'total_lessons')
  final int? totalLessons;
  @JsonKey(name: 'total_courses')
  final int? totalCourses;
  @JsonKey(name: 'language')
  final String? language;
  @JsonKey(name: 'active')
  final String? active;
  @JsonKey(name: 'active_str')
  final String? activeStr;
  @JsonKey(name: 'joined')
  final String? joined;
  @JsonKey(name: 'joined_str')
  final String? joinedStr;
  @JsonKey(name: 'avatar')
  final String? avatar;
  @JsonKey(name: 'total_login_time_unformated')
  final int? totalLoginTimeUnformated;
  @JsonKey(name: 'total_login_time')
  final String? totalLoginTime;
  @JsonKey(name: 'member_since')
  final String? memberSince;

  Map<String, dynamic> toJson() => _$GeneralToJson(this);

  static General fromJson(Map<String, dynamic> json) => _$GeneralFromJson(json);
}
