/// Plain UI models for the Information Management module (Announcements,
/// Communications and Messages), built from the live API via their `fromJson`
/// factories. The `sample*` lists below are legacy placeholders (unused).
library;

import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/constants/env.dart';

/// A single organizational announcement (Figma 20B / 20C / 20D).
class Announcement {
  final String id;
  final String title;

  /// A short one-line summary shown as the card preview (Figma 20B). Kept
  /// separate from [body] so the list shows a punchy line, not the greeting.
  final String summary;
  final String body;
  final String author;

  /// Short source/category shown in the list meta line, e.g. "Operations".
  final String category;

  /// Optional secondary tag shown after the category, e.g. "Fire Safety".
  final String? tag;

  /// Human date shown on the detail screen, e.g. "21 Aug 2026".
  final String postedDate;
  bool read;

  Announcement({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.author,
    required this.category,
    this.tag,
    required this.postedDate,
    this.read = false,
  });

  /// Build from `POST /api/announcements` item (`body` is HTML).
  factory Announcement.fromJson(Map<String, dynamic> j) {
    final plain = htmlToPlainText(j['body']?.toString() ?? '');
    final oneLine = plain.replaceAll('\n', ' ').trim();
    final tag = j['tag']?.toString();
    return Announcement(
      id: '${j['id']}',
      title: j['title']?.toString() ?? '',
      summary: oneLine.length > 140
          ? '${oneLine.substring(0, 140).trim()}…'
          : oneLine,
      body: plain,
      author: j['author']?.toString() ?? '',
      category: (j['category']?.toString().isNotEmpty ?? false)
          ? j['category'].toString()
          : (j['source']?.toString() ?? ''),
      tag: (tag != null && tag.isNotEmpty) ? tag : null,
      postedDate: j['postedDate']?.toString() ?? '',
      read: j['isRead'] == true,
    );
  }
}

/// A Communication-module record (`POST /api/communications`). Named
/// `CommunicationItem` to avoid clashing with the legacy `Communication` model.
class CommunicationItem {
  final String id;
  final String title;
  final String summary;
  final String body;
  final String category;

  /// Linked course title (`--` from the API means none → null).
  final String? course;

  /// Human publish date, e.g. "10 Sep 2026" (empty when the API sends none).
  final String publishDate;

  /// `none` = text (can be marked read here); `file` / `scorm` must be
  /// completed through their learning resource.
  final String type;
  final String? actionUrl;
  bool read;

  CommunicationItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    this.course,
    required this.publishDate,
    required this.type,
    this.actionUrl,
    this.read = false,
  });

  bool get isText => type.isEmpty || type == 'none';

  factory CommunicationItem.fromJson(Map<String, dynamic> j) {
    final plain = htmlToPlainText(j['description']?.toString() ?? '');
    final oneLine = plain.replaceAll('\n', ' ').trim();
    final course = j['course']?.toString().trim();
    final action = j['action'];
    final url = action is Map ? action['url']?.toString() : null;
    return CommunicationItem(
      id: '${j['id']}',
      title: j['title']?.toString() ?? '',
      summary: oneLine.length > 140
          ? '${oneLine.substring(0, 140).trim()}…'
          : oneLine,
      body: plain,
      category: j['category']?.toString() ?? '',
      course: (course == null || course.isEmpty || course == '--')
          ? null
          : course,
      publishDate: formatApiDate(j['publishDate']?.toString()),
      type: j['type']?.toString() ?? 'none',
      actionUrl: (url != null && url.isNotEmpty) ? url : null,
      read: j['isRead'] == true,
    );
  }
}

