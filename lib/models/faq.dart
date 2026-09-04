import 'package:json_annotation/json_annotation.dart';

part 'faq.g.dart';

@JsonSerializable()
class Faq {
  Faq({
    required this.id,
    this.title,
    this.description,
  });

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'description')
  final String? description;

  Map<String, dynamic> toJson() => _$FaqToJson(this);

  static Faq fromJson(Map<String, dynamic> json) => _$FaqFromJson(json);
}
