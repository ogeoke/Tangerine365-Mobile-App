import 'package:sevenup_mobile/constants/env.dart';
import 'package:sevenup_mobile/state/auth/auth_bloc.dart';
import 'package:sevenup_mobile/views/playcourse_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class QuickTourPage extends StatefulWidget {
  static const routeName = '/quick_tour_page';

  const QuickTourPage({super.key});

  @override
  QuickTourPageState createState() => QuickTourPageState();
}

class QuickTourPageState extends State<QuickTourPage> {
  // final flutterWebviewPlugin = new FlutterWebviewPlugin();
  var env = GetIt.I<Env>();

  double progress = 0;
  @override
  void initState() {
    _setOrientation();
    super.initState();
  }

  _setOrientation() {
    WidgetsBinding.instance.addPostFrameCallback((d) {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeLeft]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
        onPopInvokedWithResult: (status, a) async {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: SystemUiOverlay.values);
        },
        child: PlayCoursePage(
          auth: GetIt.I<AuthBloc>().state.token ?? '',
          url: Uri.parse('${env.baseUrl}/tour/story.html'),
        ),
      );
}
