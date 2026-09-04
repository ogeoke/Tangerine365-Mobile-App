// import 'package:chopper/chopper.dart';
import 'package:data_repository/data_repository.dart';
import 'package:sevenup_mobile/constants/app_strings.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class AuthInterceptor extends ApiInterceptor {
  @override
  ApiResponse<ResponseType, InnerType> onError<ResponseType, InnerType>(
      ApiResponse<ResponseType, InnerType> response) {
    if (kDebugMode) {
      print('in auth interceptor response ${response.statusCode}');
    }
    if (response.statusCode == 401 &&
        (response.request.uri.pathSegments.last != 'logout.php' &&
            response.request.uri.pathSegments.last != 'login.php')) {
      GetIt.I<AuthBloc>().add(const LogOut(false, AppStrings.multipleLogins));
    }
    // if ((response.statusCode == 401) &&
    //     GetIt.I<AuthBloc>().state is Authenticated) {
    //   GetIt.I<AuthBloc>().add(const LogOut(clearSaved: false));
    //   Future.delayed(const Duration(milliseconds: 700), () {
    //     showToast('Session expired');
    //   });
    // }
    return response;
  }
}

class InvalidCredentials implements Exception {
  final String message;

  InvalidCredentials(this.message);

  @override
  String toString() => message;
}

class ExpiredAuth implements Exception {
  final String message;

  ExpiredAuth(this.message);

  @override
  String toString() => message;
}
