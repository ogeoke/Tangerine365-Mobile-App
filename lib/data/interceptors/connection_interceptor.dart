import 'package:data_repository/remote/index.dart';
import 'package:flutter/foundation.dart';

// checks if the device is connected to the internet
class ConnectionInterceptor extends ApiInterceptor {
  @override
  ApiRequest<ResponseType, InnerType> onRequest<ResponseType, InnerType>(
      ApiRequest<ResponseType, InnerType> request) {
    if (kDebugMode) print('in ConnectionInterceptor request ${request.uri}');
    // if (ConnectionBloc().state.status == ConnectionStatus.NO_CONNECTION &&
    //     Platform.isAndroid) throw NoInternetException();
    return request;
  }
}

class NoInternetException implements Exception {
  @override
  String toString() => 'NoInternetException';
}
