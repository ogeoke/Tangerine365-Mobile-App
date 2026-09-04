import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/constants/pref_keys.dart';
import 'package:sevenup_mobile/data/local/secure_store.dart';
import 'package:sevenup_mobile/models/user.dart';
import 'package:sevenup_mobile/services/two_factor_api.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:sevenup_mobile/views/login_page.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final String? message;
  final SecureStore _vault = SecureStore();
  final TwoFactorApi _authApi = TwoFactorApi();

  GlobalKey<ExpandContainerState> containerKey = GlobalKey();

  LoginBloc({this.message})
      : super(LoginState(isLoading: false, errorMessage: message)) {
    on<LoadingLoginEvent>((event, emit) {
      state.copyWith(isLoading: true);
    });
    on<LoginPressedEvent>(_mapLoginPressedToState);
    on<LoginBiometricsPressedEvent>(_mapLoginBiometricsPressedToState);
    on<TwoFactorVerifiedEvent>((event, emit) {
      final c = event.challenge;
      _finalize(c.user, c.token, c.username, c.password);
      emit(state.copyWith(isLoading: false));
    });
  }

  Future<void> _mapLoginPressedToState(
    LoginPressedEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final res = await _authApi.authenticate(
      username: event.username,
      password: event.password,
    );

    if (!res.success || res.user == null || res.token == null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'ERROR: ${res.message ?? 'Oops, Something went wrong'}',
      ));
      return;
    }

    // authenticate returns the 2FA challenge directly when it applies.
    if (res.requires2fa) {
      emit(state.copyWith(isLoading: false, challenge: res.challenge));
      return;
    }

    _finalize(res.user!, res.token!, event.username, event.password);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _mapLoginBiometricsPressedToState(
    LoginBiometricsPressedEvent event,
    Emitter<LoginState> emit,
  ) async {
    final username = await _vault.getString(PrefKeys.username);
    final password = await _vault.getString(PrefKeys.password);
    return _mapLoginPressedToState(
      LoginPressedEvent(username ?? '', password ?? ''),
      emit,
    );
  }

  /// Completes sign-in: stores the (now unlocked) token + user and flips
  /// AuthBloc to Authenticated.
  void _finalize(User user, String token, String username, String password) {
    GetIt.I<AuthBloc>().add(LogedIn(user, password, username));
    GetIt.I<AuthBloc>().add(UpdateToken(token));
    _vault.setString(username, PrefKeys.username);
    _vault.setString(password, PrefKeys.password);
    _vault.setString(token, PrefKeys.token);
  }
}
