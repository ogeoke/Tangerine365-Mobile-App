import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';

/// One attained certificate (sample data — no certificates list endpoint yet).
class _Certificate {
  final String name;
  final String code;
  final String type; // e.g. Certificate of Attendance
  final int year;
  final String dateAttained;
  final String completion;
  const _Certificate({
    required this.name,
    required this.code,
    required this.type,
    required this.year,
    required this.dateAttained,
    required this.completion,
  });
}

/// Certificates (Figma 14): attained certificates with a summary, search and
/// per-certificate cards.
///
/// NOTE: there is no certificates-list endpoint yet (userStats only returns a
/// `certificates_attained` count), so the entries below are sample data wired
/// for an easy swap once a backend endpoint exists.
class CertificatesPage extends StatefulWidget {
  static const routeName = '/certificates';
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _query = '';

  // Per-certificate state (keyed by name). No backend endpoint yet, so
  // "generate" and "download" are simulated client-side.
  final Set<String> _generated = {};
  final Map<String, String> _format = {}; // name -> 'pdf' | 'jpg'
  String? _banner; // last-action status message shown below the header

  void _generate(String name) {
    setState(() {
      _generated.add(name);
      // 14A "Generated 1": no format selected yet — both PDF & JPG stay outline
      // and no banner shows until the student actually downloads (PDF/JPG).
      _format.remove(name);
      _banner = null;
    });
  }

  void _download(String name, String fmt) {
    setState(() {
      _format[name] = fmt;
      _banner = '${fmt.toUpperCase()} download started';
    });
  }

  static const _all = [
    _Certificate(
      name: 'Business Writing & Communication',
      code: 'COMM',
      type: 'Certificate of Attendance',
      year: 2026,
      dateAttained: '04 Sep 2026',
      completion: '04 Sep 2026',
    ),
    _Certificate(
      name: 'Empathy Quiz',
      code: 'AC',
      type: 'Certificate of Testing',
      year: 2025,
      dateAttained: '07 Jul 2025',
      completion: '04 Jul 2025',
    ),
    _Certificate(
      name: 'Excel 365 Masterclass',
      code: 'XCEL',
      type: 'Certificate of Attendance',
      year: 2025,
      dateAttained: '02 Jul 2025',
      completion: '02 Jul 2025',
    ),
  ];

  List<_Certificate> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final count = _all.length;
    final latestYear =
        _all.map((c) => c.year).fold<int>(0, (a, b) => b > a ? b : a);
    final types = _all.map((c) => c.type).toSet().length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Certificates',
              subtitle: 'Your certificates and achievements',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            if (_banner != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 12, AppTokens.screenPadding, 0),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTokens.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_banner!,
                            style: AppTokens.manrope(
                                size: 14, weight: 600, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
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
                              value: '$count',
                              label: 'Certificates',
                              highlight: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SummaryCard(
                              value: '$latestYear', label: 'Latest year')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SummaryCard(
                              value: '$types',
                              label: 'Types',
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
                        child: Text('Certificates attained',
                            style: AppTokens.manrope(
                                size: 20,
                                weight: 700,
                                color: AppTokens.textPrimary)),
                      ),
                      Text('${list.length} total',
                          style: AppTokens.manrope(
                              size: 13, weight: 600, color: AppTokens.primary)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('No certificates match your search.',
                            style: AppTokens.manrope(
                                size: 14,
                                weight: 500,
                                color: AppTokens.textSecondary)),
                      ),
                    )
                  else
                    for (final c in list) ...[
                      _CertificateCard(
                        certificate: c,
                        generated: _generated.contains(c.name),
                        format: _format[c.name],
                        onGenerate: () => _generate(c.name),
                        onPdf: () => _download(c.name, 'pdf'),
                        onJpg: () => _download(c.name, 'jpg'),
                      ),
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
          FittedBox(
            child: Text(value,
                style: AppTokens.manrope(
                    size: 26, weight: 700, color: AppTokens.primary)),
          ),
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
        hintText: 'Search certificates',
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

class _CertificateCard extends StatelessWidget {
  final _Certificate certificate;
  final bool generated;
  final String? format; // 'pdf' | 'jpg' | null (nothing selected yet)
  final VoidCallback onGenerate;
  final VoidCallback onPdf;
  final VoidCallback onJpg;
  const _CertificateCard({
    required this.certificate,
    required this.generated,
    required this.format,
    required this.onGenerate,
    required this.onPdf,
    required this.onJpg,
  });

  @override
  Widget build(BuildContext context) {
    final c = certificate;
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTokens.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${c.year}',
                    style: AppTokens.manrope(
                        size: 16, weight: 700, color: AppTokens.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('Code',
                    style: AppTokens.manrope(
                        size: 14, weight: 600, color: AppTokens.primary)),
              ),
              Text(c.code,
                  style: AppTokens.manrope(
                      size: 14, weight: 600, color: AppTokens.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED)),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Certificate',
            child: Text(c.type,
                style: AppTokens.manrope(
                    size: 14, weight: 700, color: AppTokens.primary)),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Date attained',
            child: Text(c.dateAttained,
                style: AppTokens.manrope(
                    size: 14, weight: 600, color: AppTokens.textPrimary)),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Completion',
            child: Text(c.completion,
                style: AppTokens.manrope(
                    size: 14, weight: 600, color: AppTokens.textPrimary)),
          ),
          const SizedBox(height: 16),
          if (!generated)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onGenerate,
                child: Text('Generate certificate',
                    style: AppTokens.manrope(
                        size: 14, weight: 600, color: Colors.white)),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _FormatButton(
                      label: 'PDF',
                      filled: format == 'pdf',
                      onTap: onPdf),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormatButton(
                      label: 'JPG',
                      filled: format == 'jpg',
                      onTap: onJpg),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// PDF / JPG download button — filled when it's the active/last format.
class _FormatButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _FormatButton(
      {required this.label, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: filled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onTap,
              child: Text(label,
                  style: AppTokens.manrope(
                      size: 14, weight: 600, color: Colors.white)),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTokens.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onTap,
              child: Text(label,
                  style: AppTokens.manrope(
                      size: 14, weight: 600, color: AppTokens.primary)),
            ),
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
