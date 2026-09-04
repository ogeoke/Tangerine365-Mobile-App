import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';

/// One attained competency (sample data — no backend endpoint yet).
class _Competency {
  final String name;
  final String type; // 'Skill' | 'Attitude'
  final String assessment; // 'Score' | 'Flag'
  final int? score; // 0–100 for score-based; null for flag/attained
  final String lastCompleted;
  final String required;
  const _Competency({
    required this.name,
    required this.type,
    required this.assessment,
    this.score,
    required this.lastCompleted,
    this.required = '—',
  });
}

/// Competencies (Figma 13): attained skills/attitudes with a summary, search
/// and per-competency cards.
///
/// NOTE: there is no competencies endpoint yet (userStats only returns a
/// `competencies_attained` count, not the list), so the entries below are
/// sample data wired for an easy swap once a backend endpoint exists.
class CompetenciesPage extends StatefulWidget {
  static const routeName = '/competencies';
  const CompetenciesPage({super.key});

  @override
  State<CompetenciesPage> createState() => _CompetenciesPageState();
}

class _CompetenciesPageState extends State<CompetenciesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _query = '';

  static const _all = [
    _Competency(
      name: 'Time Management',
      type: 'Skill',
      assessment: 'Score',
      score: 95,
      lastCompleted: '02 Jul 2025 · 16:57',
    ),
    _Competency(
      name: 'Written Communication',
      type: 'Attitude',
      assessment: 'Flag',
      lastCompleted: '02 Jul 2025 · 17:05',
    ),
  ];

  List<_Competency> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final attained = _all.length;
    final skills = _all.where((c) => c.type == 'Skill').length;
    final attitudes = _all.where((c) => c.type == 'Attitude').length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Competencies',
              subtitle: 'Your attained skills and achievements',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 16, AppTokens.screenPadding, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _SummaryCard(
                              value: '$attained',
                              label: 'Attained',
                              highlight: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SummaryCard(
                              value: '$skills', label: 'Skill')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SummaryCard(
                              value: '$attitudes',
                              label: 'Attitude',
                              highlight: true)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SearchBar(onChanged: (v) => setState(() => _query = v)),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text('Attained competencies',
                            style: AppTokens.manrope(
                                size: 20,
                                weight: 700,
                                color: AppTokens.textPrimary)),
                      ),
                      Text('${list.length} total',
                          style: AppTokens.manrope(
                              size: 13,
                              weight: 600,
                              color: AppTokens.primary)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('No competencies match your search.',
                            style: AppTokens.manrope(
                                size: 14,
                                weight: 500,
                                color: AppTokens.textSecondary)),
                      ),
                    )
                  else
                    for (final c in list) ...[
                      _CompetencyCard(competency: c),
                      const SizedBox(height: 16),
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

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;
  const _SummaryCard(
      {required this.value, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFEAF3E6) : const Color(0xFFF1F3F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTokens.manrope(
                  size: 26, weight: 700, color: AppTokens.primary)),
          const SizedBox(height: 4),
          Text(label,
              style: AppTokens.manrope(
                  size: 13, weight: 400, color: AppTokens.textSecondary)),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTokens.manrope(
          size: 14, weight: 400, color: AppTokens.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search competencies',
        hintStyle: AppTokens.manrope(
            size: 14, weight: 400, color: AppTokens.placeholder),
        prefixIcon:
            const Icon(Icons.search, color: AppTokens.textSecondary, size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTokens.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _CompetencyCard extends StatelessWidget {
  final _Competency competency;
  const _CompetencyCard({required this.competency});

  @override
  Widget build(BuildContext context) {
    final c = competency;
    final scoreValue =
        c.score != null ? '${c.score} / 100' : 'Attained ✓';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(c.name,
                    style: AppTokens.manrope(
                        size: 20, weight: 700, color: AppTokens.textPrimary)),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTokens.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(c.score != null ? '${c.score}' : '✓',
                    style: AppTokens.manrope(
                        size: 16, weight: 700, color: AppTokens.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Tag(label: c.type, green: true),
              const SizedBox(width: 10),
              _Tag(label: c.assessment, green: false),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED)),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Score',
            child: Text(scoreValue,
                style: AppTokens.manrope(
                    size: 14, weight: 700, color: AppTokens.primary)),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Last completed',
            child: Text(c.lastCompleted,
                style: AppTokens.manrope(
                    size: 14, weight: 600, color: AppTokens.textPrimary)),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Required',
            child: Text(c.required,
                style: AppTokens.manrope(
                    size: 14, weight: 600, color: AppTokens.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool green;
  const _Tag({required this.label, required this.green});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: green ? AppTokens.lightGreen : const Color(0xFFEFF1F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTokens.manrope(
              size: 13,
              weight: 600,
              color: green ? AppTokens.primary : AppTokens.textSecondary)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: AppTokens.manrope(
                  size: 14, weight: 400, color: AppTokens.textSecondary)),
        ),
        child,
      ],
    );
  }
}
