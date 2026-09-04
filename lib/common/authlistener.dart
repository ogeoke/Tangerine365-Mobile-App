import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthListener extends StatelessWidget {
  final Widget child;
  final Widget? page;
  final Function()? onAuthenticated;

  const AuthListener(
      {super.key, this.page, required this.child, this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // if(state is Authenticated && !(page is DashboardPage)){
          //    Navigator.pushReplacementNamed(context, DashboardPage.routeName);
          // } else
          if (state is UnAuthenticated) {
            Navigator.of(context)
                .popUntil((p) => !Navigator.of(context).canPop());
          } else {
            onAuthenticated?.call();
          }
          //  Navigator.of(context).pushReplacementNamed(LoginPage.routeName, arguments:  { 'message': state.message });
          //  }
        },
        child: child);
  }
}
