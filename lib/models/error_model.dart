// library _model;

// import 'dart:convert';

// import 'package:built_value/built_value.dart';
// import 'package:built_value/serializer.dart';
// import 'package:data_repository/data_repository.dart';

// import 'serializers.dart';

// part 'error_model.g.dart';

// abstract class ErrorModel  implements Built<ErrorModel, ErrorModelBuilder> {
//   ErrorModel._();

//   factory ErrorModel([Function(ErrorModelBuilder b) updates]) = _$ErrorModel;
//   // @override
//   // @BuiltValueField(wireName: 'code')
//   // int? get code;
//   @BuiltValueField(wireName: 'message')
//   String get message;

//   String toJson() {
//     return json.encode(serializers.serializeWith(ErrorModel.serializer, this));
//   }

//   static ErrorModel? fromJson(String jsonString) {
//     return serializers.deserializeWith(
//         ErrorModel.serializer, json.decode(jsonString));
//   }

//   static Serializer<ErrorModel> get serializer => _$errorModelSerializer;
// }
