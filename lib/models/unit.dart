import 'package:json_annotation/json_annotation.dart';

part 'unit.g.dart';

@JsonSerializable()
class Unit {
  Unit({
    this.name,
    required this.id,
    this.url,
    this.type,
    this.status,
    this.next,
  });

  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'url')
  final String? url;
  @JsonKey(name: 'type')
  final String? type;
  @JsonKey(name: 'status')
  final String? status;
  final String? next;

  Map<String, dynamic> toJson() => _$UnitToJson(this);

  static Unit fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}
