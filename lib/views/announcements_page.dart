import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/common/skeleton.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/info_comms.dart';
import 'package:sevenup_mobile/state/notifications/notification_cubit.dart';

/// Which announcements the list is filtered to.
enum _AnnFilter { unread, all, read }

/// Announcements list (Figma 20B): Unread / All / Read segmented filter over a
/// list of announcement cards. Tapping a card opens the detail (20C / 20D).
/// Sample data until the announcements endpoint exists.
class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = ApiRepository();
  List<Announcement> _items = [];
  _AnnFilter _filter = _AnnFilter.unread;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted && !_loading) setState(() => _error = false);
    final res = await _repository.getAnnouncements();
    if (!mounted) return;
    final body = res.body;
    final list =
        (body != null && body['data'] is List) ? body['data'] as List : null;
    setState(() {
      if (list != null) {
        _items = list
            .whereType<Map>()
            .map((e) => Announcement.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _error = false;
      } else {
        _error = true;
      }
      _loading = false;
    });
    // Keep the header bell in sync with the announcements we just fetched.
    if (mounted) context.read<NotificationCubit>().load();
  }

  List<Announcement> get _visible {
    switch (_filter) {
      case _AnnFilter.unread:
        return _items.where((a) => !a.read).toList();
      case _AnnFilter.read:
        return _items.where((a) => a.read).toList();
      case _AnnFilter.all:
        return _items;
    }
  }

  int get _unreadCount => _items.where((a) => !a.read).length;

  Future<void> _open(Announcement a) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AnnouncementDetailPage(announcement: a)),
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
              title: 'Announcements',
              subtitle: 'Organizational updates and notices',
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
                              _AnnouncementCard(
                                announcement: visible[i],
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
  final _AnnFilter selected;
  final int unreadCount;
  final ValueChanged<_AnnFilter> onSelect;
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
              _AnnFilter.unread),
          _tab('All', _AnnFilter.all),
          _tab('Read', _AnnFilter.read),
        ],
      ),
    );
  }

  Widget _tab(String label, _AnnFilter value) {
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

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;
  const _AnnouncementCard({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = announcement;
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
                    child: const Icon(Icons.campaign_rounded,
                        color: AppTokens.primary, size: 24),
                  ),
                  const Spacer(),
                  if (!a.read)
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
                a.title,
                style: AppTokens.manrope(
                    size: 19, weight: 700, height: 25, color: AppTokens.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                a.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTokens.manrope(
                    size: 14,
                    weight: 400,
                    height: 20,
                    color: AppTokens.textSecondary),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      a.tag == null ? a.category : '${a.category} • ${a.tag}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.manrope(
                          size: 13,
                          weight: 400,
                          color: AppTokens.textSecondary),
                    ),
                  ),
                  if (!a.read) ...[
                    Text(
                      'Read',
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
  final _AnnFilter filter;
  const _EmptyFilter({required this.filter});

  @override
  Widget build(BuildContext context) {
    final label = filter == _AnnFilter.unread
        ? 'No unread announcements'
        : filter == _AnnFilter.read
            ? 'No read announcements yet'
            : 'No announcements yet';
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
            Text('New announcements will appear here.',
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
            Text("Couldn't load announcements.",
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

/// Announcement detail (Figma 20C read / 20D not-read). A status banner, the
/// announcement header and body, and a primary action that marks it as read.
class AnnouncementDetailPage extends StatefulWidget {
  final Announcement announcement;
  const AnnouncementDetailPage({super.key, required this.announcement});

  @override
  State<AnnouncementDetailPage> createState() => _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = ApiRepository();
  bool _marking = false;

  Announcement get a => widget.announcement;

  Future<void> _markRead() async {
    if (_marking) return;
    setState(() => _marking = true);
    final res = await _repository.markAnnouncementRead(a.id);
    if (!mounted) return;
    if (res.isSuccessful) {
      setState(() {
        a.read = true;
        _marking = false;
      });
      context.read<NotificationCubit>().load(); // refresh the header bell
    } else {
      setState(() => _marking = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Could not mark as read.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final read = a.read;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Announcement',
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
                        child: const Icon(Icons.campaign_rounded,
                            color: AppTokens.primary, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          a.title,
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
                  Text(
                    a.author,
                    style: AppTokens.manrope(
                        size: 16, weight: 700, color: AppTokens.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Posted ${a.postedDate}',
                    style: AppTokens.manrope(
                        size: 14,
                        weight: 400,
                        color: AppTokens.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    a.body,
                    style: AppTokens.manrope(
                        size: 15,
                        weight: 400,
                        height: 23,
                        color: AppTokens.textPrimary),
                  ),
                  const SizedBox(height: 30),
                  if (!read)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _marking ? null : _markRead,
                        child: _marking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text('Mark as read',
                                style: AppTokens.manrope(
                                    size: 16,
                                    weight: 700,
                                    color: Colors.white)),
                      ),
                    )
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
                        child: Text('Back to announcements',
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
