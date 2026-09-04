import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/constants/env.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/stats.dart';
import 'package:sevenup_mobile/models/user.dart';
import 'package:sevenup_mobile/state/auth/index.dart';

const _monthAbbr = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
  'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

/// Profile (Figma 17): read-only personal, employment and education details.
///
/// Core fields (name, username, email, avatar) come from the authenticate
/// session; Last Login comes from `userStats`. The remaining fields (Date of
/// Birth, Marital Status and the Employment / Education sections) are LMS
/// `custom_fields` from `POST /api/user/userdetailsbyuserid` — shown as "—"
/// until that endpoint's custom fields are wired.
class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = ApiRepository();
  Stats? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _repository.getStats();
    if (!mounted) return;
    if (res.body is Stats) setState(() => _stats = res.body as Stats);
  }

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

  String _fmtLastLogin(String? s) {
    final d = DateTime.tryParse(s ?? '');
    if (d == null) return '—';
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_monthAbbr[d.month - 1]} ${d.year}, $h12:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final u = GetIt.I<AuthBloc>().state.user;
    final name = '${u?.firstName ?? ''} ${u?.lastName ?? ''}'.trim();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Profile',
              subtitle: 'Your personal information',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 16, AppTokens.screenPadding, 24),
                children: [
                  _ProfileHeaderCard(
                    name: name.isEmpty ? (u?.username ?? 'User') : name,
                    email: u?.email ?? '',
                    avatarUrl: _avatarUrl(u),
                  ),
                  const SizedBox(height: 18),
                  _InfoCard(
                    title: 'Personal Information',
                    rows: [
                      ('First Name', u?.firstName ?? '—'),
                      ('Last Name', u?.lastName ?? '—'),
                      ('Username', u?.username ?? '—'),
                      ('Email', u?.email ?? '—'),
                      ('Last Login', _fmtLastLogin(_stats?.lastLogin)),
                      ('Date of Birth', '—'),
                      ('Marital Status', '—'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _InfoCard(
                    title: 'Employment Information',
                    rows: const [
                      ('Department', '—'),
                      ('Organization Grade', '—'),
                      ('Years in Organization', '—'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _InfoCard(
                    title: 'Education & Interests',
                    rows: const [
                      ('Education Level', '—'),
                      ('Discipline', '—'),
                      ('Professional Certification', '—'),
                      ('Learning Interest', '—'),
                      ('Hobby', '—'),
                    ],
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

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  const _ProfileHeaderCard(
      {required this.name, required this.email, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3E6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white),
            clipBehavior: Clip.antiAlias,
            child: (avatarUrl != null)
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(Icons.person,
                        color: AppTokens.primary, size: 38),
                    placeholder: (_, __) => const Icon(Icons.person,
                        color: AppTokens.primary, size: 38),
                  )
                : const Icon(Icons.person, color: AppTokens.primary, size: 38),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.manrope(
                        size: 20, weight: 700, color: AppTokens.textPrimary)),
                const SizedBox(height: 4),
                Text(email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.manrope(
                        size: 13,
                        weight: 400,
                        color: AppTokens.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTokens.manrope(
                  size: 18, weight: 700, color: AppTokens.textPrimary)),
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(rows[i].$1,
                        style: AppTokens.manrope(
                            size: 14,
                            weight: 400,
                            color: AppTokens.textSecondary)),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(rows[i].$2,
                        textAlign: TextAlign.right,
                        style: AppTokens.manrope(
                            size: 14,
                            weight: 700,
                            color: AppTokens.textPrimary)),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED)),
          ],
        ],
      ),
    );
  }
}
