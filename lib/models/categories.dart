import 'package:json_annotation/json_annotation.dart';

part 'categories.g.dart';

@JsonSerializable()
class Categories {
  Categories({
    required this.id,
    required this.name,
  });

  @JsonKey(name: 'categoryId')
  final String id;
  @JsonKey(name: 'categoryName')
  final String name;

  Map<String, dynamic> toJson() => _$CategoriesToJson(this);

  static Categories fromJson(Map<String, dynamic> json) =>
      _$CategoriesFromJson(json);
}
