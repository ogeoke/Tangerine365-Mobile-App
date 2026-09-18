import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/downloads.dart';
import 'package:sevenup_mobile/common/safety.dart';
import 'package:flutter/services.dart';
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

/// Which box the Messages screen is showing.
enum _Box { inbox, sent }

/// Messages (Figma 12A Inbox / 12B Sent). Search field, Inbox/Sent toggle, and
/// a list of message rows. Tapping a row opens the read/reply screen (12C).
/// Live data: `POST api/messages/inbox` and `POST api/messages/sent`.
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = ApiRepository();
  List<InfoMessage> _inbox = [];
  List<InfoMessage> _sent = [];
  int? _serverUnread;
  _Box _box = _Box.inbox;
  String _query = '';
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  static List<InfoMessage>? _parse(Map<String, dynamic>? data) {
    final list = data?['messages'];
    if (list is! List) return null;
    return list
        .whereType<Map>()
        .map((e) => InfoMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _repository.getMessages(sent: false),
      _repository.getMessages(sent: true),
    ]);
    if (!mounted) return;
    final inbox = _parse(results[0].body);
    final sent = _parse(results[1].body);
    final unread = results[0].body?['unread_count'];
    setState(() {
      if (inbox != null) _inbox = inbox;
      if (sent != null) _sent = sent;
      _serverUnread = unread is num ? unread.toInt() : int.tryParse('$unread');
      _error = inbox == null && sent == null;
      _loading = false;
    });
    // Keep the header bell in sync with what we just fetched.
    if (mounted) context.read<NotificationCubit>().load();
  }

  // Prefer the local count once rows are loaded so opening a message updates
  // the badge immediately; fall back to the server's unread_count.
  int get _unread => _inbox.isNotEmpty
      ? _inbox.where((m) => m.unread).length
      : (_serverUnread ?? 0);

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
    final replied = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            MessageDetailPage(message: m, sent: _box == _Box.sent),
      ),
    );
    if (!mounted) return;
    setState(() {}); // reflect read state immediately
    if (replied == true) {
      // "View Sent Items" after a reply: jump to the Sent box and refetch.
      setState(() => _box = _Box.sent);
    }
    _load();
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
                  : RefreshIndicator(
                      color: AppTokens.primary,
                      onRefresh: _load,
                      child: _error
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [_ErrorMessages(onRetry: _load)],
                            )
                          : visible.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [_EmptyMessages()],
                                )
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
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
                        Flexible(
                          child: Text(
                            m.timeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTokens.manrope(
                                size: 13,
                                weight: 400,
                                color: AppTokens.textSecondary),
                          ),
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

class _ErrorMessages extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorMessages({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTokens.screenPadding),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 34, color: AppTokens.accent),
          const SizedBox(height: 18),
          Text("Couldn't load messages",
              style: AppTokens.manrope(
                  size: 22, weight: 700, color: AppTokens.textPrimary)),
          const SizedBox(height: 10),
          Text('Check your connection and retry.',
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 14, weight: 400, color: AppTokens.textSecondary)),
          const SizedBox(height: 18),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry',
                style: AppTokens.manrope(
                    size: 15, weight: 700, color: AppTokens.primary)),
          ),
        ],
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

  /// True when opened from the Sent box (no reply composer, no mark-read).
  final bool sent;
  const MessageDetailPage(
      {super.key, required this.message, this.sent = false});

  @override
  State<MessageDetailPage> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = TextEditingController();
  final _repository = ApiRepository();
  _ReplyState _state = _ReplyState.idle;
  late InfoMessage _message = widget.message;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    if (!widget.sent && widget.message.unread) _markRead();
  }

  /// Refresh the full message (body / attachment) from `messages/getMessage`.
  Future<void> _loadDetail() async {
    final res = await _repository.getMessage(widget.message.id);
    final data = res.body;
    if (!mounted || data == null || data.isEmpty) return;
    final fresh = InfoMessage.fromJson(data);
    if (fresh.id.isEmpty) return;
    fresh.unread = false;
    setState(() => _message = fresh);
  }

  /// Opening an inbox message marks it read on the server, then refreshes the
  /// header bell. The row is updated optimistically.
  Future<void> _markRead() async {
    widget.message.unread = false;
    await _repository.markMessageRead(widget.message.id);
    if (mounted) context.read<NotificationCubit>().load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      setState(() => _state = _ReplyState.validationError);
      return;
    }
    setState(() => _state = _ReplyState.sending);
    final res = await _repository.replyToMessage(_message.threadId, content);
    if (!mounted) return;
    final body = res.body;
    final ok = res.isSuccessful &&
        body != null &&
        (body['success'] == true || body['status'] == 'success');
    setState(() => _state = ok ? _ReplyState.sent : _ReplyState.failed);
  }

  /// Download the attachment into the phone's Downloads folder (same native
  /// MediaStore channel the certificates use).
  Future<void> _downloadAttachment(InfoMessage m) async {
    final url = m.attachmentUrl;
    if (url == null || _downloading) return;
    setState(() => _downloading = true);
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      final res = await req.close();
      if (res.statusCode != 200) {
        throw HttpException('HTTP ${res.statusCode}');
      }
      final bytes = await consolidateHttpClientResponseBytes(res);
      final name = safeFileName(m.attachmentDisplayName);
      final mime = _mimeFor(name);
      final saved = await Downloads.save(
        filename: name,
        mimeType: mime,
        bytes: bytes,
      );
      if (!mounted) return;
      Downloads.showSaved(context,
          name: saved.name, uri: saved.uri, mimeType: mime);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Could not download the attachment.')));
    } finally {
      client.close();
      if (mounted) setState(() => _downloading = false);
    }
  }

  static String _mimeFor(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    const types = {
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain',
      'csv': 'text/csv',
      'zip': 'application/zip',
    };
    return types[ext] ?? 'application/octet-stream';
  }

  Future<void> _openAttachment(String url) async {
    if (!await openExternalUrl(url)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the attachment.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = _message;
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
              // Inbox: who sent it to you. Sent box: the API has no recipient.
              subtitle: widget.sent ? 'Sent message' : 'From ${m.sender}',
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
                              if (m.senderRole.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(m.senderRole,
                                    style: AppTokens.manrope(
                                        size: 14,
                                        weight: 400,
                                        color: AppTokens.textSecondary)),
                              ],
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
                  if (m.attachmentUrl != null) ...[
                    const SizedBox(height: 14),
                    Material(
                      color: AppTokens.surface,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _openAttachment(m.attachmentUrl!),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTokens.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (m.attachmentIsImage) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: m.attachmentUrl!,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                        height: 180,
                                        color: AppTokens.lightGreen),
                                    // Preview failed: keep just the file row.
                                    errorWidget: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Row(
                                children: [
                                  const Icon(Icons.attach_file,
                                      color: AppTokens.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      m.attachmentDisplayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTokens.manrope(
                                          size: 14,
                                          weight: 600,
                                          color: AppTokens.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 44,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTokens.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: _downloading
                                      ? null
                                      : () => _downloadAttachment(m),
                                  icon: _downloading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Icon(Icons.download_rounded,
                                          color: Colors.white, size: 20),
                                  label: Text(
                                      _downloading
                                          ? 'Downloading…'
                                          : 'Download attachment',
                                      style: AppTokens.manrope(
                                          size: 15,
                                          weight: 700,
                                          color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (!widget.sent) ...[
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
                      // Back to the composer; the typed text is kept.
                      onRetry: () =>
                          setState(() => _state = _ReplyState.idle),
                      onViewSent: () => Navigator.of(context).pop(true),
                    ),
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
