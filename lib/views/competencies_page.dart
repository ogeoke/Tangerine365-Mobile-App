import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/competency.dart';
import 'package:sevenup_mobile/services/app_router.dart';

const _monthAbbr = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
  'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String _cap(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

String _fmtDateTime(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return '—';
  final l = d.toLocal();
  final hh = l.hour.toString().padLeft(2, '0');
  final mm = l.minute.toString().padLeft(2, '0');
  return '${l.day.toString().padLeft(2, '0')} ${_monthAbbr[l.month - 1]} '
      '${l.year} · $hh:$mm';
}

/// Competencies (Figma 13): the learner's attained skills/knowledge from
/// `POST /api/competencies`, with a summary, search and per-competency cards.
class CompetenciesPage extends StatefulWidget {
  static const routeName = '/competencies';
  const CompetenciesPage({super.key});

  @override
  State<CompetenciesPage> createState() => _CompetenciesPageState();
}

class _CompetenciesPageState extends State<CompetenciesPage>
    with WidgetsBindingObserver, RouteAware {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = ApiRepository();

  List<Competency> _all = const [];
  bool _loading = true;
  bool _error = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() => _load(silent: true);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load(silent: true);
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = false;
      });
    }
    final res = await _repository.getCompetencies();
    if (!mounted) return;
    final raw = res.body;
    final items = raw == null ? null : raw['competencies'];
    if (items is List) {
      final list = items
          .whereType<Map>()
          .map((e) => Competency.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      setState(() {
        _all = list;
        _error = false;
        _loading = false;
      });
    } else if (!silent) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  List<Competency> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final attained = _all.length;
    final skills = _all.where((c) => c.typology == 'skill').length;
    final knowledge = _all.where((c) => c.typology == 'knowledge').length;

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
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppTokens.primary))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTokens.primary,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                            AppTokens.screenPadding, 16,
                            AppTokens.screenPadding, 24),
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
                                      value: '$knowledge',
                                      label: 'Knowledge',
                                      highlight: true)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _SearchBar(
                              onChanged: (v) => setState(() => _query = v)),
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
                          if (_error)
                            _EmptyState(
                              icon: Icons.error_outline,
                              message: "Couldn't load your competencies.",
                              action: 'Retry',
                              onAction: _load,
                            )
                          else if (_all.isEmpty)
                            const _EmptyState(
                              icon: Icons.verified_outlined,
                              message: 'You have no competencies yet. Complete '
                                  'a course to attain one.',
                            )
                          else if (list.isEmpty)
                            const _EmptyState(
                              icon: Icons.search_off,
                              message: 'No competencies match your search.',
                            )
                          else
                            for (final c in list) ...[
                              _CompetencyCard(competency: c),
                              const SizedBox(height: 16),
                            ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? action;
  final VoidCallback? onAction;
  const _EmptyState(
      {required this.icon, required this.message, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppTokens.textSecondary),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                    size: 14, weight: 500, color: AppTokens.textSecondary)),
            if (action != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTokens.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onAction,
                child: Text(action!,
                    style: AppTokens.manrope(
                        size: 14, weight: 700, color: AppTokens.primary)),
              ),
            ],
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
  final Competency competency;
  const _CompetencyCard({required this.competency});

  @override
  Widget build(BuildContext context) {
    final c = competency;
    final scoreValue = c.isFlag
        ? 'Attained ✓'
        : '${c.score == null ? '—' : c.score!.round()} / 100';
    final badge = c.isFlag ? '✓' : '${c.score == null ? '—' : c.score!.round()}';
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
                child: Text(badge,
                    style: AppTokens.manrope(
                        size: 16, weight: 700, color: AppTokens.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (c.typology.isNotEmpty)
                _Tag(label: _cap(c.typology), green: true),
              _Tag(label: _cap(c.type), green: false),
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
            label: 'Date attained',
            child: Text(_fmtDateTime(c.dateAttained),
                style: AppTokens.manrope(
                    size: 14, weight: 600, color: AppTokens.textPrimary)),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Category',
            child: Text(c.category.isEmpty ? '—' : c.category,
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
        const SizedBox(width: 12),
        Flexible(child: child),
      ],
    );
  }
}
