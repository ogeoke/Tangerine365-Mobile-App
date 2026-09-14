/// Plain UI models for the Information Management module (Announcements +
/// Messages). There are no backend endpoints yet, so [sampleAnnouncements],
/// [sampleInbox] and [sampleSent] provide realistic placeholder content that
/// the screens render. When the endpoints land, swap these lists for API data —
/// the widgets read only these model fields.
library;

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
}

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
  });

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
