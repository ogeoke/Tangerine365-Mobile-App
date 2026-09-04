/// created by Wisdom Ekeh ekeh.wisdom@gmail.com
///c 2020 Wed Jan 22
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/constants/app_assets.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/constants/env.dart';
import 'package:sevenup_mobile/models/user.dart';
import 'package:sevenup_mobile/services/biometrics_service.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:sevenup_mobile/views/about_page.dart';
import 'package:sevenup_mobile/views/activatekey_page.dart';
import 'package:sevenup_mobile/views/certificates_page.dart';
import 'package:sevenup_mobile/views/competencies_page.dart';
import 'package:sevenup_mobile/views/faq_page.dart';
import 'package:sevenup_mobile/views/help_support_page.dart';
import 'package:sevenup_mobile/views/leaderboard_page.dart';
import 'package:sevenup_mobile/views/my_learning_page.dart';
import 'package:sevenup_mobile/views/profile_page.dart';

const Color _logoutColor = Color(0xFFE5361B);

/// A single tappable row inside an expanded module.
class _Sub {
  final String label;
  final void Function(BuildContext) onTap;
  const _Sub(this.label, this.onTap);
}

/// A collapsible service module in the side menu.
class _Module {
  final String iconAsset;
  final String title;
  final List<_Sub> subs;
  const _Module(this.iconAsset, this.title, this.subs);
}

/// Approved side menu (Figma 07 • Menu Open / Group 405–409): green profile
/// header, collapsible service modules with sub-items, an Account & Support
/// section, and a red Logout that confirms via a dialog (Group 406). The avatar
/// comes from the authenticate API (`user.avatar` → [User.profilePicture]).
class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  int? _expanded; // index of the open module, null = all collapsed

  static String? _avatarUrl(User? user) {
    final a = user?.profilePicture;
    if (a == null || a.trim().isEmpty) return null;
    if (a.startsWith('http')) return a;
    final base = GetIt.I<Env>().baseUrl;
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    if (a.startsWith('/')) return '$b$a';
    // A bare avatar filename lives in the LMS user-photo directory.
    return '$b/files/appCore/photo/$a';
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).pop(); // close the drawer
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _soon(BuildContext context, String label) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label is coming soon.')));
  }

  List<_Module> get _modules => [
        _Module(AppAssets.modCourses, 'Courses', [
          _Sub('My Learning', (c) => _open(c, const MyLearningPage())),
          _Sub('Leaderboard', (c) => _open(c, const LeaderboardPage())),
          _Sub('Subscription Code',
              (c) => _open(c, const ActivateKeyPage())),
          _Sub('Competencies', (c) => _open(c, const CompetenciesPage())),
          _Sub('Certificates', (c) => _open(c, const CertificatesPage())),
        ]),
        _Module(AppAssets.modRepository, 'Knowledge Repository', [
          _Sub('Products', (c) => _soon(c, 'Products')),
          _Sub('Policies & SOPs', (c) => _soon(c, 'Policies & SOPs')),
          _Sub('Learning Series', (c) => _soon(c, 'Learning Series')),
          _Sub('FAQs', (c) => _open(c, const FaqPage())),
        ]),
        _Module(AppAssets.modBanking, 'Banking Tools', [
          _Sub('Forms', (c) => _soon(c, 'Forms')),
          _Sub('Forex & Rates', (c) => _soon(c, 'Forex & Rates')),
          _Sub('Loan Calculator', (c) => _soon(c, 'Loan Calculator')),
        ]),
        _Module(AppAssets.modInformation, 'Information Management', [
          _Sub('Announcements', (c) => _soon(c, 'Announcements')),
          _Sub('Messages', (c) => _soon(c, 'Messages')),
        ]),
      ];

  @override
  Widget build(BuildContext context) {
    final user = GetIt.I<AuthBloc>().state.user;
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.86,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _Header(
            name: '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
            email: user?.email ?? '',
            avatarUrl: _avatarUrl(user),
            onClose: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (var i = 0; i < _modules.length; i++)
                  _ModuleTile(
                    module: _modules[i],
                    expanded: _expanded == i,
                    onToggle: () =>
                        setState(() => _expanded = _expanded == i ? null : i),
                  ),
                const _SectionLabel('ACCOUNT & SUPPORT'),
                _AccountRow(
                    icon: Icons.account_circle_outlined,
                    label: 'Profile',
                    onTap: () => _open(context, const ProfilePage())),
                _AccountRow(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => _open(context, const HelpSupportPage())),
                _AccountRow(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () => _open(context, const AboutPage())),
                _AccountRow(
                    icon: Icons.logout,
                    label: 'Logout',
                    danger: true,
                    onTap: () => _confirmLogout(context)),
                const _BiometricRow(),
              ],
            ),
          ),
          const _Footer(),
        ],
      ),
    );
  }
}

