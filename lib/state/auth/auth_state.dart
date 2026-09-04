///created by Wisdom Ekeh ekeh.wisdom@gmail.com
///c 2020 Wed Jan 22

part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  final String? token;
  final bool useBiometrics;
  final User? user;

  const AuthState(this.token, this.user, [this.useBiometrics = false]);

  @override
  List<Object?> get props => [token, user, useBiometrics];
}

/// Initializing app checking login state
class AuthenticationUninitialized extends AuthState {
  const AuthenticationUninitialized() : super(null, null);

  @override
  String toString() => 'AuthenticationUninitialized';
}

class Default extends AuthState {
  const Default(super.token, super.user, [super.useBiometrics]);

  @override
  String toString() => 'Default';
}

/// User is logged in
class Authenticated extends AuthState {
  const Authenticated(super.token, super.user, [super.useBiometrics]);

  @override
  String toString() => 'Authenticated';
}

///user is not logged in
class UnAuthenticated extends AuthState {
  final String? message;

  const UnAuthenticated(User? user, [this.message, bool useBiometrics = false])
      : super(null, user, useBiometrics);
  @override
  String toString() => 'UnAuthenticated';
}
