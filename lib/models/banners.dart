import 'package:json_annotation/json_annotation.dart';

part 'banners.g.dart';

@JsonSerializable()
class Banners {
  Banners({
    required this.id,
    this.title,
    this.imagePath,
    this.link,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.bannerUrl,
  });

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'image_path')
  final String? imagePath;
  @JsonKey(name: 'link')
  final String? link;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'banner_url')
  final String? bannerUrl;

  Map<String, dynamic> toJson() => _$BannersToJson(this);

  static Banners fromJson(Map<String, dynamic> json) => _$BannersFromJson(json);
}
