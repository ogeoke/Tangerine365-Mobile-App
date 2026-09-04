part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoadingLoginEvent extends LoginEvent {
  @override
  String toString() {
    if (kDebugMode) print('LoadingLoginEvent');
    return super.toString();
  }
}

class LoginPressedEvent extends LoginEvent {
  final String username;
  final String password;

  LoginPressedEvent(this.username, this.password);
  @override
  String toString() {
    if (kDebugMode) {
      print('''LoginPressedEvent: 
   { username: $username,
     password: $password
    }''');
    }
    return super.toString();
  }
}

class LoginBiometricsPressedEvent extends LoginEvent {
  @override
  String toString() {
    if (kDebugMode) print('LoginBiometricsPressedEvent');
    return super.toString();
  }
}

/// Dispatched after the 2FA code is verified, to finalize sign-in.
class TwoFactorVerifiedEvent extends LoginEvent {
  final TwoFactorChallenge challenge;
  TwoFactorVerifiedEvent(this.challenge);
}
