import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_assets.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/state/auth/index.dart';

// Rank medal + row tints (Figma 06).
const _gold = Color(0xFFF5A623);
const _silver = Color(0xFFB6BCC6);
const _bronze = Color(0xFFB0672E);
const _row1Bg = Color(0xFFFBF3D9);
const _row2Bg = Color(0xFFEFF2F5);
const _row3Bg = Color(0xFFFBEDE6);

/// A single leaderboard entry (currently sample data — no backend endpoint yet).
class _Entry {
  final int rank;
  final String name;
  final String subtitle;
  final int points;
  final int level;
  final int badges;
  final bool isYou;
  const _Entry(this.rank, this.name, this.subtitle, this.points, this.level,
      this.badges,
      {this.isYou = false});

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

enum _Tab { points, levels, badges }

/// Leaderboard (Figma 06): rank/level/rewards summary, a Points/Levels/Badges
/// switch, and the Top-10 list, with a "How to collect points" sheet (06A).
///
/// NOTE: the backend has no leaderboard/points endpoint yet, so the rank,
/// points, level, badges and list below are sample data wired for easy swap.
class LeaderboardPage extends StatefulWidget {
  static const routeName = '/leaderboard';
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _Tab _tab = _Tab.points;

  String get _fullName {
    final u = GetIt.I<AuthBloc>().state.user;
    final n = '${u?.firstName ?? ''} ${u?.lastName ?? ''}'.trim();
    return n.isEmpty ? 'You' : n;
  }

  late final List<_Entry> _entries = [
    _Entry(1, _fullName, 'You', 27100, 272, 4, isYou: true),
    const _Entry(2, 'Sadiat Ogidan', 'Top performer', 1000, 268, 3),
    const _Entry(3, 'Amina Yusuf', 'Top performer', 940, 265, 3),
    const _Entry(4, 'Chinedu Okafor', 'Level 263', 875, 263, 2),
    const _Entry(5, 'Adaobi Nwosu', 'Level 260', 820, 260, 2),
    const _Entry(6, 'Tunde Bello', 'Level 257', 780, 257, 2),
    const _Entry(7, 'Ngozi Eze', 'Level 254', 730, 254, 1),
    const _Entry(8, 'Emeka Obi', 'Level 251', 690, 251, 1),
  ];

  /// The right-hand value shown per tab: points, level, or badge count.
  String _valueFor(_Entry e) {
    switch (_tab) {
      case _Tab.points:
        return _RankRow.formatPoints(e.points);
      case _Tab.levels:
        return '${e.level}';
      case _Tab.badges:
        return '${e.badges}';
    }
  }

  String get _sectionTitle {
    switch (_tab) {
      case _Tab.points:
        return 'Top 10 learners';
      case _Tab.levels:
        return 'Level progression';
      case _Tab.badges:
        return 'Badge collection';
    }
  }

