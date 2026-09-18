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

  /// Banner URLs whose image failed to load — dropped from the rotation.
  final Set<String> _failed = {};

  List<String> get _urls => widget.children
      .map((e) => (e.bannerUrl ?? '').trim())
      .where((u) => u.isNotEmpty && !_failed.contains(u))
      .toList();

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final count = _urls.length;
      if (count < 2 || !_pageController.hasClients) return;
      _pageController.animateToPage(_page >= count - 1 ? 0 : _page + 1,
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

  void _markFailed(String url) {
    if (_failed.contains(url)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _failed.add(url));
    });
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    // Placeholder artwork only when there is no banner to show at all.
    if (urls.isEmpty) return const BannerPlaceholderCard();
    const aspectRatio = 384 / 168;
    return LayoutBuilder(
      builder: (context, constraints) => Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(10.0),
        child: SizedBox(
          height: constraints.maxWidth / aspectRatio,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              PageView(
                controller: _pageController,
                children: [
                  for (final url in urls)
                    Stack(
                      key: ValueKey(url),
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          // Plain light panel while loading; a failed image is
                          // removed from the carousel instead of shown broken.
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const ColoredBox(
                                      color: AppTokens.lightGreen),
                          errorBuilder: (_, __, ___) {
                            _markFailed(url);
                            return const ColoredBox(
                                color: AppTokens.lightGreen);
                          },
                        ),
                        Positioned.fill(
                            child: Material(
                                color: Colors.black.withOpacity(0.2),
                                child: const SizedBox.expand())),
                      ],
                    ),
                ],
              ),
              if (urls.length > 1)
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: 14,
                  child: Center(
                      child: SmoothPageIndicator(
                          controller: _pageController,
                          count: urls.length,
                          effect: WormEffect(
                              dotHeight: 7,
                              dotWidth: 7,
                              dotColor: Colors.white.withOpacity(.8),
                              activeDotColor: Theme.of(context).primaryColor,
                              spacing: 6))),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "No Information at this time" artwork — only shown when the admin has
/// no (loadable) banners.
class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.bannerPlaceholder,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(color: AppTokens.lightGreen),
    );
  }
}

/// Banner-sized placeholder used when there are no banners to show at all.
class BannerPlaceholderCard extends StatelessWidget {
  const BannerPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    const aspectRatio = 384 / 168;
    return LayoutBuilder(
      builder: (context, constraints) => ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: SizedBox(
          height: constraints.maxWidth / aspectRatio,
          width: double.infinity,
          child: const _BannerPlaceholder(),
        ),
      ),
    );
  }
}
