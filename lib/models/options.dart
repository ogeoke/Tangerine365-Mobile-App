import 'package:json_annotation/json_annotation.dart';

part 'options.g.dart';

@JsonSerializable()
class Options {
  Options({
    this.redoable,
    this.showScore,
  });

  @JsonKey(name: 'redoable')
  final bool? redoable;
  @JsonKey(name: 'show_score')
  final bool? showScore;

  Map<String, dynamic> toJson() => _$OptionsToJson(this);

  static Options fromJson(Map<String, dynamic> json) => _$OptionsFromJson(json);
}
