import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/common/skeleton.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/models/banking.dart';

/// Forex & Rates hub (Figma 19B): a searchable list of rate tables. Tapping a
/// table opens its detail (currently only NAFEX has a sample table, 19C).
/// Rate data comes from the CLIENT's API — sample data until it's wired.
class ForexRatesPage extends StatefulWidget {
  const ForexRatesPage({super.key});

  @override
  State<ForexRatesPage> createState() => _ForexRatesPageState();
}

class _ForexRatesPageState extends State<ForexRatesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _tables = sampleRateTables();
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  List<RateTable> get _visible {
    if (_query.trim().isEmpty) return _tables;
    final q = _query.toLowerCase();
    return _tables
        .where((t) =>
            t.title.toLowerCase().contains(q) ||
            t.subtitle.toLowerCase().contains(q))
        .toList();
  }

  void _openTable(RateTable t) {
    if (t.id == 'nafex') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NafexRatesPage()),
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text('${t.title} will be available once rates are '
                'connected.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Forex & Rates',
              subtitle: 'Current treasury and deposit information',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 18, AppTokens.screenPadding, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rates updated $sampleRatesUpdated',
                      style: AppTokens.manrope(
                          size: 15, weight: 600, color: AppTokens.primary)),
                  const SizedBox(height: 14),
                  _SearchField(
                    hint: 'Search rate tables...',
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const SkeletonCards(count: 6)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppTokens.screenPadding,
                          12, AppTokens.screenPadding, 24),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _RateTableCard(
                          table: visible[i],
                          onTap: () => _openTable(visible[i])),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateTableCard extends StatelessWidget {
  final RateTable table;
  final VoidCallback onTap;
  const _RateTableCard({required this.table, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTokens.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTokens.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: AppTokens.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(table.title,
                        style: AppTokens.manrope(
                            size: 17,
                            weight: 700,
                            color: AppTokens.textPrimary)),
                    const SizedBox(height: 4),
                    Text(table.subtitle,
                        style: AppTokens.manrope(
                            size: 14,
                            weight: 400,
                            color: AppTokens.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppTokens.textSecondary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// NAFEX rates table (Figma 19C): a searchable Buy/Sell table by currency.
class NafexRatesPage extends StatefulWidget {
  const NafexRatesPage({super.key});

  @override
  State<NafexRatesPage> createState() => _NafexRatesPageState();
}

class _NafexRatesPageState extends State<NafexRatesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _rates = sampleNafexRates();
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  List<CurrencyRate> get _visible {
    if (_query.trim().isEmpty) return _rates;
    final q = _query.toLowerCase();
    return _rates
        .where((r) =>
            r.country.toLowerCase().contains(q) ||
            r.code.toLowerCase().contains(q))
        .toList();
  }

  static String _n(double v) {
    final whole = v.floor();
    final frac = ((v - whole) * 100).round();
    final buf = StringBuffer();
    final digits = whole.toString();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return '${buf.toString()}.${frac.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'NAFEX Rates',
              subtitle: 'Autonomous foreign-exchange rates',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 18, AppTokens.screenPadding, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sampleRatesUpdated,
                      style: AppTokens.manrope(
                          size: 15, weight: 600, color: AppTokens.primary)),
                  const SizedBox(height: 14),
                  _SearchField(
                    hint: 'Search currency or code...',
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ],
              ),
            ),
            // Table header
            Container(
              margin: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 12, AppTokens.screenPadding, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTokens.lightGreen.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text('Currency',
                        style: AppTokens.manrope(
                            size: 15,
                            weight: 700,
                            color: AppTokens.textPrimary)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Buy',
                        textAlign: TextAlign.right,
                        style: AppTokens.manrope(
                            size: 15,
                            weight: 700,
                            color: AppTokens.textPrimary)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Sell',
                        textAlign: TextAlign.right,
                        style: AppTokens.manrope(
                            size: 15,
                            weight: 700,
                            color: AppTokens.textPrimary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const SkeletonTableRows()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 0, AppTokens.screenPadding, 24),
                itemCount: visible.length,
                itemBuilder: (_, i) {
                  final r = visible[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTokens.surface,
                      border: Border(
                        left: const BorderSide(color: AppTokens.border),
                        right: const BorderSide(color: AppTokens.border),
                        bottom: const BorderSide(color: AppTokens.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.country,
                                  style: AppTokens.manrope(
                                      size: 16,
                                      weight: 700,
                                      color: AppTokens.textPrimary)),
                              const SizedBox(height: 4),
                              Text(r.code,
                                  style: AppTokens.manrope(
                                      size: 13,
                                      weight: 700,
                                      color: AppTokens.primary)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(_n(r.buy),
                              textAlign: TextAlign.right,
                              style: AppTokens.manrope(
                                  size: 16,
                                  weight: 500,
                                  color: AppTokens.textPrimary)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(_n(r.sell),
                              textAlign: TextAlign.right,
                              style: AppTokens.manrope(
                                  size: 16,
                                  weight: 500,
                                  color: AppTokens.textPrimary)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTokens.manrope(size: 15, color: AppTokens.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTokens.manrope(size: 15, color: AppTokens.placeholder),
        filled: true,
        fillColor: AppTokens.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTokens.primary),
        ),
      ),
    );
  }
}
