import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewOrientation extends StatefulWidget {
  final List<DeviceOrientation> orientations;
  final List<DeviceOrientation> onPopOrientations;

  const ViewOrientation(this.orientations,
      {super.key, this.onPopOrientations = const []});
  @override
  ViewOrientationState createState() => ViewOrientationState();
}

class ViewOrientationState extends State<ViewOrientation> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(widget.orientations);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(widget.onPopOrientations);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
