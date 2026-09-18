import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/common/logout_dialog.dart';
import 'package:sevenup_mobile/common/notification_bell.dart';
import 'package:sevenup_mobile/constants/app_assets.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:sevenup_mobile/state/settings/settings_cubit.dart';
import 'package:sevenup_mobile/views/course/cubit/banner_cubit.dart';
import 'package:sevenup_mobile/views/banking_tools_page.dart';
import 'package:sevenup_mobile/views/courses_hub_page.dart';
import 'package:sevenup_mobile/views/info_management_page.dart';

import 'carousel.dart';
import 'knowledge_repository_page.dart';

/// Approved Home screen (Figma 01): greeting, message banner, and the four
/// service modules. No side-menu icon here — the menu appears inside modules.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openCourses(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CoursesHubPage()));
  }

  void _openInformation(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const InfoManagementPage()));
  }

  void _openBanking(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BankingToolsPage()));
  }

  @override
  Widget build(BuildContext context) {
    final firstName = context.watch<AuthBloc>().state.user?.firstName ?? '';
    return Scaffold(
      backgroundColor: AppTokens.screenBg,
      // Home has no text input; never shrink the fixed grid for a keyboard.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.screenPadding,
            8,
            AppTokens.screenPadding,
            12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${firstName.isEmpty ? 'there' : firstName}',
                          style: AppTokens.manrope(
                            size: 24,
                            weight: 700,
                            color: AppTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'What would you like to learn today?',
                          style: AppTokens.manrope(
                            size: 14,
                            weight: 400,
                            color: AppTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const NotificationBell(),
                  const SizedBox(width: 8),
                  _LogoutButton(onTap: () => confirmLogout(context)),
                ],
              ),
              const SizedBox(height: 16),
              _BannerSection(),
              const SizedBox(height: 18),
              Text(
                'Choose a service',
                style: AppTokens.manrope(
                  size: 22,
                  weight: 700,
                  color: AppTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'All services are available. Tap a service to get started.',
                style: AppTokens.manrope(
                  size: 13,
                  weight: 400,
                  color: AppTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              // The 2×2 service grid fills the remaining space so the cards
              // resize to fit — the Home screen never scrolls.
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _ModuleCard(
                              iconAsset: AppAssets.modCourses,
                              title: 'Courses',
                              subtitle:
                                  'My Courses, Catalogue, Assessments & more',
                              active: true,
                              animationIndex: 0,
                              onTap: () => _openCourses(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModuleCard(
                              iconAsset: AppAssets.modRepository,
                              title: 'Knowledge Repository',
                              subtitle: 'Products, Policies & SOPs',
                              active: true,
                              activeColor: AppTokens.moduleRepositoryActiveBg,
                              animationIndex: 1,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const KnowledgeRepositoryPage(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _ModuleCard(
                              iconAsset: AppAssets.modBanking,
                              title: 'Banking Tools',
                              subtitle: 'Forms, Forex & Rates',
                              active: true,
                              activeColor: AppTokens.moduleBankingActiveBg,
                              animationIndex: 2,
                              onTap: () => _openBanking(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModuleCard(
                              iconAsset: AppAssets.modInformation,
                              title: 'Information Management',
                              subtitle: 'Announcements, Communications & more',
                              active: true,
                              activeColor: AppTokens.moduleInfoActiveBg,
                              animationIndex: 3,
                              onTap: () => _openInformation(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logout control in the Home header (Figma 01): a white rounded-square button
/// with a soft shadow and the orange "log out" glyph.
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(Icons.logout, color: AppTokens.accent, size: 24),
        ),
      ),
    );
  }
}

class _BannerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerCubit, BannerState>(
      builder: (context, state) {
        final banners = state.data?.toList() ?? [];
        final enabled = context.watch<SettingsCubit>().state.data?.enableBanner;
        if (enabled != 'true') return const SizedBox.shrink();
        if (banners.isEmpty) return const BannerPlaceholderCard();
        return Carousel(children: banners);
      },
    );
  }
}

/// A single service-module card (Figma 01): active cards use [activeColor]
/// (Courses green, Information Management Tangerine orange); inactive modules are grey with the white icon art and a "COMING SOON" pill.
class _ModuleCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final bool active;

  /// Card colour when active; the shared texture is laid over it.
  final Color activeColor;
  final VoidCallback? onTap;

  /// Position in the grid (0-based), used only to stagger the entrance.
  final int animationIndex;

  const _ModuleCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.active = false,
    this.activeColor = AppTokens.moduleCoursesBg,
    this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
          color: active ? activeColor : AppTokens.moduleComingSoonBg,
          borderRadius: BorderRadius.circular(AppTokens.moduleCardRadius),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: active
                ? BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage(AppAssets.moduleCardTexture),
                      fit: BoxFit.cover,
                      opacity: AppTokens.moduleTextureOpacity,
                    ),
                  )
                : null,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Image.asset(iconAsset, width: 58, height: 58),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.manrope(
                        size: 15,
                        weight: 700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.manrope(
                        size: 11,
                        weight: 400,
                        height: 14,
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                    const SizedBox(height: 10),
                    active
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Open',
                                style: AppTokens.manrope(
                                  size: 14,
                                  weight: 600,
                                  color: Colors.white,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'COMING SOON',
                              style: AppTokens.manrope(
                                size: 9,
                                weight: 700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (animationIndex * 90).ms)
        .fadeIn(duration: 360.ms)
        .slideY(begin: 0.10, end: 0, duration: 360.ms, curve: Curves.easeOut);
  }
}
