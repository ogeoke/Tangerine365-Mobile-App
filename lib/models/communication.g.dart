// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Communication _$CommunicationFromJson(Map<String, dynamic> json) =>
    Communication(
      totalSize: (json['total_size'] as num?)?.toInt(),
      forumLastMessage: json['forum_last_message'] as String,
      numberForumMessages: (json['number_forum_messages'] as num?)?.toInt(),
      numberPersonalMessages:
          (json['number_personal_messages'] as num?)?.toInt(),
      numberPersonalFolders: (json['number_personal_folders'] as num?)?.toInt(),
      numberFiles: (json['number_files'] as num?)?.toInt(),
      numberComments: (json['number_comments'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CommunicationToJson(Communication instance) =>
    <String, dynamic>{
      'total_size': instance.totalSize,
      'forum_last_message': instance.forumLastMessage,
      'number_forum_messages': instance.numberForumMessages,
      'number_personal_messages': instance.numberPersonalMessages,
      'number_personal_folders': instance.numberPersonalFolders,
      'number_files': instance.numberFiles,
      'number_comments': instance.numberComments,
    };
