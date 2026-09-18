import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/certificate.dart';
import 'package:sevenup_mobile/services/app_router.dart';
import 'package:sevenup_mobile/views/certificate_preview_page.dart';

const _monthAbbr = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _fmtDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return '—';
  final l = d.toLocal();
  return '${l.day.toString().padLeft(2, '0')} '
      '${_monthAbbr[l.month - 1]} ${l.year}';
}

int _year(String iso) => DateTime.tryParse(iso)?.toLocal().year ?? 0;

/// Certificates (Figma 14): the learner's earned certificates from
/// `POST /api/certificates`. Tapping one opens the full-screen render
/// ([CertificatePreviewPage]) which draws the backend's Fabric.js design and
/// offers PDF + image download.
class CertificatesPage extends StatefulWidget {
  static const routeName = '/certificates';
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage>
    with WidgetsBindingObserver, RouteAware {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = ApiRepository();

  List<Certificate> _all = const [];
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

  // Returning here (e.g. after generating on the web) or resuming the app
  // re-fetches so a newly issued certificate flips to "Download".
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
    final res = await _repository.getCertificates();
    if (!mounted) return;
    final raw = res.body;
    final certs = raw == null ? null : raw['certificates'];
    if (certs is List) {
      final list = certs
          .whereType<Map>()
          .map((e) => Certificate.fromJson(Map<String, dynamic>.from(e)))
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

  List<Certificate> get _filtered {
    if (_query.trim().isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all
        .where(
          (c) =>
              c.course.toLowerCase().contains(q) ||
              c.title.toLowerCase().contains(q) ||
              c.identifier.toLowerCase().contains(q),
        )
        .toList();
  }

  void _open(
    Certificate c, {
    Map<String, dynamic>? renderData,
    String? autoDownload,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CertificatePreviewPage(
          certificate: c,
          renderData: renderData,
          autoDownload: autoDownload,
        ),
      ),
    );
  }

  /// Card action: an issued certificate opens for download (render API); an
  /// un-issued one is generated first.
  void _onAction(Certificate c) => c.generated ? _open(c) : _generate(c);

  /// `certificates/generate` returns the same design + substitutions as the
  /// render API, so after a successful generate we offer PDF/JPG straight away
  /// and draw from that data (no second render call). "Not now" just returns
  /// to the list, where the card now shows "Download certificate".
  Future<void> _generate(Certificate c) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppTokens.primary),
            ),
          ),
        ),
      ),
    );
    final res = await _repository.generateCertificate(
      c.id.toString(),
      c.courseId.toString(),
    );
    if (!mounted) return;
    Navigator.of(context).pop(); // progress

    final body = res.body;
    final data = body?['data'];
    final ok = body?['success'] == true && data is Map && data['design'] is Map;
    if (!ok) {
      final msg = body?['message']?.toString();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              (msg != null && msg.isNotEmpty)
                  ? msg
                  : 'Could not generate this certificate. Please try again.',
            ),
          ),
        );
      return;
    }

    _load(silent: true); // card flips to "Download certificate"
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // sheet sizes to its content (no overflow)
      builder: (_) => _GeneratedSheet(course: c.course),
    );
    if (!mounted || choice == null) return;
    _open(c, renderData: Map<String, dynamic>.from(data), autoDownload: choice);
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final count = _all.length;
    final latestYear = _all
        .map((c) => _year(c.issueDate))
        .fold<int>(0, (a, b) => b > a ? b : a);
    final types = _all.map((c) => c.title).toSet().length;

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
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTokens.primary,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTokens.primary,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppTokens.screenPadding,
                          16,
                          AppTokens.screenPadding,
                          24,
                        ),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  value: '$count',
                                  label: 'Certificates',
                                  highlight: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SummaryCard(
                                  value: latestYear == 0 ? '—' : '$latestYear',
                                  label: 'Latest year',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SummaryCard(
                                  value: '$types',
                                  label: 'Types',
                                  highlight: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _SearchBar(
                            onChanged: (v) => setState(() => _query = v),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  'Certificates attained',
                                  style: AppTokens.manrope(
                                    size: 20,
                                    weight: 700,
                                    color: AppTokens.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${list.length} total',
                                style: AppTokens.manrope(
                                  size: 13,
                                  weight: 600,
                                  color: AppTokens.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (_error)
                            _EmptyState(
                              icon: Icons.error_outline,
                              message: "Couldn't load your certificates.",
                              action: 'Retry',
                              onAction: _load,
                            )
                          else if (_all.isEmpty)
                            const _EmptyState(
                              icon: Icons.workspace_premium_outlined,
                              message:
                                  'You have no certificates yet. Complete a '
                                  'course to earn one.',
                            )
                          else if (list.isEmpty)
                            const _EmptyState(
                              icon: Icons.search_off,
                              message: 'No certificates match your search.',
                            )
                          else
                            for (final c in list) ...[
                              _CertificateCard(
                                certificate: c,
                                onView: () => _onAction(c),
                              ),
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
  const _EmptyState({
    required this.icon,
    required this.message,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppTokens.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                size: 14,
                weight: 500,
                color: AppTokens.textSecondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTokens.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAction,
                child: Text(
                  action!,
                  style: AppTokens.manrope(
                    size: 14,
                    weight: 700,
                    color: AppTokens.primary,
                  ),
                ),
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
  const _SummaryCard({
    required this.value,
    required this.label,
    this.highlight = false,
  });

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
            child: Text(
              value,
              style: AppTokens.manrope(
                size: 26,
                weight: 700,
                color: AppTokens.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTokens.manrope(
              size: 13,
              weight: 400,
              color: AppTokens.textSecondary,
            ),
          ),
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
        size: 14,
        weight: 400,
        color: AppTokens.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Search certificates',
        hintStyle: AppTokens.manrope(
          size: 14,
          weight: 400,
          color: AppTokens.placeholder,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppTokens.textSecondary,
          size: 22,
        ),
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
  final Certificate certificate;
  final VoidCallback onView;
  const _CertificateCard({required this.certificate, required this.onView});

  @override
  Widget build(BuildContext context) {
    final c = certificate;
    final year = _year(c.issueDate);
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
                child: Text(
                  c.course,
                  style: AppTokens.manrope(
                    size: 20,
                    weight: 700,
                    color: AppTokens.textPrimary,
                  ),
                ),
              ),
              if (year != 0) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.lightGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$year',
                    style: AppTokens.manrope(
                      size: 16,
                      weight: 700,
                      color: AppTokens.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Code',
                  style: AppTokens.manrope(
                    size: 14,
                    weight: 600,
                    color: AppTokens.primary,
                  ),
                ),
              ),
              Text(
                c.identifier,
                style: AppTokens.manrope(
                  size: 14,
                  weight: 600,
                  color: AppTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED)),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Certificate',
            child: Text(
              c.title,
              style: AppTokens.manrope(
                size: 14,
                weight: 700,
                color: AppTokens.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Date attained',
            child: Text(
              _fmtDate(c.issueDate),
              style: AppTokens.manrope(
                size: 14,
                weight: 600,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Completion',
            child: Text(
              _fmtDate(c.completionDate),
              style: AppTokens.manrope(
                size: 14,
                weight: 600,
                color: AppTokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onView,
              // Mirror the LMS: an issued certificate downloads; an un-issued
              // one is generated first. Reflects the web state on each reload.
              child: Text(
                c.generated ? 'Download certificate' : 'Generate certificate',
                style: AppTokens.manrope(
                  size: 14,
                  weight: 600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
          child: Text(
            label,
            style: AppTokens.manrope(
              size: 14,
              weight: 400,
              color: AppTokens.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(child: child),
      ],
    );
  }
}

/// Shown after a successful generate: download now as PDF / JPG, or not now.
class _GeneratedSheet extends StatelessWidget {
  final String course;
  const _GeneratedSheet({required this.course});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    Widget option(String fmt, IconData icon, String label) => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => Navigator.of(context).pop(fmt),
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: AppTokens.manrope(size: 15, weight: 700, color: Colors.white),
        ),
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 12 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppTokens.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTokens.lightGreen,
                border: Border.all(color: AppTokens.primary, width: 2),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTokens.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Certificate generated',
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                size: 21,
                weight: 700,
                color: AppTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              course.isEmpty
                  ? 'Would you like to download it now?'
                  : 'Your certificate for $course is ready. Would you like to '
                        'download it now?',
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                size: 14,
                weight: 400,
                height: 20,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            option('pdf', Icons.picture_as_pdf_outlined, 'Download as PDF'),
            const SizedBox(height: 10),
            option('jpg', Icons.image_outlined, 'Download as JPG'),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Not now',
                style: AppTokens.manrope(
                  size: 15,
                  weight: 700,
                  color: AppTokens.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
