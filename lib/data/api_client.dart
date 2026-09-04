import 'package:data_repository/data_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../constants/env.dart';
import '../state/auth/auth_bloc.dart';
import 'interceptors/network_duration_interceptor.dart';
import 'session_store.dart';

class ApiClient {
  static var env = GetIt.I.get<Env>();
  static ApiRequest<ResponseType, InnerType>
      baseRequest<ResponseType, InnerType>({String? requestId}) =>
          ApiRequest<ResponseType, InnerType>(
            baseUrl: '${env.baseUrl}/api',
            requestId: requestId,
            dataKey: 'data',
            interceptors: [
              HeaderInterceptor(
                kIsWeb
                    ? {
                        'Authorization':
                            'Bearer ${GetIt.I<AuthBloc>().state.token}',
                        'X-Requested-From': 'MobileApp',

                        // "Content-Type": "application/json",
                        // "Accept": "application/json",
                      }
                    : {
                        'Authorization':
                            'Bearer ${GetIt.I<AuthBloc>().state.token}',
                        "Content-Type": "application/json",
                        "Accept": "application/json",
                        'X-Requested-From': 'MobileApp',
                        if (SessionStore.instance.cookie != null)
                          'Cookie': SessionStore.instance.cookie!,
                      },
              ),
              NetworkDurationInterceptor(),
            ],
          );
  static ApiRequest<ResponseType, InnerType>
      baseRequestNoAuth<ResponseType, InnerType>() =>
          ApiRequest<ResponseType, InnerType>(
            baseUrl: '${env.baseUrl}/api',
            dataKey: 'data',
            interceptors: [
              HeaderInterceptor(
                kIsWeb
                    ? {
                        "Accept": "application/json",
                        'X-Requested-From': 'MobileApp'
                      }
                    : {
                        "Content-Type": "application/json",
                        "Accept": "application/json",
                        'X-Requested-From': 'MobileApp',
                      },
              ),
              NetworkDurationInterceptor(),
            ],
          );
}
