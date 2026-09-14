import 'dart:async';

import 'package:sevenup_mobile/constants/app_assets.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/models/banners.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Carousel extends StatefulWidget {
  final List<Banners> children;
  const Carousel({super.key, required this.children});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late PageController _pageController;
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _pageController.animateToPage(
          _page >= (widget.children.length - 1) ? 0 : _page + 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastEaseInToSlowEaseOut);
    });

    _pageController.addListener(() {
      _page = _pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var aspectRatio = 384 / 168;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(10.0),
        child: SizedBox(
          height: (MediaQuery.of(context).size.width - 50) / aspectRatio,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              PageView(
                controller: _pageController,
                children: [
                  for (var item
                      in widget.children.map((e) => e.bannerUrl ?? ''))
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item,
                          fit: BoxFit.cover,
                          // Soft branded panel while loading and if the image
                          // fails (e.g. a missing banner on the server) — no
                          // default broken-image glyph.
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const _BannerPlaceholder(),
                          errorBuilder: (_, __, ___) =>
                              const _BannerPlaceholder(),
                        ),
                        Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            top: 0,
                            child: Material(
                                color: Colors.black.withOpacity(0.2),
                                child: const SizedBox.expand())),
                      ],
                    ),
                ],
              ),
              Positioned(
                right: 0,
                left: 0,
                bottom: 14,
                child: Center(
                    child: SmoothPageIndicator(
                        controller: _pageController,
                        count: 3,
                        effect: WormEffect(
                            dotHeight: 7,
                            dotWidth: 7,
                            dotColor: Colors.white.withOpacity(.8),
                            activeDotColor: Theme.of(context)
                                .primaryColor, // const Color(0xffED73D8),
                            spacing: 6))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown in place of a banner while it loads or if it fails to load (e.g. a
/// missing image on the server) — a soft green panel with the faint wordmark,
/// instead of the default broken-image icon.
class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTokens.lightGreen, AppTokens.lightGreenAlt],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.5,
          child: Image.asset(
            AppAssets.logo,
            height: 40,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_outlined,
              color: AppTokens.primary,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }
}
