import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

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

  @JsonKey(name: 'idst')
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
