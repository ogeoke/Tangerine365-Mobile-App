import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// The LMS returns `idst` as a string on some endpoints and a number on others
/// (e.g. authenticate/profile now send `11840` as an int). Coerce to String so
/// parsing never throws on a numeric id.
String? _idstToString(Object? v) => v?.toString();

@JsonSerializable()
class User {
  User({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    required this.email,
    this.profilePicture,
  });

  @JsonKey(name: 'idst', fromJson: _idstToString)
  final String? id;
  @JsonKey(name: 'userid')
  final String? username;
  @JsonKey(name: 'firstname')
  final String? firstName;
  @JsonKey(name: 'lastname')
  final String? lastName;
  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'avatar')
  final String? profilePicture;

  Map<String, dynamic> toJson() => _$UserToJson(this);

  static User fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
