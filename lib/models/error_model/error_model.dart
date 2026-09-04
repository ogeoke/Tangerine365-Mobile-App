import 'package:data_repository/data_repository.dart';
import 'package:json_annotation/json_annotation.dart';

part 'error_model.g.dart';

@JsonSerializable()
class ErrorModel implements ApiError {
  ErrorModel({
    required this.message,
  });

  @override
  @JsonKey(name: 'message')
  final String message;

  @override
  int get code => 100;

  Map<String, dynamic> toJson() => _$ErrorModelToJson(this);

  static ErrorModel fromJson(Map<String, dynamic> json) =>
      _$ErrorModelFromJson(json);
}
