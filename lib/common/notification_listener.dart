import 'package:sevenup_mobile/state/notification/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KNotificationListener extends StatelessWidget {
  final Widget child;

  const KNotificationListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      BlocListener<NotificationBloc, NotificationState>(
          bloc: NotificationBloc(),
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message ?? ''),
                backgroundColor: Colors.red));
          },
          child: child);
}
