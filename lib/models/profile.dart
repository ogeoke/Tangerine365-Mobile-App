import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

/// Extended learner profile from `POST /api/profile` (the `data` object).
///
/// All fields are optional display strings; the endpoint returns core account
/// details plus fields from `core_user_profiledetail`. Missing/empty values are
/// rendered as "—" by the Profile screen. `idst`/`valid`/`custom_fields` are
/// intentionally omitted — the screen only needs the display fields below, and
/// their types vary across the LMS endpoints.
@JsonSerializable()
class Profile {
  Profile({
    this.userid,
    this.firstname,
    this.lastname,
    this.fullname,
    this.email,
    this.avatar,
    this.lastEnter,
    this.dateOfBirth,
    this.maritalStatus,
    this.department,
    this.organizationGrade,
    this.yearsInOrg,
    this.educationLevel,
    this.discipline,
    this.professionalCert,
    this.learningInterest,
    this.hobby,
  });

  @JsonKey(name: 'userid')
  final String? userid;
  @JsonKey(name: 'firstname')
  final String? firstname;
  @JsonKey(name: 'lastname')
  final String? lastname;
  @JsonKey(name: 'fullname')
  final String? fullname;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'avatar')
  final String? avatar;
  @JsonKey(name: 'last_enter')
  final String? lastEnter;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  @JsonKey(name: 'marital_status')
  final String? maritalStatus;
  @JsonKey(name: 'department')
  final String? department;
  @JsonKey(name: 'organization_grade')
  final String? organizationGrade;
  @JsonKey(name: 'years_in_org')
  final String? yearsInOrg;
  @JsonKey(name: 'education_level')
  final String? educationLevel;
  @JsonKey(name: 'discipline')
  final String? discipline;
  @JsonKey(name: 'professional_cert')
  final String? professionalCert;
  @JsonKey(name: 'learning_interest')
  final String? learningInterest;
  @JsonKey(name: 'hobby')
  final String? hobby;

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  static Profile fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
