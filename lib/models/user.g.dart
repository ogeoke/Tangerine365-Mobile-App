// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['idst'] as String?,
      username: json['userid'] as String?,
      firstName: json['firstname'] as String?,
      lastName: json['lastname'] as String?,
      email: json['email'] as String,
      profilePicture: json['avatar'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'idst': instance.id,
      'userid': instance.username,
      'firstname': instance.firstName,
      'lastname': instance.lastName,
      'email': instance.email,
      'avatar': instance.profilePicture,
    };
