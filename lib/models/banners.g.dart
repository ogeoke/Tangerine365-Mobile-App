// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banners.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Banners _$BannersFromJson(Map<String, dynamic> json) => Banners(
      id: json['id'] as String,
      title: json['title'] as String?,
      imagePath: json['image_path'] as String?,
      link: json['link'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      bannerUrl: json['banner_url'] as String?,
    );

Map<String, dynamic> _$BannersToJson(Banners instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image_path': instance.imagePath,
      'link': instance.link,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'banner_url': instance.bannerUrl,
    };
