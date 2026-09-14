// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      userid: json['userid'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      fullname: json['fullname'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      lastEnter: json['last_enter'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      maritalStatus: json['marital_status'] as String?,
      department: json['department'] as String?,
      organizationGrade: json['organization_grade'] as String?,
      yearsInOrg: json['years_in_org'] as String?,
      educationLevel: json['education_level'] as String?,
      discipline: json['discipline'] as String?,
      professionalCert: json['professional_cert'] as String?,
      learningInterest: json['learning_interest'] as String?,
      hobby: json['hobby'] as String?,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'userid': instance.userid,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'fullname': instance.fullname,
      'email': instance.email,
      'avatar': instance.avatar,
      'last_enter': instance.lastEnter,
      'date_of_birth': instance.dateOfBirth,
      'marital_status': instance.maritalStatus,
      'department': instance.department,
      'organization_grade': instance.organizationGrade,
      'years_in_org': instance.yearsInOrg,
      'education_level': instance.educationLevel,
      'discipline': instance.discipline,
      'professional_cert': instance.professionalCert,
      'learning_interest': instance.learningInterest,
      'hobby': instance.hobby,
    };