/// Logout confirmation (Figma Group 406).
void _confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (c) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 44),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('!',
                style: AppTokens.manrope(
                    size: 30, weight: 700, color: _logoutColor)),
            const SizedBox(height: 4),
            Text('Log out of Tangerine365?',
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                    size: 17, weight: 700, color: AppTokens.textPrimary)),
            const SizedBox(height: 8),
            Text(
              "You'll need to enter your login details and complete verification again.",
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 12,
                  weight: 400,
                  height: 17,
                  color: AppTokens.textSecondary),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _logoutColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(c).pop(); // dialog
                  Navigator.of(context).pop(); // drawer
                  GetIt.I<AuthBloc>().add(const LogOut(true));
                },
                child: Text('Log out',
                    style: AppTokens.manrope(
                        size: 14, weight: 600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTokens.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(c).pop(),
                child: Text('Cancel',
                    style: AppTokens.manrope(
                        size: 14, weight: 600, color: AppTokens.primary)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback onClose;
  const _Header({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E6A20), Color(0xFF57A343)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 12,
              child: InkWell(
                onTap: onClose,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.18),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (avatarUrl != null)
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                                Icons.person,
                                color: AppTokens.primary,
                                size: 44),
                            placeholder: (_, __) => const Icon(Icons.person,
                                color: AppTokens.primary, size: 44),
                          )
                        : const Icon(Icons.person,
                            color: AppTokens.primary, size: 44),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name.isEmpty ? 'Welcome' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.manrope(
                        size: 22, weight: 700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.manrope(
                        size: 13,
                        weight: 400,
                        color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final _Module module;
  final bool expanded;
  final VoidCallback onToggle;
  const _ModuleTile({
    required this.module,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            color: expanded ? AppTokens.lightGreen.withOpacity(0.55) : null,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              children: [
                Image.asset(
                  module.iconAsset,
                  width: 24,
                  height: 24,
                  color: AppTokens.primary,
                  colorBlendMode: BlendMode.srcIn,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    module.title,
                    style: AppTokens.manrope(
                      size: 16,
                      weight: 700,
                      color:
                          expanded ? AppTokens.primary : AppTokens.textPrimary,
                    ),
                  ),
                ),
                Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppTokens.primary, size: 22),
              ],
            ),
          ),
        ),
        if (!expanded)
          const Divider(
              height: 1, thickness: 1, color: Color(0xFFEDEDED), indent: 24),
        if (expanded)
          for (final s in module.subs)
            InkWell(
              onTap: () => s.onTap(context),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(58, 18, 24, 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        s.label,
                        style: AppTokens.manrope(
                            size: 15,
                            weight: 400,
                            color: AppTokens.textPrimary),
                      ),
                    ),
                  ),
                  const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFEDEDED),
                      indent: 58),
                ],
              ),
            ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
      child: Text(
        text,
        style: AppTokens.manrope(
            size: 12,
            weight: 700,
            color: AppTokens.textSecondary,
            letterSpacing: 0.6),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _AccountRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? _logoutColor : AppTokens.primary;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 18),
                Text(
                  label,
                  style: AppTokens.manrope(
                    size: 16,
                    weight: 500,
                    color: danger ? _logoutColor : AppTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
              height: 1, thickness: 1, color: Color(0xFFEDEDED), indent: 24),
        ],
      ),
    );
  }
}

/// Highlighted biometrics toggle. Reflects live state; enabling runs a
/// biometric check first, disabling is immediate.
class _BiometricRow extends StatelessWidget {
  const _BiometricRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: GetIt.I<AuthBloc>(),
      builder: (context, state) {
        final on = state.useBiometrics;
        return Container(
          color: AppTokens.lightGreen.withOpacity(0.55),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.fingerprint, color: AppTokens.primary, size: 26),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Use Biometrics',
                        style: AppTokens.manrope(
                            size: 16,
                            weight: 500,
                            color: AppTokens.textPrimary)),
                    Text(on ? 'Enabled' : 'Disabled',
                        style: AppTokens.manrope(
                            size: 12,
                            weight: 400,
                            color: AppTokens.textSecondary)),
                  ],
                ),
              ),
              Switch(
                activeTrackColor: AppTokens.primary,
                inactiveTrackColor: AppTokens.primary.withOpacity(.4),
                thumbColor: const WidgetStatePropertyAll(Colors.white),
                value: on,
                onChanged: (v) async {
                  // Enabling requires a successful biometric check; disabling
                  // is always allowed.
                  if (v) {
                    final ok = await BiometricService.didAuthenticate();
                    if (!ok) return;
                  }
                  GetIt.I<AuthBloc>().add(SetBiometrics());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: Text(
          'Tangerine365 • v1.0.0',
          style: AppTokens.manrope(
              size: 12, weight: 400, color: AppTokens.textSecondary),
        ),
      ),
    );
  }
}

class DrawerItem {
  final String title;
  final Widget icon;
  final Widget? end;
  final String routeName;
  final Object? arguments;
  final Function()? onClick;

  DrawerItem(
    this.title,
    this.icon,
    this.routeName, {
    this.onClick,
    this.end,
    this.arguments,
  });
}

class FadeinImageAnim extends StatefulWidget {
  const FadeinImageAnim({super.key});

  @override
  FadeinImageAnimState createState() => FadeinImageAnimState();
}

class FadeinImageAnimState extends State<FadeinImageAnim>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _animation2;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    ).drive(Tween(begin: -3.0, end: 1.0));
    _animation2 = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    ).drive(Tween(begin: 0.0, end: -1.0));
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        AnimatedBuilder(
          animation: _animation,
          builder: (c, w) => Align(
            alignment: Alignment(_animation.value, 0),
            child: Container(
              alignment: Alignment.center,
              width: 45,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animation2,
          builder: (c, w) => Align(
            alignment: Alignment(1 * _animation2.value, 0),
            child: Container(
              alignment: Alignment.center,
              width: 75,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
        ),
      ],
    );
  }
}
