///created by Wisdom Ekeh ekeh.wisdom@gmail.com
///c 2020 Wed Jan 22

// import 'package:equatable/equatable.dart';
// import 'package:meta/meta.dart';
// import 'package:sevenup_mobile/models/user.dart';
part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AppStarted extends AuthEvent {
  @override
  String toString() => 'AppStarted';
}

class UpdateUser extends AuthEvent {
  final User user;

  const UpdateUser(this.user);

  @override
  String toString() => 'UpdateUser';
}

class SetBiometrics extends AuthEvent {
  @override
  String toString() => 'SetBiometrics';
}

class UpdateToken extends AuthEvent {
  final String token;

  const UpdateToken(this.token);

  @override
  String toString() => 'UpdateToken';
}

class LogedIn extends AuthEvent {
  final User user;
  final String password, username;

  const LogedIn(this.user, this.password, this.username);

  @override
  String toString() => 'LogedIn';
}

class LogOut extends AuthEvent {
  final String? message;
  final bool deleteSaved;

  const LogOut(this.deleteSaved, [this.message]);
  @override
  String toString() => 'LogOut';
}
