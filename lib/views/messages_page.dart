import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/common/skeleton.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/models/info_comms.dart';

/// Which box the Messages screen is showing.
enum _Box { inbox, sent }

/// Messages (Figma 12A Inbox / 12B Sent). Search field, Inbox/Sent toggle, and
/// a list of message rows. Tapping an inbox row opens the read/reply screen
/// (12C). Sample data until the messages endpoints exist.
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<InfoMessage> _inbox = sampleInbox();
  final List<InfoMessage> _sent = sampleSent();
  _Box _box = _Box.inbox;
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // No endpoint yet — briefly show the loading skeleton, then the list.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  int get _unread => _inbox.where((m) => m.unread).length;

  List<InfoMessage> get _source => _box == _Box.inbox ? _inbox : _sent;

  List<InfoMessage> get _visible {
    if (_query.trim().isEmpty) return _source;
    final q = _query.toLowerCase();
    return _source
        .where((m) =>
            m.sender.toLowerCase().contains(q) ||
            m.subject.toLowerCase().contains(q) ||
            m.preview.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _openMessage(InfoMessage m) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MessageDetailPage(message: m)),
    );
    setState(() {}); // reflect read state + any sent reply
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
              title: 'Messages',
              subtitle: 'Your messages and learning updates',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 16, AppTokens.screenPadding, 0),
              child: Column(
                children: [
                  _SearchField(
                      onChanged: (v) => setState(() => _query = v)),
                  const SizedBox(height: 16),
                  _BoxToggle(
                    box: _box,
                    inboxCount: _unread,
                    sentCount: _sent.length,
                    onSelect: (b) => setState(() => _box = b),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 18, AppTokens.screenPadding, 8),
              child: Row(
                children: [
                  Text(
                    _box == _Box.inbox ? 'Inbox' : 'Sent messages',
                    style: AppTokens.manrope(
                        size: 22, weight: 700, color: AppTokens.textPrimary),
                  ),
                  const Spacer(),
                  Text(
                    _box == _Box.inbox
                        ? '$_unread unread'
                        : '${_sent.length} sent',
                    style: AppTokens.manrope(
                        size: 14, weight: 600, color: AppTokens.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const SkeletonCards()
                  : visible.isEmpty
                      ? const _EmptyMessages()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              AppTokens.screenPadding,
                              4,
                              AppTokens.screenPadding,
                              24),
                          itemCount: visible.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) => _MessageRow(
                            message: visible[i],
                            sent: _box == _Box.sent,
                            onTap: () => _openMessage(visible[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTokens.manrope(size: 15, color: AppTokens.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search communications',
        hintStyle:
            AppTokens.manrope(size: 15, color: AppTokens.placeholder),
        prefixIcon: const Icon(Icons.search, color: AppTokens.textSecondary),
        filled: true,
        fillColor: AppTokens.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

class _BoxToggle extends StatelessWidget {
  final _Box box;
  final int inboxCount;
  final int sentCount;
  final ValueChanged<_Box> onSelect;
  const _BoxToggle({
    required this.box,
    required this.inboxCount,
    required this.sentCount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _pill('Inbox', inboxCount, _Box.inbox, box == _Box.inbox)),
        const SizedBox(width: 14),
        Expanded(
            child: _pill('Sent', sentCount, _Box.sent, box == _Box.sent)),
      ],
    );
  }

  Widget _pill(String label, int count, _Box value, bool active) {
    return GestureDetector(
      onTap: () => onSelect(value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppTokens.primary : AppTokens.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
              color: active ? AppTokens.primary : AppTokens.border),
        ),
        child: Text(
          count > 0 ? '$label · $count' : label,
          style: AppTokens.manrope(
            size: 16,
            weight: active ? 700 : 600,
            color: active ? Colors.white : AppTokens.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final InfoMessage message;
  final bool sent;
  final VoidCallback onTap;
  const _MessageRow(
      {required this.message, required this.sent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final m = message;
    final unread = m.unread && !sent;
    return Material(
      color: unread ? AppTokens.lightGreen.withOpacity(0.5) : AppTokens.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: unread ? Colors.transparent : AppTokens.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    unread ? AppTokens.lightGreen : const Color(0xFFEDEFED),
                child: Text(
                  sent ? 'YO' : m.initials,
                  style: AppTokens.manrope(
                      size: 15, weight: 700, color: AppTokens.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            m.sender,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTokens.manrope(
                                size: 16,
                                weight: 700,
                                color: AppTokens.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          m.timeLabel,
                          style: AppTokens.manrope(
                              size: 13,
                              weight: 400,
                              color: AppTokens.textSecondary),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                                color: AppTokens.primary,
                                shape: BoxShape.circle),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.manrope(
                          size: 15,
                          weight: 700,
                          color: AppTokens.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      m.preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.manrope(
                          size: 14,
                          weight: 400,
                          height: 19,
                          color: AppTokens.textSecondary),
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

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppTokens.screenPadding),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
        decoration: BoxDecoration(
          color: AppTokens.surface,
          borderRadius: BorderRadius.circular(20),
        ),
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
            const SizedBox(height: 22),
            Text('No messages yet',
                style: AppTokens.manrope(
                    size: 22, weight: 700, color: AppTokens.textPrimary)),
            const SizedBox(height: 10),
            Text('New messages and announcements will appear here.',
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                    size: 14,
                    weight: 400,
                    height: 20,
                    color: AppTokens.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Read message + reply (Figma 12C / 12D / 12D1 / 12E / 12F / 12G)
// ---------------------------------------------------------------------------

/// The lifecycle of the reply composer at the bottom of a read message.
enum _ReplyState { idle, validationError, sending, sent, failed }

class MessageDetailPage extends StatefulWidget {
  final InfoMessage message;
  const MessageDetailPage({super.key, required this.message});

  @override
  State<MessageDetailPage> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = TextEditingController();
  _ReplyState _state = _ReplyState.idle;

  @override
  void initState() {
    super.initState();
    // Opening an inbox message marks it read.
    widget.message.unread = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) {
      setState(() => _state = _ReplyState.validationError);
      return;
    }
    setState(() => _state = _ReplyState.sending);
    // No endpoint yet — simulate a send round-trip.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _state = _ReplyState.sent);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Read Message',
              subtitle: 'Inbox · ${m.sender}',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 16, AppTokens.screenPadding, 20),
                children: [
                  // Sender card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTokens.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTokens.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTokens.lightGreen,
                          child: Text(m.initials,
                              style: AppTokens.manrope(
                                  size: 15,
                                  weight: 700,
                                  color: AppTokens.primary)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.sender,
                                  style: AppTokens.manrope(
                                      size: 17,
                                      weight: 700,
                                      color: AppTokens.textPrimary)),
                              const SizedBox(height: 2),
                              Text(m.senderRole,
                                  style: AppTokens.manrope(
                                      size: 14,
                                      weight: 400,
                                      color: AppTokens.textSecondary)),
                              const SizedBox(height: 2),
                              Text(m.fullDate,
                                  style: AppTokens.manrope(
                                      size: 13,
                                      weight: 400,
                                      color: AppTokens.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text('SUBJECT',
                      style: AppTokens.manrope(
                          size: 13,
                          weight: 700,
                          color: AppTokens.primary,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Text(m.subject,
                      style: AppTokens.manrope(
                          size: 23,
                          weight: 700,
                          height: 30,
                          color: AppTokens.textPrimary)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTokens.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTokens.border),
                    ),
                    child: Text(m.body,
                        style: AppTokens.manrope(
                            size: 15,
                            weight: 400,
                            height: 23,
                            color: AppTokens.textPrimary)),
                  ),
                  const SizedBox(height: 22),
                  _ReplyComposer(
                    controller: _controller,
                    state: _state,
                    onChanged: () {
                      if (_state == _ReplyState.validationError) {
                        setState(() => _state = _ReplyState.idle);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  _ReplyButton(
                    state: _state,
                    onSend: _send,
                    onRetry: () => setState(() => _state = _ReplyState.idle),
                    onViewSent: () => Navigator.of(context).maybePop(),
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

/// The reply text area, which changes appearance per [state]
/// (Figma 12C idle, 12D validation, 12D1 composed, 12F sent, 12G failed).
class _ReplyComposer extends StatelessWidget {
  final TextEditingController controller;
  final _ReplyState state;
  final VoidCallback onChanged;
  const _ReplyComposer({
    required this.controller,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final error = state == _ReplyState.validationError;
    final failed = state == _ReplyState.failed;
    final sent = state == _ReplyState.sent;
    final label = failed
        ? 'Reply not sent'
        : sent
            ? 'Reply sent'
            : 'Reply';
    Color borderColor = AppTokens.primary.withOpacity(0.5);
    if (error || failed) borderColor = AppTokens.accent;

    Widget field;
    if (sent) {
      field = _StatusBox(
        text: 'Your reply was sent successfully and added to Sent Items.',
        borderColor: AppTokens.primary.withOpacity(0.5),
      );
    } else if (failed) {
      field = _StatusBox(
        text: 'We couldn’t send your reply. Please enter your message again '
            'and retry.',
        borderColor: AppTokens.accent,
      );
    } else {
      field = Container(
        decoration: BoxDecoration(
          color: AppTokens.lightGreen.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: error ? 2 : 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          minLines: 4,
          maxLines: 6,
          enabled: state != _ReplyState.sending,
          style: AppTokens.manrope(size: 15, color: AppTokens.textPrimary),
          decoration: InputDecoration(
            hintText: 'Write your reply…',
            hintStyle:
                AppTokens.manrope(size: 15, color: AppTokens.textSecondary),
            border: InputBorder.none,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTokens.manrope(
                size: 20, weight: 700, color: AppTokens.textPrimary)),
        const SizedBox(height: 12),
        field,
        if (error) ...[
          const SizedBox(height: 8),
          Text('Enter a reply before sending.',
              style: AppTokens.manrope(
                  size: 13, weight: 600, color: AppTokens.accent)),
        ],
      ],
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String text;
  final Color borderColor;
  const _StatusBox({required this.text, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: AppTokens.lightGreen.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Text(text,
          style: AppTokens.manrope(
              size: 15,
              weight: 400,
              height: 21,
              color: AppTokens.textSecondary)),
    );
  }
}

class _ReplyButton extends StatelessWidget {
  final _ReplyState state;
  final VoidCallback onSend;
  final VoidCallback onRetry;
  final VoidCallback onViewSent;
  const _ReplyButton({
    required this.state,
    required this.onSend,
    required this.onRetry,
    required this.onViewSent,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    VoidCallback? onTap;
    bool sending = false;
    switch (state) {
      case _ReplyState.sending:
        label = 'Sending…';
        onTap = null;
        sending = true;
        break;
      case _ReplyState.sent:
        label = 'View Sent Items';
        onTap = onViewSent;
        break;
      case _ReplyState.failed:
        label = 'Try Again';
        onTap = onRetry;
        break;
      case _ReplyState.idle:
      case _ReplyState.validationError:
        label = 'Send reply';
        onTap = onSend;
        break;
    }
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              sending ? AppTokens.primary.withOpacity(0.55) : AppTokens.primary,
          disabledBackgroundColor: AppTokens.primary.withOpacity(0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: sending
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(label,
                      style: AppTokens.manrope(
                          size: 16, weight: 700, color: Colors.white)),
                ],
              )
            : Text(label,
                style: AppTokens.manrope(
                    size: 16, weight: 700, color: Colors.white)),
      ),
    );
  }
}
