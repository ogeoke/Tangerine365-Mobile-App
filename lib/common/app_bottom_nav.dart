import 'package:flutter/material.dart';
import 'package:sevenup_mobile/constants/app_assets.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/views/banking_tools_page.dart';
import 'package:sevenup_mobile/views/courses_hub_page.dart';
import 'package:sevenup_mobile/views/info_management_page.dart';
import 'package:sevenup_mobile/views/knowledge_repository_page.dart';

/// Shared bottom service menu (Figma 01) shown across the main screens.
/// [currentIndex]: 0 = Home, 1 = Courses, -1 = none selected. Home returns to
/// the app root; every module tab returns to that module's main page.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, this.currentIndex = -1});


  /// Return to a module's main page from anywhere inside that module.
  ///
  /// Tapping a bottom-nav module tab should behave like pressing Back enough
  /// times to reach the module's landing page — so from e.g. Courses > My
  /// Learning > (detail), tapping "Courses" lands back on the Courses hub.
  ///
  /// - Already on the module's main page → do nothing.
  /// - The main page is still in the back stack → pop straight back to it
  ///   (preserves its state, no reload).
  /// - Otherwise → open it fresh on top of the app root (Home), so Back from
  ///   there still goes Home.
  void _goToModule(
    BuildContext context,
    String routeName,
    Widget Function() builder,
  ) {
    if (ModalRoute.of(context)?.settings.name == routeName) return;

    final nav = Navigator.of(context);
    var foundInStack = false;
    nav.popUntil((route) {
      final stop = route.settings.name == routeName || route.isFirst;
      if (stop) foundInStack = route.settings.name == routeName;
      return stop;
    });
    if (!foundInStack) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => builder(),
          settings: RouteSettings(name: routeName),
        ),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <_NavItemData>[
      _NavItemData(
        icon: Icons.home_rounded,
        label: 'Home',
        onTap: () {
          if (currentIndex == 0) return;
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
      ),
      _NavItemData(
        iconAsset: AppAssets.modCourses,
        label: 'Courses',
        onTap: () => _goToModule(
          context,
          CoursesHubPage.routeName,
          () => const CoursesHubPage(),
        ),
      ),
      _NavItemData(
        iconAsset: AppAssets.modRepository,
        label: 'Repository',
        onTap: () => _goToModule(
          context,
          KnowledgeRepositoryPage.routeName,
          () => const KnowledgeRepositoryPage(),
        ),
      ),
      _NavItemData(
        iconAsset: AppAssets.modBanking,
        // Short label so it doesn't truncate in the 5-tab bottom bar.
        label: 'Banking',
        onTap: () => _goToModule(
          context,
          BankingToolsPage.routeName,
          () => const BankingToolsPage(),
        ),
      ),
      _NavItemData(
        iconAsset: AppAssets.modInformation,
        label: 'Information',
        onTap: () => _goToModule(
          context,
          InfoManagementPage.routeName,
          () => const InfoManagementPage(),
        ),
      ),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTokens.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                _NavItem(data: items[i], selected: i == currentIndex),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData? icon;
  final String? iconAsset;
  final String label;
  final VoidCallback onTap;
  const _NavItemData({
    this.icon,
    this.iconAsset,
    required this.label,
    required this.onTap,
  });
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  const _NavItem({required this.data, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTokens.primary : AppTokens.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              data.iconAsset != null
                  ? Image.asset(
                      data.iconAsset!,
                      width: 24,
                      height: 24,
                      color: color,
                      colorBlendMode: BlendMode.srcIn,
                    )
                  : Icon(data.icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                  size: 11,
                  weight: selected ? 700 : 400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
