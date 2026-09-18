import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/state/notifications/notification_cubit.dart';
import 'package:sevenup_mobile/views/announcements_page.dart';
import 'package:sevenup_mobile/views/communications_page.dart';
import 'package:sevenup_mobile/views/messages_page.dart';

/// Information Management hub (Figma 20A) — the first screen after tapping the
/// Information Management service. Surfaces the module's two features:
/// Announcements, Communications and Messages. Unread counts come from the live
/// `notifications/counts` endpoint via [NotificationCubit].
class InfoManagementPage extends StatelessWidget {
  static const routeName = '/information';
  const InfoManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    // Throttled refresh (no-op if the counts were fetched recently).
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<NotificationCubit>().loadIfStale());
    final counts = context.watch<NotificationCubit>().state;
    final unreadAnnouncements = counts.announcements;
    final unreadCommunications = counts.communications;
    final newMessages = counts.messages;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Information Management',
              subtitle: 'Announcements, communications and messages',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 20, AppTokens.screenPadding, 24),
                children: [
                  Text(
                    'INFORMATION',
                    style: AppTokens.manrope(
                        size: 13,
                        weight: 700,
                        color: AppTokens.primary,
                        letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stay informed',
                    style: AppTokens.manrope(
                        size: 30, weight: 700, color: AppTokens.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Read organizational announcements and communications, and '
                    'access your direct messages.',
                    style: AppTokens.manrope(
                        size: 15,
                        weight: 400,
                        height: 22,
                        color: AppTokens.textSecondary),
                  ),
                  const SizedBox(height: 26),
                  _FeatureCard(
                    icon: Icons.campaign_rounded,
                    title: 'Announcements',
                    description:
                        'Company updates, training notices and important '
                        'information.',
                    badge: unreadAnnouncements > 0
                        ? '$unreadAnnouncements unread'
                        : 'All read',
                    actionLabel: 'View',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AnnouncementsPage()),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 360.ms)
                      .slideY(
                          begin: 0.10,
                          end: 0,
                          duration: 360.ms,
                          curve: Curves.easeOut),
                  const SizedBox(height: 18),
                  _FeatureCard(
                    icon: Icons.forward_to_inbox_rounded,
                    title: 'Communications',
                    description:
                        'Policies, circulars and learning notices shared with '
                        'you.',
                    badge: unreadCommunications > 0
                        ? '$unreadCommunications unread'
                        : 'All read',
                    actionLabel: 'View',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CommunicationsPage()),
                    ),
                  )
                      .animate(delay: 90.ms)
                      .fadeIn(duration: 360.ms)
                      .slideY(
                          begin: 0.10,
                          end: 0,
                          duration: 360.ms,
                          curve: Curves.easeOut),
                  const SizedBox(height: 18),
                  _FeatureCard(
                    icon: Icons.forum_rounded,
                    title: 'Messages',
                    description:
                        'Inbox, sent items and replies from administrators.',
                    badge: newMessages > 0 ? '$newMessages new' : 'No new',
                    actionLabel: 'Open',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MessagesPage()),
                    ),
                  )
                      .animate(delay: 180.ms)
                      .fadeIn(duration: 360.ms)
                      .slideY(
                          begin: 0.10,
                          end: 0,
                          duration: 360.ms,
                          curve: Curves.easeOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A large tappable feature card on the hub (Announcements / Messages).
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String badge;
  final String actionLabel;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTokens.border),
          ),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTokens.lightGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTokens.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTokens.manrope(
                          size: 22,
                          weight: 700,
                          color: AppTokens.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppTokens.manrope(
                          size: 14,
                          weight: 400,
                          height: 20,
                          color: AppTokens.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppTokens.lightGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge,
                            style: AppTokens.manrope(
                                size: 13,
                                weight: 700,
                                color: AppTokens.primary),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          actionLabel,
                          style: AppTokens.manrope(
                              size: 15,
                              weight: 700,
                              color: AppTokens.primary),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward,
                            color: AppTokens.primary, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
