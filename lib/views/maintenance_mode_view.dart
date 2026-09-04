import 'package:sevenup_mobile/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MaintenaceModeScreen extends StatelessWidget {
  const MaintenaceModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Overlay(initialEntries: [
      OverlayEntry(
        builder: (context) => Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(width: double.infinity),
            SizedBox(
                height: 50,
                child: Assets.images.logoAlt
                    .image()
                    .animate()
                    .fadeIn()
                    .scaleXY(delay: 300.ms)
                    .shake(delay: 400.ms)
                    .shimmer(delay: 400.ms)),
            const Text("App under Maintenance",
                style: TextStyle(color: Colors.white, fontSize: 20))
          ]),
        ),
      )
    ]);
  }
}
