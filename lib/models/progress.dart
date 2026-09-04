import 'package:json_annotation/json_annotation.dart';

part 'progress.g.dart';

@JsonSerializable()
class Progress {
  Progress({
    this.total,
    this.completed,
    this.percentage,
  });

  @JsonKey(name: 'total')
  final int? total;
  @JsonKey(name: 'completed')
  final int? completed;
  @JsonKey(name: 'percentage')
  final int? percentage;

  Map<String, dynamic> toJson() => _$ProgressToJson(this);

  static Progress fromJson(Map<String, dynamic> json) =>
      _$ProgressFromJson(json);
}
