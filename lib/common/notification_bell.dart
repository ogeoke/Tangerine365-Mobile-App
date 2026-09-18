import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/state/notifications/notification_cubit.dart';
import 'package:sevenup_mobile/views/announcements_page.dart';
import 'package:sevenup_mobile/views/communications_page.dart';
import 'package:sevenup_mobile/views/messages_page.dart';

/// The notification bell used in the Home and module headers: shows the unread
/// total badge (from [NotificationCubit]) and opens a breakdown sheet on tap.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  @override
  void initState() {
    super.initState();
    // Refresh (throttled) whenever a bell appears.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationCubit>().loadIfStale();
    });
  }

  void _open(BuildContext context) {
    context.read<NotificationCubit>().load(); // fresh counts on open
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocBuilder<NotificationCubit, NotificationState>(
        builder: (_, s) => _NotificationSheet(state: s),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, s) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _open(context),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded,
                    color: AppTokens.primary, size: 27),
                if (s.total > 0)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTokens.accent,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        s.total > 9 ? '9+' : '${s.total}',
                        style: AppTokens.manrope(
                            size: 10, weight: 700, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationSheet extends StatelessWidget {
  final NotificationState state;
  const _NotificationSheet({required this.state});

  @override
  Widget build(BuildContext context) {
    // Keep the last row clear of the system nav/gesture area at the bottom.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                  color: AppTokens.border,
                  borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 18),
          Text('Notifications',
              style: AppTokens.manrope(
                  size: 22, weight: 700, color: AppTokens.textPrimary)),
          const SizedBox(height: 4),
          Text(
            state.total == 0
                ? "You're all caught up."
                : 'You have ${state.total} unread ${state.total == 1 ? 'item' : 'items'}.',
            style: AppTokens.manrope(
                size: 13, weight: 400, color: AppTokens.textSecondary),
          ),
          const SizedBox(height: 18),
          _CountRow(
            icon: Icons.mail_outline,
            label: 'Messages',
            count: state.messages,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop(); // close the sheet
              nav.push(
                  MaterialPageRoute(builder: (_) => const MessagesPage()));
            },
          ),
          _CountRow(
            icon: Icons.campaign_outlined,
            label: 'Communications',
            count: state.communications,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop(); // close the sheet
              nav.push(MaterialPageRoute(
                  builder: (_) => const CommunicationsPage()));
            },
          ),
          _CountRow(
            icon: Icons.notifications_active_outlined,
            label: 'Announcements',
            count: state.announcements,
            onTap: () {
              final nav = Navigator.of(context);
              nav.pop(); // close the sheet
              nav.push(MaterialPageRoute(
                  builder: (_) => const AnnouncementsPage()));
            },
          ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onTap;
  const _CountRow(
      {required this.icon,
      required this.label,
      required this.count,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppTokens.lightGreen, shape: BoxShape.circle),
            child: Icon(icon, color: AppTokens.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: AppTokens.manrope(
                    size: 15, weight: 600, color: AppTokens.textPrimary)),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 30),
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: count > 0 ? AppTokens.accent : const Color(0xFFEDEFEC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('$count',
                style: AppTokens.manrope(
                    size: 13,
                    weight: 700,
                    color: count > 0 ? Colors.white : AppTokens.textSecondary)),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                size: 20, color: AppTokens.textSecondary),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: row,
    );
  }
}
