import 'package:json_annotation/json_annotation.dart';

part 'communication.g.dart';

@JsonSerializable()
class Communication {
  Communication({
    this.totalSize,
    required this.forumLastMessage,
    this.numberForumMessages,
    this.numberPersonalMessages,
    this.numberPersonalFolders,
    this.numberFiles,
    this.numberComments,
  });

  @JsonKey(name: 'total_size')
  final int? totalSize;
  @JsonKey(name: 'forum_last_message')
  final String forumLastMessage;
  @JsonKey(name: 'number_forum_messages')
  final int? numberForumMessages;
  @JsonKey(name: 'number_personal_messages')
  final int? numberPersonalMessages;
  @JsonKey(name: 'number_personal_folders')
  final int? numberPersonalFolders;
  @JsonKey(name: 'number_files')
  final int? numberFiles;
  @JsonKey(name: 'number_comments')
  final int? numberComments;

  Map<String, dynamic> toJson() => _$CommunicationToJson(this);

  static Communication fromJson(Map<String, dynamic> json) =>
      _$CommunicationFromJson(json);
}
