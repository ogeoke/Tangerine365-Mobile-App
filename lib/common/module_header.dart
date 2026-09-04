import 'package:flutter/material.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';

/// Standard module-screen header (Figma): a red back arrow, title + subtitle,
/// and (optionally) the green side-menu icon, above a hairline divider.
class ModuleHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;

  const ModuleHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTokens.screenPadding, 8, AppTokens.screenPadding, 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(top: 4, right: 8),
                  child: Icon(Icons.arrow_back_ios_new,
                      color: AppTokens.accent, size: 20),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTokens.manrope(
                        size: 28,
                        weight: 700,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTokens.manrope(
                          size: 13,
                          weight: 400,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (onMenu != null)
                GestureDetector(
                  onTap: onMenu,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4, left: 8),
                    child: Icon(Icons.menu, color: AppTokens.primary, size: 26),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTokens.border),
        ],
      ),
    );
  }
}
