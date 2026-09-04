import 'package:data_repository/data_repository.dart';
import 'package:flutter/foundation.dart';

class NetworkDurationInterceptor extends ApiInterceptor {
  Map<String, int> timestamp = {};
  // final AnalyticsService analyticsService = GetIt.I<AnalyticsService>();

  @override
  ApiResponse<ResponseType, InnerType> onResponse<ResponseType, InnerType>(
      ApiResponse<ResponseType, InnerType> response) {
    return _handleResponse(response, false);
  }

  @override
  ApiRequest<ResponseType, InnerType> onRequest<ResponseType, InnerType>(
      ApiRequest<ResponseType, InnerType> request) {
    timestamp
        .addAll({request.requestId: DateTime.now().millisecondsSinceEpoch});

    // analyticsService.logEvent(AnalyticsEvents.networkRequestStart,
    //     {'request_path': request.path, 'request_method': request.method});
    return request;
  }

  @override
  ApiResponse<ResponseType, InnerType> onError<ResponseType, InnerType>(
      ApiResponse<ResponseType, InnerType> response) {
    return _handleResponse(response, true);
  }

  ApiResponse<ResponseType, InnerType> _handleResponse<ResponseType, InnerType>(
      ApiResponse<ResponseType, InnerType> response, bool hasError) {
    var duration = DateTime.now().millisecondsSinceEpoch -
        (timestamp.remove(response.request.requestId) ?? 00);

    if (kDebugMode) {
      if (hasError) {
        print('request completed with error in $duration milliseconds');
      } else {
        print('request completed successfully in $duration milliseconds');
      }
    }

    // analyticsService.logEvent(AnalyticsEvents.networkRequestEnd, {
    //   'request_path': response.request.path,
    //   'request_method': response.request.method,
    //   'status_code': response.statusCode,
    // });

    // analyticsService.logEvent(AnalyticsEvents.networkRequestDuration, {
    //   'duration': duration,
    //   'request_path': response.request.path,
    //   'request_method': response.request.method,
    //   'status_code': response.statusCode,
    // });

    return response.copyWith(extra: {...?response.extra, 'duration': duration});
  }
}
