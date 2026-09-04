import 'package:json_annotation/json_annotation.dart';

import 'completed.dart';

part 'metadata.g.dart';

@JsonSerializable()
class Metadata {
  Metadata({
    this.status,
    this.attempts,
    this.attemptsLeft,
    this.completed,
  });

  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'attempts')
  final int? attempts;
  @JsonKey(name: 'attempts_left')
  final int? attemptsLeft;
  @JsonKey(name: 'completed')
  final Completed? completed;

  Map<String, dynamic> toJson() => _$MetadataToJson(this);

  static Metadata fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);
}