  void _showHowTo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HowToCollectPointsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Leaderboard',
              subtitle: 'Your rank, level and rewards',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 16, AppTokens.screenPadding, 24),
                children: [
                  _ProfileCard(name: _fullName, rank: 1, badge: 'Learning Novice'),
                  const SizedBox(height: 18),
                  const _StatRow(points: '27,100', level: '272', badges: '4'),
                  const SizedBox(height: 18),
                  _TabSwitch(
                      selected: _tab, onSelect: (t) => setState(() => _tab = t)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_sectionTitle,
                            style: AppTokens.manrope(
                                size: 20,
                                weight: 700,
                                color: AppTokens.textPrimary)),
                      ),
                      _HowToPill(onTap: _showHowTo),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (final e in _entries) ...[
                    _RankRow(entry: e, valueText: _valueFor(e)),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final int rank;
  final String badge;
  const _ProfileCard(
      {required this.name, required this.rank, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E6A20), Color(0xFF4C9A3A)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.manrope(
                        size: 22, weight: 700, color: Colors.white)),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Rank #$rank',
                      style: AppTokens.manrope(
                          size: 14, weight: 600, color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text('Latest badge',
                  style: AppTokens.manrope(
                      size: 12,
                      weight: 400,
                      color: Colors.white.withOpacity(0.85))),
              const SizedBox(height: 6),
              Image.asset(AppAssets.leaderboardBadge,
                  width: 96, height: 96, fit: BoxFit.contain),
              const SizedBox(height: 4),
              Text(badge,
                  style: AppTokens.manrope(
                      size: 15, weight: 600, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String points;
  final String level;
  final String badges;
  const _StatRow(
      {required this.points, required this.level, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(value: points, label: 'Points', green: true)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(value: level, label: 'Level')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(value: badges, label: 'Badges')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool green;
  const _StatCard(
      {required this.value, required this.label, this.green = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokens.border),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTokens.manrope(
                  size: 22,
                  weight: 700,
                  color: green ? AppTokens.primary : AppTokens.textPrimary)),
          const SizedBox(height: 4),
          Text(label,
              style: AppTokens.manrope(
                  size: 13, weight: 400, color: AppTokens.textSecondary)),
        ],
      ),
    );
  }
}

class _TabSwitch extends StatelessWidget {
  final _Tab selected;
  final ValueChanged<_Tab> onSelect;
  const _TabSwitch({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    Widget seg(_Tab t, String label) {
      final on = selected == t;
      return Expanded(
        child: GestureDetector(
          onTap: () => onSelect(t),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? AppTokens.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(label,
                style: AppTokens.manrope(
                    size: 14,
                    weight: on ? 700 : 500,
                    color: on ? Colors.white : AppTokens.textPrimary)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFEC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          seg(_Tab.points, 'Points'),
          seg(_Tab.levels, 'Levels'),
          seg(_Tab.badges, 'Badges'),
        ],
      ),
    );
  }
}

class _HowToPill extends StatelessWidget {
  final VoidCallback onTap;
  const _HowToPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTokens.lightGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('How to earn points',
            style: AppTokens.manrope(
                size: 13, weight: 600, color: AppTokens.primary)),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final _Entry entry;
  final String valueText;
  const _RankRow({required this.entry, required this.valueText});

  Color? get _rowBg {
    switch (entry.rank) {
      case 1:
        return _row1Bg;
      case 2:
        return _row2Bg;
      case 3:
        return _row3Bg;
      default:
        return AppTokens.surface;
    }
  }

  Color get _medal {
    switch (entry.rank) {
      case 1:
        return _gold;
      case 2:
        return _silver;
      case 3:
        return _bronze;
      default:
        return const Color(0xFFE6E9EC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topThree = entry.rank <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _rowBg,
        borderRadius: BorderRadius.circular(14),
        border: topThree ? null : Border.all(color: AppTokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _medal),
            child: Text('${entry.rank}',
                style: AppTokens.manrope(
                    size: 14,
                    weight: 700,
                    color: topThree ? Colors.white : AppTokens.textSecondary)),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.isYou ? AppTokens.primary : AppTokens.lightGreen,
            ),
            child: Text(entry.initials,
                style: AppTokens.manrope(
                    size: 14,
                    weight: 700,
                    color: entry.isYou ? Colors.white : AppTokens.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.manrope(
                        size: 16,
                        weight: 700,
                        color: AppTokens.textPrimary)),
                const SizedBox(height: 2),
                Text(entry.subtitle,
                    style: AppTokens.manrope(
                        size: 12,
                        weight: 400,
                        color: AppTokens.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(valueText,
              style: AppTokens.manrope(
                  size: 16,
                  weight: 700,
                  color: entry.isYou ? AppTokens.primary : AppTokens.textPrimary)),
        ],
      ),
    );
  }

  static String formatPoints(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// -----------------------------------------------------------------------------
// 06A • How to collect points (bottom sheet)
// -----------------------------------------------------------------------------
class _PointRule {
  final String title;
  final String desc;
  final int points;
  const _PointRule(this.title, this.desc, this.points);
}

class _HowToCollectPointsSheet extends StatelessWidget {
  const _HowToCollectPointsSheet();

  static const _rules = [
    _PointRule('Daily login', 'Come back and keep your streak alive', 500),
    _PointRule('Complete a course', 'Finish every lesson in a course', 600),
    _PointRule('Earn a certificate', 'Collect proof of your achievement', 150),
    _PointRule('Pass a test', 'Successfully complete an assessment', 250),
    _PointRule('Join a discussion', 'Post a topic or helpful comment', 50),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
                color: AppTokens.border,
                borderRadius: BorderRadius.circular(3)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How to collect points',
                          style: AppTokens.manrope(
                              size: 24,
                              weight: 700,
                              color: AppTokens.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Every learning action moves you up the leaderboard.',
                          style: AppTokens.manrope(
                              size: 13,
                              weight: 400,
                              color: AppTokens.textSecondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFFEDEFEC)),
                    child: const Icon(Icons.close,
                        size: 20, color: AppTokens.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: _rules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _RuleTile(index: i + 1, rule: _rules[i], green: i.isEven),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final int index;
  final _PointRule rule;
  final bool green;
  const _RuleTile(
      {required this.index, required this.rule, required this.green});

  @override
  Widget build(BuildContext context) {
    final accent = green ? AppTokens.primary : AppTokens.accent;
    final bg = green
        ? AppTokens.lightGreen.withOpacity(0.5)
        : AppTokens.accent.withOpacity(0.07);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
            child: Text('$index',
                style: AppTokens.manrope(
                    size: 14, weight: 700, color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.title,
                    style: AppTokens.manrope(
                        size: 16,
                        weight: 700,
                        color: AppTokens.textPrimary)),
                const SizedBox(height: 2),
                Text(rule.desc,
                    style: AppTokens.manrope(
                        size: 12,
                        weight: 400,
                        color: AppTokens.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: accent, borderRadius: BorderRadius.circular(20)),
            child: Text('+${rule.points}',
                style: AppTokens.manrope(
                    size: 14, weight: 700, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
