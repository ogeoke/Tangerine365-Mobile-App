import 'package:data_repository/data_repository.dart';
import 'package:flutter/foundation.dart';

import 'json_interceptor.dart';

class TokenInterceptor extends ApiInterceptor {
  static const accessToken = 'token';

  @override
  ApiResponse<ResponseType, InnerType> onResponse<ResponseType, InnerType>(
      ApiResponse<ResponseType, InnerType> response) {
    if (kDebugMode) print('in TokenInterceptor ${response.statusCode}');
    if (response.isSuccessful) {
      var token = JsonInterceptor.convertFromJson<String, String>(
          response.bodyString, accessToken);

      if (kDebugMode) {
        print('in TokenInterceptor    $token, ${response.bodyString}');
      }

      return response.copyWith(extra: <String, dynamic>{
        // refreshToken: refresh,
        accessToken: token,
        ...?response.extra
      });
    }

    return response;
  }
}
