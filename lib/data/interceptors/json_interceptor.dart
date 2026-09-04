import 'dart:convert';

import 'package:data_repository/data_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:sevenup_mobile/models/error_model/error_model.dart';

import '../../models/assigned_course.dart';
import '../../models/banners.dart';
import '../../models/can_enter.dart';
import '../../models/categories.dart';
import '../../models/communication.dart';
import '../../models/completed.dart';
// Import all the model classes that might be used
import '../../models/course.dart';
import '../../models/course_item.dart';
import '../../models/course_module.dart';
import '../../models/course_progress.dart';
import '../../models/course_stats.dart';
import '../../models/enrollment.dart';
import '../../models/faq.dart';
import '../../models/general.dart';
import '../../models/learning.dart';
import '../../models/metadata.dart';
import '../../models/options.dart';
import '../../models/progress.dart';
import '../../models/recomended.dart';
import '../../models/settings.dart';
import '../../models/stats.dart';
import '../../models/test.dart';
import '../../models/unit.dart';
import '../../models/usage.dart';
import '../../models/user.dart';

class JsonInterceptor<ErrorType> implements ApiInterceptor {
  static T? _deserialize<T>(dynamic value) {
    if (value is T) return value;

    // Handle Map<String, dynamic> conversion using fromJson methods
    if (value is Map<String, dynamic>) {
      return _fromJsonMap<T>(value);
    }

    return null;
  }

  static T? _fromJsonMap<T>(Map<String, dynamic> json) {
    switch (T) {
      case const (Course):
        return Course.fromJson(json) as T?;
      case const (User):
        return User.fromJson(json) as T?;
      case const (Enrollment):
        return Enrollment.fromJson(json) as T?;
      case const (Banners):
        return Banners.fromJson(json) as T?;
      case const (Categories):
        return Categories.fromJson(json) as T?;
      case const (General):
        return General.fromJson(json) as T?;
      case const (Learning):
        return Learning.fromJson(json) as T?;
      case const (Stats):
        return Stats.fromJson(json) as T?;
      case const (Settings):
        return Settings.fromJson(json) as T?;
      case const (Recomended):
        return Recomended.fromJson(json) as T?;
      case const (Faq):
        return Faq.fromJson(json) as T?;
      case const (AssignedCourse):
        return AssignedCourse.fromJson(json) as T?;
      case const (CourseItem):
        return CourseItem.fromJson(json) as T?;
      case const (CourseModule):
        return CourseModule.fromJson(json) as T?;
      case const (CourseProgress):
        return CourseProgress.fromJson(json) as T?;
      case const (CourseStats):
        return CourseStats.fromJson(json) as T?;
      case const (CanEnter):
        return CanEnter.fromJson(json) as T?;
      case const (Communication):
        return Communication.fromJson(json) as T?;
      case const (Completed):
        return Completed.fromJson(json) as T?;
      case const (Metadata):
        return Metadata.fromJson(json) as T?;
      case const (Options):
        return Options.fromJson(json) as T?;
      case const (Progress):
        return Progress.fromJson(json) as T?;
      case const (Test):
        return Test.fromJson(json) as T?;
      case const (Unit):
        return Unit.fromJson(json) as T?;
      case const (Usage):
        return Usage.fromJson(json) as T?;
      case const (ErrorModel):
        return ErrorModel.fromJson(json) as T?;
      default:
        return null;
    }
  }

  static List<T> _deserializeListOf<T>(
    Iterable value,
  ) =>
      value.map((value) => _deserialize<T>(value)).whereType<T>().toList();

  static dynamic _decode<T>(entity) {
    try {
      if (entity is List) return _deserializeListOf<T>(entity);
      return _deserialize<T>(entity);
    } catch (e, trace) {
      if (kDebugMode) print('JsonInterceptor:_decode $e, $trace');
      return null;
    }
  }

  static dynamic _getBody(dynamic body, [String? key = '']) {
    if (kDebugMode) print('get body, $key');
    try {
      if (key == null || key == '') return body;
      return body[key] ?? body;
    } catch (e) {
      return body;
    }
  }

  ///convert a  json string  to a model  with type [ResultType]
  static ResultType? convertFromJson<ResultType, Item>(dynamic data,
      [String? key]) {
    try {
      if (data is String) data = json.decode(data);
    } catch (e) {
      if (kDebugMode) print('JsonInterceptor:convertFromJson $e');
    }
    if (kDebugMode) print('in convert fromjson $key, $data');
    return _decode<Item>(_getBody(data, key));
  }

