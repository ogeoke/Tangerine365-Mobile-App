import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/safety.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/common/skeleton.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/info_comms.dart';
import 'package:sevenup_mobile/state/notifications/notification_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// Which communications the list is filtered to.
enum _CommFilter { unread, all, read }

/// Communications list — same layout as Announcements (20B): Unread / All /
/// Read segmented filter over cards. Live from `POST api/communications`.
class CommunicationsPage extends StatefulWidget {
  const CommunicationsPage({super.key});

  @override
  State<CommunicationsPage> createState() => _CommunicationsPageState();
}

class _CommunicationsPageState extends State<CommunicationsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = ApiRepository();
  List<CommunicationItem> _items = [];
  _CommFilter _filter = _CommFilter.unread;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted && !_loading) setState(() => _error = false);
    final res = await _repository.getCommunications();
    if (!mounted) return;
    final data = res.body?['data'];
    final list = (data is Map && data['communications'] is List)
        ? data['communications'] as List
        : null;
    setState(() {
      if (list != null) {
        _items = list
            .whereType<Map>()
            .map((e) =>
                CommunicationItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _error = false;
      } else {
        _error = true;
      }
      _loading = false;
    });
    if (mounted) context.read<NotificationCubit>().load();
  }

  List<CommunicationItem> get _visible {
    switch (_filter) {
      case _CommFilter.unread:
        return _items.where((c) => !c.read).toList();
      case _CommFilter.read:
        return _items.where((c) => c.read).toList();
      case _CommFilter.all:
        return _items;
    }
  }

  int get _unreadCount => _items.where((c) => !c.read).length;

  Future<void> _open(CommunicationItem c) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => CommunicationDetailPage(communication: c)),
    );
    setState(() {}); // reflect read state changed on the detail screen
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Communications',
              subtitle: 'Policies, circulars and learning notices',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 16, AppTokens.screenPadding, 8),
              child: _FilterTabs(
                selected: _filter,
                unreadCount: _unreadCount,
                onSelect: (f) => setState(() => _filter = f),
              ),
            ),
            Expanded(
              child: _loading
                  ? const SkeletonCards()
                  : RefreshIndicator(
                      color: AppTokens.primary,
                      onRefresh: _load,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                            AppTokens.screenPadding, 8,
                            AppTokens.screenPadding, 24),
                        children: [
                          if (_error && _items.isEmpty)
                            _ErrorState(onRetry: _load)
                          else if (visible.isEmpty)
                            _EmptyFilter(filter: _filter)
                          else
                            for (var i = 0; i < visible.length; i++) ...[
                              _CommunicationCard(
                                communication: visible[i],
                                onTap: () => _open(visible[i]),
                              ),
                              if (i != visible.length - 1)
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

class _FilterTabs extends StatelessWidget {
  final _CommFilter selected;
  final int unreadCount;
  final ValueChanged<_CommFilter> onSelect;
  const _FilterTabs({
    required this.selected,
    required this.unreadCount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppTokens.lightGreen.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tab('Unread${unreadCount > 0 ? '  $unreadCount' : ''}',
              _CommFilter.unread),
          _tab('All', _CommFilter.all),
          _tab('Read', _CommFilter.read),
        ],
      ),
    );
  }

  Widget _tab(String label, _CommFilter value) {
    final active = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: 42),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppTokens.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: AppTokens.manrope(
              size: 14,
              weight: active ? 700 : 600,
              color: active ? Colors.white : AppTokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(CommunicationItem c) {
  switch (c.type) {
    case 'file':
      return Icons.description_rounded;
    case 'scorm':
      return Icons.school_rounded;
    default:
      return Icons.forward_to_inbox_rounded;
  }
}

class _CommunicationCard extends StatelessWidget {
  final CommunicationItem communication;
  final VoidCallback onTap;
  const _CommunicationCard({required this.communication, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = communication;
    final meta = [
      if (c.category.isNotEmpty) c.category,
      if (c.publishDate.isNotEmpty) c.publishDate,
    ].join(' • ');
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
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTokens.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_iconFor(c),
                        color: AppTokens.primary, size: 24),
                  ),
                  const Spacer(),
                  if (!c.read)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTokens.lightGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'NOT READ',
                        style: AppTokens.manrope(
                            size: 11,
                            weight: 700,
                            color: AppTokens.primary,
                            letterSpacing: 0.4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                c.title,
                style: AppTokens.manrope(
                    size: 19,
                    weight: 700,
                    height: 25,
                    color: AppTokens.textPrimary),
              ),
              if (c.summary.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  c.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTokens.manrope(
                      size: 14,
                      weight: 400,
                      height: 20,
                      color: AppTokens.textSecondary),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.manrope(
                          size: 13,
                          weight: 400,
                          color: AppTokens.textSecondary),
                    ),
                  ),
                  if (!c.read) ...[
                    Text(
                      c.isText ? 'Read' : 'Open',
                      style: AppTokens.manrope(
                          size: 14, weight: 700, color: AppTokens.primary),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward,
                        color: AppTokens.primary, size: 16),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFilter extends StatelessWidget {
  final _CommFilter filter;
  const _EmptyFilter({required this.filter});

  @override
  Widget build(BuildContext context) {
    final label = filter == _CommFilter.unread
        ? 'No unread communications'
        : filter == _CommFilter.read
            ? 'No read communications yet'
            : 'No communications yet';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTokens.primary, width: 2),
              ),
            ),
            const SizedBox(height: 18),
            Text(label,
                style: AppTokens.manrope(
                    size: 18, weight: 700, color: AppTokens.textPrimary)),
            const SizedBox(height: 8),
            Text('New communications will appear here.',
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                    size: 14, weight: 400, color: AppTokens.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 40, color: AppTokens.textSecondary),
            const SizedBox(height: 12),
            Text("Couldn't load communications.",
                style: AppTokens.manrope(
                    size: 14, weight: 500, color: AppTokens.textSecondary)),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTokens.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              child: Text('Retry',
                  style: AppTokens.manrope(
                      size: 14, weight: 700, color: AppTokens.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Communication detail — same layout as the announcement detail (20C / 20D).
/// Text communications can be marked read here; file/SCORM ones must be
/// completed through their learning resource, so we open it instead.
class CommunicationDetailPage extends StatefulWidget {
  final CommunicationItem communication;
  const CommunicationDetailPage({super.key, required this.communication});

  @override
  State<CommunicationDetailPage> createState() =>
      _CommunicationDetailPageState();
}

class _CommunicationDetailPageState extends State<CommunicationDetailPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = ApiRepository();
  bool _marking = false;

  CommunicationItem get c => widget.communication;

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _markRead() async {
    if (_marking) return;
    setState(() => _marking = true);
    final res = await _repository.markCommunicationRead(c.id);
    if (!mounted) return;
    if (res.isSuccessful) {
      setState(() {
        c.read = true;
        _marking = false;
      });
      context.read<NotificationCubit>().load(); // refresh the header bell
    } else {
      setState(() => _marking = false);
      _snack('Could not mark as read.');
    }
  }

  Future<void> _openResource() async {
    final ok = await openExternalUrl(c.actionUrl);
    if (!ok && mounted) {
      _snack('Please complete this communication on the LMS.');
    }
  }

  Widget _primaryButton(String label, VoidCallback? onPressed,
      {bool busy = false}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.primary,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onPressed,
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: AppTokens.manrope(
                    size: 16, weight: 700, color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final read = c.read;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Communication',
              subtitle: read ? 'Read' : 'Not read',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 18, AppTokens.screenPadding, 20),
                children: [
                  // Status banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTokens.lightGreen.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        if (read) ...[
                          const Icon(Icons.mark_email_read_outlined,
                              color: AppTokens.primary, size: 22),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          read ? 'READ' : 'NOT READ',
                          style: AppTokens.manrope(
                              size: 14,
                              weight: 700,
                              color: AppTokens.primary,
                              letterSpacing: 0.4),
                        ),
                        const Spacer(),
                        if (read)
                          Text('Marked as read',
                              style: AppTokens.manrope(
                                  size: 13,
                                  weight: 400,
                                  color: AppTokens.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTokens.lightGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_iconFor(c),
                            color: AppTokens.primary, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          c.title,
                          style: AppTokens.manrope(
                              size: 24,
                              weight: 700,
                              height: 30,
                              color: AppTokens.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (c.category.isNotEmpty)
                    Text(
                      c.category,
                      style: AppTokens.manrope(
                          size: 16, weight: 700, color: AppTokens.primary),
                    ),
                  if (c.publishDate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Published ${c.publishDate}',
                      style: AppTokens.manrope(
                          size: 14,
                          weight: 400,
                          color: AppTokens.textSecondary),
                    ),
                  ],
                  if (c.course != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Course: ${c.course}',
                      style: AppTokens.manrope(
                          size: 14,
                          weight: 400,
                          color: AppTokens.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    c.body,
                    style: AppTokens.manrope(
                        size: 15,
                        weight: 400,
                        height: 23,
                        color: AppTokens.textPrimary),
                  ),
                  const SizedBox(height: 30),
                  if (!read && c.isText)
                    _primaryButton('Mark as read',
                        _marking ? null : _markRead,
                        busy: _marking)
                  else if (!read)
                    _primaryButton(
                        c.type == 'scorm' ? 'Start learning' : 'Open file',
                        _openResource)
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTokens.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: Text('Back to communications',
                            style: AppTokens.manrope(
                                size: 16,
                                weight: 700,
                                color: AppTokens.primary)),
                      ),
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
