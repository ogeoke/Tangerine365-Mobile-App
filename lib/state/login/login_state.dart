part of 'login_bloc.dart';

class LoginState extends Equatable {
  final String? username;
  final String? password;
  final String? errorMessage;
  final bool isLoading;

  /// Set when the account requires 2FA — the UI navigates to verification.
  final TwoFactorChallenge? challenge;

  const LoginState(
      {this.isLoading = false,
      this.username,
      this.password,
      this.errorMessage,
      this.challenge});

  @override
  List<Object?> get props =>
      ([username, password, errorMessage, isLoading, challenge]);

  LoginState copyWith(
          {String? username,
          String? password,
          String? errorMessage,
          bool? isLoading,
          TwoFactorChallenge? challenge}) =>
      LoginState(
          username: username ?? this.username,
          password: password ?? this.password,
          errorMessage: errorMessage,
          isLoading: isLoading ?? false,
          challenge: challenge);

  @override
  String toString() {
    if (kDebugMode) {
      print('''LoginState:
   { username: $username,
     password: $password,
     errorMessage: $errorMessage,
     isLoading: $isLoading,
     challenge: ${challenge?.method}
    }''');
    }
    return super.toString();
  }
}
