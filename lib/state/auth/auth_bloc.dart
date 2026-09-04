/// created by Wisdom Ekeh ekeh.wisdom@gmail.com
/// c 2020 Wed Jan 22
library;

import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/common/app_dialog.dart';
import 'package:sevenup_mobile/constants/pref_keys.dart';
import 'package:sevenup_mobile/data/interceptors/json_interceptor.dart';
import 'package:sevenup_mobile/data/local/secure_store.dart';
import 'package:sevenup_mobile/data/sharedpref_manager.dart';
import 'package:sevenup_mobile/main.dart';
import 'package:sevenup_mobile/models/user.dart';

import '../../data/api_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// final Auth = AuthBloc();

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static final AuthBloc _authBlocSingleton = AuthBloc._internal();
  final SecureStore _vault = SecureStore();
  // final BuiltvalueConverter converter = BuiltvalueConverter();
  final _repository = ApiRepository();

  factory AuthBloc() => _authBlocSingleton;
  bool alreadyShownPopup = true;

  AuthBloc._internal() : super(const AuthenticationUninitialized()) {
    on<AppStarted>((event, emit) async {
      // final token = await _vault.getString(PrefKeys.token);
      final usr = await _vault.getString(PrefKeys.user);
      // var username = await _vault.getString(PrefKeys.USERNAME);
      // var password = await _vault.getString(PrefKeys.PASSWORD);
      bool biometricsEnabled = await SharedPreferenceManager().getBoolData(
        PrefKeys.biometrics,
        false,
      );

      var user = JsonInterceptor.convertFromJson<User, User>(usr);
      if (user != null) {
        emit(UnAuthenticated(user, null, (biometricsEnabled)));
      } else {
        emit(UnAuthenticated(null, null, (biometricsEnabled)));
      }
    });

    on<LogedIn>((event, emit) async {
      alreadyShownPopup = false;
      bool biometricsEnabled = await SharedPreferenceManager().getBoolData(
        PrefKeys.biometrics,
        false,
      );
      emit(Authenticated(state.token ?? '', event.user, biometricsEnabled));
      // print(jsonEncode(event.user.toJson()));
      _vault.setString(PrefKeys.user, jsonEncode(event.user.toJson()));
      _vault.setString(PrefKeys.password, event.password);
      _vault.setString(PrefKeys.username, event.username);
    });

    on<UpdateToken>((event, emit) {
      emit(Authenticated(event.token, state.user!, state.useBiometrics));
      _vault.setString(event.token, PrefKeys.token);
    });

    on<SetBiometrics>((event, emit) async {
      bool val = (state.useBiometrics);
      // print(val);
      emit(Default(state.token ?? '', state.user!, !val));
      await SharedPreferenceManager().setBoolData(PrefKeys.biometrics, !val);
    });

    on<LogOut>((event, emit) {
      _repository.logout();
      emit(
        UnAuthenticated(
          event.deleteSaved ? null : state.user,
          event.message,
          state.useBiometrics,
        ),
      );
      if (event.deleteSaved) {
        _vault.deleteKey(PrefKeys.token);
        _vault.deleteKey(PrefKeys.user);
      }
      if (!alreadyShownPopup && event.message?.isNotEmpty == true) {
        alreadyShownPopup = true;
        Future.delayed(
          const Duration(milliseconds: 1000),
          () => AppDialog.buildErrorDialog(
            App.navigatorKey.currentContext!,
            event.message ?? '',
          ),
        );
      }
    });
  }
}