/// ISO date → "10 Sep 2026". Returns '' for missing/placeholder (pre-2000)
/// dates such as the LMS default `1900-01-01`.
String formatApiDate(String? iso) {
  final d = iso == null ? null : DateTime.tryParse(iso);
  if (d == null || d.year < 2000) return '';
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
    'Oct', 'Nov', 'Dec'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

/// Lightweight HTML → plain text (keeps paragraph/line breaks) for rendering
/// announcement/message bodies without a full HTML widget.
String htmlToPlainText(String h) {
  if (h.isEmpty) return '';
  var s = h
      .replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</\s*p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'</\s*(div|li|h[1-6])\s*>', caseSensitive: false),
          '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '');
  s = _decodeEntities(s)
      // The LMS DB can't store 4-byte emoji, so they arrive as literal "????".
      .replaceAll(RegExp(r' ?\?{4}'), '')
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n[ \t]+'), '\n');
  return s.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

const _namedEntities = {
  'nbsp': ' ', 'amp': '&', 'lt': '<', 'gt': '>', 'quot': '"', 'apos': "'",
  'rsquo': '’', 'lsquo': '‘', 'rdquo': '”', 'ldquo': '“', 'sbquo': '‚',
  'bdquo': '„', 'ndash': '–', 'mdash': '—', 'hellip': '…', 'bull': '•',
  'middot': '·', 'copy': '©', 'reg': '®', 'trade': '™', 'deg': '°',
  'euro': '€', 'pound': '£', 'cent': '¢', 'yen': '¥', 'times': '×',
  'divide': '÷', 'laquo': '«', 'raquo': '»', 'eacute': 'é', 'egrave': 'è',
  'aacute': 'á', 'agrave': 'à', 'ccedil': 'ç', 'ntilde': 'ñ', 'ouml': 'ö',
  'uuml': 'ü', 'auml': 'ä', 'szlig': 'ß',
};

/// Decode named (`&rsquo;`) and numeric (`&#8217;` / `&#x2019;`) entities.
String _decodeEntities(String s) {
  return s.replaceAllMapped(RegExp(r'&(#x[0-9a-fA-F]+|#\d+|[a-zA-Z]+);'), (m) {
    final e = m[1]!;
    if (e.startsWith('#')) {
      final code = e[1] == 'x' || e[1] == 'X'
          ? int.tryParse(e.substring(2), radix: 16)
          : int.tryParse(e.substring(1));
      return (code == null || code > 0x10FFFF)
          ? m[0]!
          : String.fromCharCode(code);
    }
    return _namedEntities[e] ?? m[0]!;
  });
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Row time label: "09:47" today, "Yesterday", else "18 Aug" (year added when
/// not the current year).
String _messageTimeLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return _hhmm(d);
  if (diff == 1) return 'Yesterday';
  final base = '${d.day} ${_months[d.month - 1]}';
  return d.year == now.year ? base : '$base ${d.year}';
}

/// Read-screen date: "21 Aug 2026 · 09:47".
String _messageFullDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year} · ${_hhmm(d)}';

/// A single message in the inbox or the sent box (Figma 12A / 12B / 12C).
class InfoMessage {
  final String id;
  final String sender;
  final String senderRole;
  final String subject;
  final String preview;
  final String body;

  /// Short time label shown at the top-right of the row, e.g. "09:47",
  /// "Yesterday", "18 Aug".
  final String timeLabel;

  /// Full date shown on the read-message header, e.g. "21 Aug 2026 · 09:47".
  final String fullDate;
  bool unread;

  /// Thread the message belongs to (replies attach to it).
  final String threadId;

  /// Optional attachment (`attachment.name` / `attachment.url`).
  final String? attachmentName;
  final String? attachmentUrl;

  InfoMessage({
    required this.id,
    required this.sender,
    required this.senderRole,
    required this.subject,
    required this.preview,
    required this.body,
    required this.timeLabel,
    required this.fullDate,
    this.unread = false,
    String? threadId,
    this.attachmentName,
    this.attachmentUrl,
  }) : threadId = threadId ?? id;

  /// Build from a `POST /api/messages/inbox|sent|getMessage` item. `body` /
  /// `text` may contain HTML; `timestamp` is ISO-8601 (falls back to `posted`).
  factory InfoMessage.fromJson(Map<String, dynamic> j) {
    final sender = j['sender'] is Map
        ? Map<String, dynamic>.from(j['sender'] as Map)
        : const <String, dynamic>{};
    final name = (sender['fullname']?.toString().trim().isNotEmpty ?? false)
        ? sender['fullname'].toString().trim()
        : '${sender['firstname'] ?? ''} ${sender['lastname'] ?? ''}'.trim();
    final body = htmlToPlainText((j['body'] ?? j['text'] ?? '').toString());
    final previewRaw = htmlToPlainText((j['preview'] ?? '').toString());
    final preview = (previewRaw.isNotEmpty ? previewRaw : body)
        .replaceAll('\n', ' ')
        .trim();
    final att = j['attachment'] is Map
        ? Map<String, dynamic>.from(j['attachment'] as Map)
        : const <String, dynamic>{};
    final attName = att['name']?.toString().trim();
    var attUrl = att['url']?.toString().trim();
    // The API sends the stored file name but `url: null`; LMS message
    // attachments live under files/appLms/message/<name>.
    if ((attUrl == null || attUrl.isEmpty) &&
        attName != null &&
        attName.isNotEmpty) {
      final base = GetIt.I<Env>().baseUrl;
      final b = base.endsWith('/') ? base : '$base/';
      attUrl = '${b}files/appLms/message/${Uri.encodeComponent(attName)}';
    }
    final when = DateTime.tryParse(j['timestamp']?.toString() ?? '') ??
        DateTime.tryParse(j['posted']?.toString() ?? '');
    return InfoMessage(
      id: '${j['id'] ?? j['id_message'] ?? ''}',
      threadId: '${j['threadId'] ?? j['id'] ?? ''}',
      sender: name.isNotEmpty ? name : 'Unknown sender',
      senderRole: '',
      subject: (j['subject'] ?? j['title'] ?? '').toString(),
      preview: preview,
      body: body,
      timeLabel: when == null ? '' : _messageTimeLabel(when.toLocal()),
      fullDate: when == null ? '' : _messageFullDate(when.toLocal()),
      unread: j['isUnread'] == true,
      attachmentName: (attName != null && attName.isNotEmpty) ? attName : null,
      attachmentUrl: (attUrl != null && attUrl.isNotEmpty) ? attUrl : null,
    );
  }

  /// Attachment name without the LMS storage prefix
  /// (`<idst>_<n>_<timestamp>_file.png` → `file.png`).
  String get attachmentDisplayName {
    final n = attachmentName ?? 'Attachment';
    return n.replaceFirst(RegExp(r'^\d+_\d+_\d+_'), '');
  }

  bool get attachmentIsImage => RegExp(r'\.(png|jpe?g|gif|webp)$',
          caseSensitive: false)
      .hasMatch(attachmentName ?? '');

  /// Avatar initials derived from the sender name: first + last initial for a
  /// multi-word name ("Learning Administration" → "LA"), or a single letter for
  /// a one-word name ("Tangerine365" → "T").
  String get initials {
    final parts =
        sender.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Sample data (placeholder until the Information Management endpoints exist).
// ---------------------------------------------------------------------------

List<Announcement> sampleAnnouncements() => [
      Announcement(
        id: 'a1',
        title: 'New Compliance Training Now Available',
        summary:
            'Complete the new Compliance & Ethics course before 30 June 2026.',
        body: 'Dear Team,\n\n'
            'We’re pleased to announce the launch of our new Compliance and '
            'Ethics Training course, now available on your LMS dashboard.\n\n'
            'Key topics include:\n'
            '• Anti-money laundering (AML)\n'
            '• Workplace ethics and conduct\n'
            '• Data privacy and security\n\n'
            'Deadline: June 30, 2026\n'
            'Estimated time: 45 minutes\n'
            'Certification: Yes, upon completion\n\n'
            'To begin, open My Courses and select Compliance and Ethics '
            'Training.\n\n'
            'Warm regards,\n'
            'Learning & Development Team',
        author: 'Learning & Development Team',
        category: 'Learning & Development',
        tag: 'Fire Safety',
        postedDate: '21 Aug 2026',
        read: false,
      ),
      Announcement(
        id: 'a2',
        title: 'Updated Workplace Safety Procedures',
        summary:
            'Review the revised safety guidance and complete the acknowledgement.',
        body: 'Dear Team,\n\n'
            'We have revised our workplace safety guidance in line with the '
            'latest regulatory requirements. Please review the updated '
            'procedures at your earliest convenience and complete the '
            'acknowledgement in My Courses.\n\n'
            'Regards,\n'
            'Operations',
        author: 'Operations',
        category: 'Operations',
        tag: '12 Aug 2026',
        postedDate: '12 Aug 2026',
        read: true,
      ),
    ];

List<InfoMessage> sampleInbox() => [
      InfoMessage(
        id: 'm1',
        sender: 'Learning Administration',
        senderRole: 'Training Administrator',
        subject: 'Reminder: Complete Your Assigned Training',
        preview: 'Please complete your assigned courses before Friday.',
        body: 'Hello,\n\n'
            'Please complete your assigned training courses before Friday, '
            '28 August 2026.\n\n'
            'Log in to your dashboard and continue any outstanding lessons.\n\n'
            'Regards,\n'
            'Learning Administration',
        timeLabel: '09:47',
        fullDate: '21 Aug 2026 · 09:47',
        unread: true,
      ),
      InfoMessage(
        id: 'm2',
        sender: 'Compliance Team',
        senderRole: 'Compliance Office',
        subject: 'Mandatory AML/CFT Refresher',
        preview: 'Your annual compliance training is now available.',
        body: 'Hello,\n\n'
            'Your annual AML/CFT refresher training is now available and is '
            'mandatory for all staff. Kindly complete it within two weeks.\n\n'
            'Regards,\n'
            'Compliance Team',
        timeLabel: '09:12',
        fullDate: '21 Aug 2026 · 09:12',
        unread: true,
      ),
      InfoMessage(
        id: 'm3',
        sender: 'Tangerine365',
        senderRole: 'Community',
        subject: 'Welcome to the Community Forum!',
        preview: 'Join the discussion and connect with other learners.',
        body: 'Hello,\n\n'
            'Welcome to the Tangerine365 Community Forum. Join the discussion, '
            'ask questions and connect with other learners across the '
            'organization.\n\n'
            'Regards,\n'
            'Tangerine365',
        timeLabel: 'Yesterday',
        fullDate: '20 Aug 2026 · 14:30',
        unread: true,
      ),
      InfoMessage(
        id: 'm4',
        sender: 'HR Learning',
        senderRole: 'Human Resources',
        subject: 'CPR Essentials enrolment confirmed',
        preview: 'You can now begin your newly assigned course.',
        body: 'Hello,\n\n'
            'Your enrolment in CPR Essentials has been confirmed. You can now '
            'begin the course from My Courses.\n\n'
            'Regards,\n'
            'HR Learning',
        timeLabel: 'Wed',
        fullDate: '19 Aug 2026 · 10:05',
        unread: false,
      ),
    ];

List<InfoMessage> sampleSent() => [
      InfoMessage(
        id: 's1',
        sender: 'Learning Administration',
        senderRole: 'Training Administrator',
        subject: 'Re: Complete Your Assigned Training',
        preview: 'Thank you. I will complete the training before Friday.',
        body: 'Thank you. I will complete the training before Friday.',
        timeLabel: '10:06',
        fullDate: '21 Aug 2026 · 10:06',
        unread: false,
      ),
      InfoMessage(
        id: 's2',
        sender: 'Compliance Team',
        senderRole: 'Compliance Office',
        subject: 'AML/CFT refresher clarification',
        preview: 'Please confirm whether the classroom session is mandatory.',
        body: 'Please confirm whether the classroom session is mandatory.',
        timeLabel: 'Yesterday',
        fullDate: '20 Aug 2026 · 16:20',
        unread: false,
      ),
      InfoMessage(
        id: 's3',
        sender: 'Admin Support',
        senderRole: 'Administration',
        subject: 'Request for course subscription',
        preview: 'Kindly approve access to the CPR Essentials course.',
        body: 'Kindly approve access to the CPR Essentials course.',
        timeLabel: '18 Aug',
        fullDate: '18 Aug 2026 · 09:00',
        unread: false,
      ),
      InfoMessage(
        id: 's4',
        sender: 'HR Learning',
        senderRole: 'Human Resources',
        subject: 'Question about certificate attainment',
        preview: 'When will my completed course certificate appear?',
        body: 'When will my completed course certificate appear?',
        timeLabel: '16 Aug',
        fullDate: '16 Aug 2026 · 11:45',
        unread: false,
      ),
    ];
