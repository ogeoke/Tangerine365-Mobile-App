import 'package:json_annotation/json_annotation.dart';

part 'can_enter.g.dart';

@JsonSerializable()
class CanEnter {
  CanEnter({
    this.can,
    this.reason,
    this.expiringIn,
  });

  @JsonKey(name: 'can')
  final bool? can;
  @JsonKey(name: 'reason')
  final String? reason;
  @JsonKey(name: 'expiring_in')
  final bool? expiringIn;

  Map<String, dynamic> toJson() => _$CanEnterToJson(this);

  static CanEnter fromJson(Map<String, dynamic> json) =>
      _$CanEnterFromJson(json);
}
