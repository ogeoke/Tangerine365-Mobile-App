// Plain models for the Knowledge Repository (`POST api/knowledge*`).

int? _int(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');
String _str(Object? v) => v?.toString() ?? '';

/// "2026-08-28 12:01:19" → "Aug 28, 2026" ('' when missing/unparseable).
String formatKnowledgeDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final d = DateTime.tryParse(raw.trim().replaceFirst(' ', 'T'));
  if (d == null) return '';
  const m = [
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
  return '${m[d.month - 1]} ${d.day}, ${d.year}';
}

class KnowledgeCategory {
  final int id;
  final String name;
  final String slug;
  final int? parentId;
  final int depth;

  /// Items directly in this category (as reported by the API).
  final int count;

  const KnowledgeCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.parentId,
    required this.depth,
    required this.count,
  });

  bool get isTopLevel => parentId == null;

  factory KnowledgeCategory.fromJson(Map<String, dynamic> j) =>
      KnowledgeCategory(
        id: _int(j['id']) ?? 0,
        name: _str(j['name']),
        slug: _str(j['slug']),
        parentId: _int(j['parent_id']),
        depth: _int(j['depth']) ?? 0,
        count: _int(j['count']) ?? 0,
      );
}

/// Helpers over the flat category list returned by the API.
extension KnowledgeCategoryTree on List<KnowledgeCategory> {
  List<KnowledgeCategory> get topLevel => where((c) => c.isTopLevel).toList();

  List<KnowledgeCategory> childrenOf(int id) =>
      where((c) => c.parentId == id).toList();

  KnowledgeCategory? byId(int? id) {
    if (id == null) return null;
    for (final c in this) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Items in [id]. The API's `count` already includes subcategories.
  int totalCount(int id) => byId(id)?.count ?? 0;

  /// Root → ... → [id] chain, used for breadcrumbs.
  List<KnowledgeCategory> pathTo(int id) {
    final out = <KnowledgeCategory>[];
    var cur = byId(id);
    var guard = 0;
    while (cur != null && guard++ < 10) {
      out.insert(0, cur);
      cur = byId(cur.parentId);
    }
    return out;
  }
}

class KnowledgeTag {
  final int id;
  final String name;
  const KnowledgeTag({required this.id, required this.name});

  factory KnowledgeTag.fromJson(Map<String, dynamic> j) =>
      KnowledgeTag(id: _int(j['id']) ?? 0, name: _str(j['name']));
}

/// A knowledge item as listed (list/search/related).
class KnowledgeItem {
  final int id;
  final String title;
  final String slug;
  final String type;
  final String summary;
  final int? categoryId;
  final String categoryName;
  final bool featured;
  final String publishedAt;
  final String updatedAt;

  const KnowledgeItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.type,
    required this.summary,
    required this.categoryId,
    required this.categoryName,
    required this.featured,
    required this.publishedAt,
    required this.updatedAt,
  });

  factory KnowledgeItem.fromJson(Map<String, dynamic> j) => KnowledgeItem(
    id: _int(j['id']) ?? 0,
    title: _str(j['title']),
    slug: _str(j['slug']),
    type: _str(j['type']),
    summary: _str(j['summary']),
    categoryId: _int(j['category_id']),
    categoryName: _str(j['category_name']),
    featured: _int(j['is_featured']) == 1 || j['is_featured'] == true,
    publishedAt: _str(j['published_at']),
    updatedAt: _str(j['updated_at']),
  );
}

class KnowledgeFaq {
  final String question;

  /// HTML answer.
  final String answer;
  const KnowledgeFaq({required this.question, required this.answer});
}

/// One content block of an article: rich HTML or a FAQ list.
class KnowledgeBlock {
  final String title;
  final String contentType; // 'html' | 'faq' | other
  final String html;
  final String description;
  final List<KnowledgeFaq> faqs;

  const KnowledgeBlock({
    required this.title,
    required this.contentType,
    required this.html,
    required this.description,
    required this.faqs,
  });

  bool get isFaq => contentType == 'faq' || faqs.isNotEmpty;

  factory KnowledgeBlock.fromJson(Map<String, dynamic> j) {
    final items =
        (j['items'] is List ? j['items'] as List : const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
          ..sort(
            (a, b) => (_int(a['sort_order']) ?? 0).compareTo(
              _int(b['sort_order']) ?? 0,
            ),
          );
    return KnowledgeBlock(
      title: _str(j['title']),
      contentType: _str(j['content_type']).isNotEmpty
          ? _str(j['content_type'])
          : _str(j['type']),
      html: _str(j['html']),
      description: _str(j['description']),
      faqs: [
        for (final f in items)
          KnowledgeFaq(
            question: _str(f['question']),
            answer: _str(f['answer']),
          ),
      ],
    );
  }
}

class KnowledgeAttachment {
  final int id;
  final String filename;
  final String mimeType;
  final int size;
  const KnowledgeAttachment({
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.size,
  });

  String get sizeLabel {
    if (size <= 0) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(0)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory KnowledgeAttachment.fromJson(Map<String, dynamic> j) =>
      KnowledgeAttachment(
        id: _int(j['id']) ?? 0,
        filename: _str(j['filename']),
        mimeType: _str(j['mime_type']),
        size: _int(j['size']) ?? 0,
      );
}

/// Full article (`knowledge/getResource`).
class KnowledgeArticle {
  final KnowledgeItem item;
  final List<KnowledgeTag> tags;
  final List<KnowledgeBlock> blocks;
  final List<KnowledgeAttachment> attachments;
  final List<KnowledgeItem> related;

  const KnowledgeArticle({
    required this.item,
    required this.tags,
    required this.blocks,
    required this.attachments,
    required this.related,
  });

  static List<Map<String, dynamic>> _maps(Object? v) =>
      (v is List ? v : const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  factory KnowledgeArticle.fromJson(Map<String, dynamic> j) {
    final contents = _maps(j['contents'])
      ..sort(
        (a, b) =>
            (_int(a['sort_order']) ?? 0).compareTo(_int(b['sort_order']) ?? 0),
      );
    return KnowledgeArticle(
      item: KnowledgeItem.fromJson(j),
      tags: _maps(j['tags']).map(KnowledgeTag.fromJson).toList(),
      blocks: contents.map(KnowledgeBlock.fromJson).toList(),
      attachments: _maps(
        j['attachments'],
      ).map(KnowledgeAttachment.fromJson).toList(),
      related: _maps(j['related']).map(KnowledgeItem.fromJson).toList(),
    );
  }
}