  ///convert a value to a json encoded string
  static dynamic convertToJson(dynamic data) {
    return json.encode(_encode(data));
  }

  static dynamic _serialize<T>(dynamic value) {
    if (value == null) return null;

    // Handle objects with toJson methods
    if (value is Course) return value.toJson();
    if (value is User) return value.toJson();
    if (value is Enrollment) return value.toJson();
    if (value is Banners) return value.toJson();
    if (value is Categories) return value.toJson();
    if (value is General) return value.toJson();
    if (value is Learning) return value.toJson();
    if (value is Stats) return value.toJson();
    if (value is Settings) return value.toJson();
    if (value is Recomended) return value.toJson();
    if (value is Faq) return value.toJson();
    if (value is AssignedCourse) return value.toJson();
    if (value is CourseItem) return value.toJson();
    if (value is CourseModule) return value.toJson();
    if (value is CourseProgress) return value.toJson();
    if (value is CourseStats) return value.toJson();
    if (value is CanEnter) return value.toJson();
    if (value is Communication) return value.toJson();
    if (value is Completed) return value.toJson();
    if (value is Metadata) return value.toJson();
    if (value is Options) return value.toJson();
    if (value is Progress) return value.toJson();
    if (value is Test) return value.toJson();
    if (value is Unit) return value.toJson();
    if (value is Usage) return value.toJson();
    if (value is ErrorModel) return value.toJson();

    return value;
  }

  static List<T> _serializeListOf<T>(List value) => List.castFrom(
        value.map((value) => _serialize<T>(value)).toList(growable: false),
      );

  static dynamic _encode<T>(entity) {
    if (entity is String) return entity;

    try {
      if (entity is List) return _serializeListOf<T>(entity);
      return _serialize<T>(entity);
    } catch (e) {
      if (kDebugMode) print('JsonInterceptor:_encode $e');
      return null;
    }
  }

  @override
  ApiResponse<ResponseType, InnerType> onResponse<ResponseType, InnerType>(
      ApiResponse<ResponseType, InnerType> response) {
    Pagination? pagination;
    if (kDebugMode) {
      // Log.d(
      //     'in convert response ${response.request.path} ${response.statusCode} ${response.bodyString.runtimeType}, ${response.bodyString}');
    }
    if (response.body != null) {
      return response.copyWith(body: response.body);
    }

    var jsn = _tryDecodeJson(response.bodyString);
    // var body;
    if (kDebugMode) {
      // Log.d(
      //     'in convert response ${jsn.runtimeType}, ${response.request.nestedKey} $jsn');
    }

    if (response.request.nestedKey != null) {
      jsn = _getBody(jsn, 'data') as Map<String, dynamic>;
    }

    final body = _decode<InnerType>(_getBody(jsn, response.request.dataKey));
    // if (kDebugMode) Log.d(body?.toString());

    return response.copyWith(body: body, pagination: pagination);
  }

  dynamic _tryDecodeJson(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (kDebugMode) print(data.runtimeType);
    try {
      return jsonDecode(data.toString());
    } catch (e) {
      if (kDebugMode) print('JsonInterceptor:_tryDecodeJson $e, ');
      return data;
    }
  }

  @override
  ApiResponse<ResponseType, InnerType> onError<ResponseType, InnerType>(
      ApiResponse<ResponseType, InnerType> response) {
    if (kDebugMode) {
      print(
          'in convert error  ${response.request.path}   ${response.bodyString}');
    }
    var json = _tryDecodeJson(response.bodyString);
    // if(kDebugMode)print(_getBody(json, response?.request?.error?.key));

    try {
      final body =
          _decode<ErrorModel>(_getBody(json, response.request.error?.key));
      if (kDebugMode) print(body);
      return response.copyWith(
          error: body ??
              ErrorModel(
                  message:
                      json?['error'].toString() ?? 'Something went wrong'));
    } catch (e, trace) {
      if (kDebugMode) {
        print(
            'JsonInterceptor:onError  ${response.request.path}  ${response.request.baseUrl},   ${response.bodyString}, $e, $trace');
      }
      return response.copyWith(
          error: ErrorModel(
              message: json?['error']?.toString() ?? 'Something went wrong'));
    }
  }

  @override
  ApiRequest<ResponseType, InnerType> onRequest<ResponseType, InnerType>(
      ApiRequest<ResponseType, InnerType> request) {
    return request;
  }
}
