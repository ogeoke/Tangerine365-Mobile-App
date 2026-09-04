import 'package:json_annotation/json_annotation.dart';

part 'completed.g.dart';

@JsonSerializable()
class Completed {
  Completed({
    this.status,
    this.score,
    this.pending,
  });

  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'score')
  final int? score;
  @JsonKey(name: 'pending')
  final String? pending;

  Map<String, dynamic> toJson() => _$CompletedToJson(this);

  static Completed fromJson(Map<String, dynamic> json) =>
      _$CompletedFromJson(json);
}
