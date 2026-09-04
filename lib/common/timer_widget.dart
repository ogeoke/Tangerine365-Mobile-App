import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final Widget child;

  const TimerWidget({super.key, required this.child});
  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> with WidgetsBindingObserver {
  Timer? timer;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void startTimer() {
    // print('start timer');
    // timer = Timer(
    //     const Duration(seconds: 500),
    //     () => GetIt.I<AuthBloc>()
    //         .add(const LogOut(false, 'Session timedout Logged off')));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        startTimer();
        break;
      case AppLifecycleState.resumed:
        timer?.cancel();
        break;
      default:
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
  }
}
