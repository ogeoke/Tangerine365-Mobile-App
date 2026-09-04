import 'package:json_annotation/json_annotation.dart';

import 'metadata.dart';
import 'options.dart';

part 'test.g.dart';

@JsonSerializable()
class Test {
  Test({
    required this.id,
    this.name,
    this.duration,
    this.options,
    this.metadata,
  });

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(name: 'options')
  final Options? options;
  @JsonKey(name: 'metadata')
  final Metadata? metadata;

  Map<String, dynamic> toJson() => _$TestToJson(this);

  static Test fromJson(Map<String, dynamic> json) => _$TestFromJson(json);
}
