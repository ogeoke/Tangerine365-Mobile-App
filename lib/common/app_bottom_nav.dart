import 'package:flutter/material.dart';
import 'package:sevenup_mobile/constants/app_assets.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/views/courses_hub_page.dart';

/// Shared bottom service menu (Figma 01) shown across the main screens.
/// [currentIndex]: 0 = Home, 1 = Courses, -1 = none selected. Home returns to
/// the app root; Courses opens the hub; the remaining modules are "coming soon".
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, this.currentIndex = -1});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label is coming soon.')));
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
        onTap: () {
          if (currentIndex == 1) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CoursesHubPage()),
          );
        },
      ),
      _NavItemData(
        iconAsset: AppAssets.modRepository,
        label: 'Repository',
        onTap: () => _comingSoon(context, 'Knowledge Repository'),
      ),
      _NavItemData(
        iconAsset: AppAssets.modBanking,
        label: 'Banking Tools',
        onTap: () => _comingSoon(context, 'Banking Tools'),
      ),
      _NavItemData(
        iconAsset: AppAssets.modInformation,
        label: 'Information',
        onTap: () => _comingSoon(context, 'Information Management'),
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
