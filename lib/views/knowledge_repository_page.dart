import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/common/downloads.dart';
import 'package:sevenup_mobile/common/safety.dart';
import 'package:sevenup_mobile/common/skeleton.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/constants/app_urls.dart';
import 'package:sevenup_mobile/constants/env.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/data/session_store.dart';
import 'package:sevenup_mobile/models/knowledge.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:url_launcher/url_launcher.dart';

// Knowledge Repository (Figma 18A–18F), wired to `POST api/knowledge*`.

const _navIndex = 2; // Repository tab

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

Future<List<KnowledgeCategory>?> _loadCategories(ApiRepository repo) async {
  final res = await repo.getKnowledgeCategories();
  final list = res.body?['categories'];
  if (list is! List) return null;
  return list
      .whereType<Map>()
      .map((e) => KnowledgeCategory.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

List<KnowledgeItem>? _items(Map<String, dynamic>? body) {
  final list = body?['items'];
  if (list is! List) return null;
  return list
      .whereType<Map>()
      .map((e) => KnowledgeItem.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

IconData _categoryIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('human') || n.contains('recruit') || n.contains('employee')) {
    return Icons.people_alt_rounded;
  }
  if (n.contains('technology') || n.contains('application')) {
    return Icons.desktop_windows_outlined;
  }
  if (n.contains('cyber') || n.contains('compliance') || n.contains('risk')) {
    return Icons.shield_rounded;
  }
  if (n.contains('infrastructure')) return Icons.dns_outlined;
  if (n.contains('support') || n.contains('customer')) {
    return Icons.headset_mic_outlined;
  }
  if (n.contains('product')) return Icons.inventory_2_outlined;
  if (n.contains('operation') || n.contains('process')) {
    return Icons.settings_outlined;
  }
  if (n.contains('finance') || n.contains('expense') || n.contains('procure')) {
    return Icons.attach_money_rounded;
  }
  if (n.contains('health') || n.contains('safety') || n.contains('emergency')) {
    return Icons.health_and_safety_outlined;
  }
  if (n.contains('question') || n.contains('faq')) {
    return Icons.help_outline_rounded;
  }
  if (n.contains('polic')) return Icons.policy_outlined;
  if (n.contains('learning')) return Icons.school_outlined;
  if (n.contains('form') || n.contains('template')) {
    return Icons.description_outlined;
  }
  return Icons.folder_outlined;
}

IconData _typeIcon(String type) => switch (type.toLowerCase()) {
  'product' => Icons.widgets_outlined,
  'policy' => Icons.policy_outlined,
  'sop' => Icons.checklist_rounded,
  'faq' => Icons.help_outline_rounded,
  _ => Icons.article_outlined,
};

String _typeLabel(String type) =>
    type.toLowerCase() == 'sop' ? 'SOP' : type.toUpperCase();

String _count(int n) => '$n ${n == 1 ? 'item' : 'items'}';

void _push(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

/// Scaffold shared by every Knowledge Repository screen.
class _KrScaffold extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget body;
  const _KrScaffold({
    required this.title,
    required this.subtitle,
    required this.body,
  });

  @override
  State<_KrScaffold> createState() => _KrScaffoldState();
}

class _KrScaffoldState extends State<_KrScaffold> {
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: _navIndex),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: widget.title,
              subtitle: widget.subtitle,
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _key.currentState?.openDrawer(),
            ),
            Expanded(child: widget.body),
          ],
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppTokens.manrope(
      size: 12,
      weight: 700,
      color: AppTokens.primary,
      letterSpacing: 0.6,
    ),
  );
}

class _Breadcrumb extends StatelessWidget {
  final List<String> parts;
  const _Breadcrumb(this.parts);
  @override
  Widget build(BuildContext context) => Text(
    parts.join('  ›  '),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: AppTokens.manrope(size: 13, weight: 600, color: AppTokens.primary),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _Chip(this.label, {this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTokens.lightGreen.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6E6CF)),
      ),
      child: Text(
        label,
        style: AppTokens.manrope(
          size: 13,
          weight: 600,
          color: AppTokens.primary,
        ),
      ),
    ),
  );
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  const _IconTile(this.icon, {this.size = 44});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppTokens.lightGreen,
      borderRadius: BorderRadius.circular(size * 0.28),
    ),
    child: Icon(icon, color: AppTokens.primary, size: size * 0.52),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const _Card({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });
  @override
  Widget build(BuildContext context) => Material(
    color: AppTokens.surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTokens.border),
        ),
        child: child,
      ),
    ),
  );
}

class _SearchBar extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onSubmit;
  final bool showButton;
  const _SearchBar({
    this.initial = '',
    required this.onSubmit,
    this.showButton = true,
  });
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _go() {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSubmit(_c.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 5, 5, 5),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokens.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppTokens.primary, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _c,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _go(),
              style: AppTokens.manrope(
                size: 15,
                weight: 500,
                color: AppTokens.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintText: 'Search knowledge...',
                hintStyle: AppTokens.manrope(
                  size: 15,
                  weight: 400,
                  color: AppTokens.placeholder,
                ),
              ),
            ),
          ),
          if (widget.showButton)
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: _go,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Search',
                  style: AppTokens.manrope(
                    size: 14,
                    weight: 700,
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

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onRetry;
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    this.onRetry,
  });
  @override
  Widget build(BuildContext context) => _Card(
    child: Row(
      children: [
        _IconTile(icon, size: 40),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTokens.manrope(
                  size: 15,
                  weight: 700,
                  color: AppTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: AppTokens.manrope(
                  size: 13,
                  weight: 400,
                  color: AppTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: AppTokens.manrope(
                size: 14,
                weight: 700,
                color: AppTokens.primary,
              ),
            ),
          ),
      ],
    ),
  );
}

/// Knowledge item card used in the Featured / Knowledge lists.
class _ItemCard extends StatelessWidget {
  final KnowledgeItem item;
  const _ItemCard(this.item);

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (item.featured) '★ FEATURED',
      if (item.type.isNotEmpty) _typeLabel(item.type),
      if (item.categoryName.isNotEmpty) item.categoryName.toUpperCase(),
    ].join(' • ');
    final updated = formatKnowledgeDate(
      item.updatedAt.isNotEmpty ? item.updatedAt : item.publishedAt,
    );
    return _Card(
      onTap: () => _push(context, KnowledgeArticlePage(item: item)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconTile(_typeIcon(item.type)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (meta.isNotEmpty)
                      Text(
                        meta,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTokens.manrope(
                          size: 11,
                          weight: 700,
                          color: AppTokens.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: AppTokens.manrope(
                        size: 17,
                        weight: 700,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    if (item.summary.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTokens.manrope(
                          size: 13,
                          weight: 400,
                          height: 19,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (updated.isNotEmpty)
                Text(
                  'Updated $updated',
                  style: AppTokens.manrope(
                    size: 12,
                    weight: 400,
                    color: AppTokens.textSecondary,
                  ),
                ),
              const Spacer(),
              Text(
                'View',
                style: AppTokens.manrope(
                  size: 14,
                  weight: 700,
                  color: AppTokens.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppTokens.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final KnowledgeCategory category;
  final int count;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => _Card(
    onTap: onTap,
    padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
    // Icon above the name so long single words (e.g. "Cybersecurity") get
    // the full card width instead of breaking mid-word.
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _IconTile(_categoryIcon(category.name), size: 38),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: AppTokens.textSecondary,
              size: 20,
            ),
          ],
        ),
        const Spacer(),
        Text(
          category.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTokens.manrope(
            size: 14,
            weight: 700,
            color: AppTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _count(count),
          style: AppTokens.manrope(
            size: 12,
            weight: 600,
            color: AppTokens.primary,
          ),
        ),
      ],
    ),
  );
}

Widget _categoryGrid(
  BuildContext context,
  List<KnowledgeCategory> shown,
  List<KnowledgeCategory> all,
) {
  return GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1.05,
    children: [
      for (final c in shown)
        _CategoryCard(
          category: c,
          count: all.totalCount(c.id),
          onTap: () => _push(
            context,
            KnowledgeCategoryPage(categoryId: c.id, categories: all),
          ),
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// 18A • Home
// ---------------------------------------------------------------------------

class KnowledgeRepositoryPage extends StatefulWidget {
  static const routeName = '/knowledge-repository';
  const KnowledgeRepositoryPage({super.key});

  @override
  State<KnowledgeRepositoryPage> createState() =>
      _KnowledgeRepositoryPageState();
}

class _KnowledgeRepositoryPageState extends State<KnowledgeRepositoryPage> {
  final _repo = ApiRepository();
  List<KnowledgeCategory>? _categories;
  List<KnowledgeTag> _tags = [];
  List<KnowledgeItem> _featured = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _loadCategories(_repo),
      _repo.getKnowledgeTags(limit: 6),
      _repo.getKnowledgeItems(featured: true, limit: 10),
    ]);
    if (!mounted) return;
    final cats = results[0] as List<KnowledgeCategory>?;
    final tagsBody = (results[1] as dynamic).body as Map<String, dynamic>?;
    final featBody = (results[2] as dynamic).body as Map<String, dynamic>?;
    setState(() {
      _categories = cats ?? _categories;
      final t = tagsBody?['tags'];
      if (t is List) {
        _tags = t
            .whereType<Map>()
            .map((e) => KnowledgeTag.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      _featured = _items(featBody) ?? _featured;
      _error = cats == null && _featured.isEmpty;
      _loading = false;
    });
  }

  void _search(String q) {
    if (q.isEmpty) return;
    _push(context, KnowledgeResultsPage(query: q, categories: _categories));
  }

  @override
  Widget build(BuildContext context) {
    final cats = _categories ?? const <KnowledgeCategory>[];
    final top = cats.topLevel;
    return _KrScaffold(
      title: 'Knowledge Repository',
      subtitle: 'Find answers, guides and organizational knowledge',
      body: RefreshIndicator(
        color: AppTokens.primary,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppTokens.screenPadding,
            20,
            AppTokens.screenPadding,
            28,
          ),
          children: [
            const _Eyebrow('Organizational knowledge'),
            const SizedBox(height: 6),
            Text(
              'How can we help?',
              style: AppTokens.manrope(
                size: 28,
                weight: 700,
                color: AppTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search products, policies, procedures, FAQs and practical '
              'guides.',
              style: AppTokens.manrope(
                size: 14,
                weight: 400,
                height: 20,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _SearchBar(onSubmit: _search),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Popular:',
                    style: AppTokens.manrope(
                      size: 13,
                      weight: 500,
                      color: AppTokens.textSecondary,
                    ),
                  ),
                  for (final t in _tags.take(5))
                    _Chip(
                      t.name,
                      onTap: () => _push(
                        context,
                        KnowledgeResultsPage(tag: t, categories: _categories),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 26),
            const _Eyebrow('Browse'),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Browse by Category',
                    style: AppTokens.manrope(
                      size: 20,
                      weight: 700,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                ),
                if (top.isNotEmpty)
                  GestureDetector(
                    onTap: () => _push(
                      context,
                      KnowledgeCategoriesPage(categories: cats),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'View all',
                          style: AppTokens.manrope(
                            size: 13,
                            weight: 700,
                            color: AppTokens.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppTokens.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (_loading && _categories == null)
              const SizedBox(height: 320, child: SkeletonCards(count: 3))
            else if (_error)
              _Message(
                icon: Icons.cloud_off_rounded,
                title: 'Couldn’t load the repository',
                body: 'Check your connection and try again.',
                onRetry: () {
                  setState(() => _loading = true);
                  _load();
                },
              )
            else if (top.isEmpty)
              const _Message(
                icon: Icons.folder_off_outlined,
                title: 'No categories yet',
                body: 'Knowledge categories will appear here.',
              )
            else
              _categoryGrid(context, top.take(6).toList(), cats),
            if (_featured.isNotEmpty) ...[
              const SizedBox(height: 28),
              const _Eyebrow('Featured'),
              const SizedBox(height: 4),
              Text(
                'Featured Knowledge',
                style: AppTokens.manrope(
                  size: 20,
                  weight: 700,
                  color: AppTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              for (final i in _featured) ...[
                _ItemCard(i),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Opens the first category whose name contains [match] (e.g. the side menu's
/// "Learning Series" → Learning & Development); falls back to the categories
/// list when no category matches.
class KnowledgeCategoryLinkPage extends StatefulWidget {
  final String match;
  final String title;
  const KnowledgeCategoryLinkPage({
    super.key,
    required this.match,
    required this.title,
  });

  @override
  State<KnowledgeCategoryLinkPage> createState() =>
      _KnowledgeCategoryLinkPageState();
}

class _KnowledgeCategoryLinkPageState extends State<KnowledgeCategoryLinkPage> {
  List<KnowledgeCategory>? _cats;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadCategories(ApiRepository()).then((c) {
      if (mounted) {
        setState(() {
          _cats = c;
          _failed = c == null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cats = _cats;
    if (cats != null) {
      final m = widget.match.toLowerCase();
      final hit = cats.where((c) => c.name.toLowerCase().contains(m));
      return hit.isNotEmpty
          ? KnowledgeCategoryPage(categoryId: hit.first.id, categories: cats)
          : KnowledgeCategoriesPage(categories: cats);
    }
    return _KrScaffold(
      title: widget.title,
      subtitle: 'Knowledge Repository',
      body: _failed
          ? ListView(
              padding: const EdgeInsets.all(AppTokens.screenPadding),
              children: const [
                _Message(
                  icon: Icons.cloud_off_rounded,
                  title: 'Couldn’t load the repository',
                  body: 'Check your connection and try again.',
                ),
              ],
            )
          : const SkeletonCards(count: 4),
    );
  }
}

// ---------------------------------------------------------------------------
// 18B • Categories
// ---------------------------------------------------------------------------

class KnowledgeCategoriesPage extends StatefulWidget {
  final List<KnowledgeCategory> categories;
  const KnowledgeCategoriesPage({super.key, required this.categories});

  @override
  State<KnowledgeCategoriesPage> createState() =>
      _KnowledgeCategoriesPageState();
}

class _KnowledgeCategoriesPageState extends State<KnowledgeCategoriesPage> {
  final _open = <int>{};

  @override
  Widget build(BuildContext context) {
    final all = widget.categories;
    return _KrScaffold(
      title: 'Categories',
      subtitle: 'Browse categories',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.screenPadding,
          18,
          AppTokens.screenPadding,
          28,
        ),
        children: [
          const _Breadcrumb(['Repository', 'Categories']),
          const SizedBox(height: 14),
          Text(
            'Categories',
            style: AppTokens.manrope(
              size: 26,
              weight: 700,
              color: AppTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Expand a category to view its available items.',
            style: AppTokens.manrope(
              size: 14,
              weight: 400,
              color: AppTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          for (final c in all.topLevel) ...[
            _expandable(context, c, all),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _expandable(
    BuildContext context,
    KnowledgeCategory c,
    List<KnowledgeCategory> all,
  ) {
    final kids = all.childrenOf(c.id);
    final open = _open.contains(c.id);
    void openCategory(KnowledgeCategory x) => _push(
      context,
      KnowledgeCategoryPage(categoryId: x.id, categories: all),
    );
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => kids.isEmpty
                ? openCategory(c)
                : setState(() => open ? _open.remove(c.id) : _open.add(c.id)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              child: Row(
                children: [
                  Icon(
                    kids.isEmpty
                        ? Icons.chevron_right
                        : (open
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                    color: AppTokens.primary,
                  ),
                  const SizedBox(width: 8),
                  _IconTile(_categoryIcon(c.name), size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      c.name,
                      style: AppTokens.manrope(
                        size: 15,
                        weight: 700,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    _count(all.totalCount(c.id)),
                    style: AppTokens.manrope(
                      size: 12,
                      weight: 600,
                      color: AppTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (open) ...[
            _subRow(
              'All ${c.name}',
              all.totalCount(c.id),
              () => openCategory(c),
              bold: true,
            ),
            for (final k in kids)
              _subRow(k.name, all.totalCount(k.id), () => openCategory(k)),
          ],
        ],
      ),
    );
  }

  Widget _subRow(
    String label,
    int count,
    VoidCallback onTap, {
    bool bold = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTokens.border)),
        ),
        padding: const EdgeInsets.fromLTRB(56, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppTokens.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTokens.manrope(
                  size: 14,
                  weight: bold ? 700 : 500,
                  color: AppTokens.textPrimary,
                ),
              ),
            ),
            Text(
              '$count',
              style: AppTokens.manrope(
                size: 12,
                weight: 600,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppTokens.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Types filter (shared by category + results pages)
// ---------------------------------------------------------------------------

class _TypeFilter extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _TypeFilter({required this.value, required this.onChanged});
  @override
  State<_TypeFilter> createState() => _TypeFilterState();
}

class _TypeFilterState extends State<_TypeFilter> {
  static List<String>? _cache;
  List<String> _types = _cache ?? const [];

  @override
  void initState() {
    super.initState();
    if (_cache == null) _fetch();
  }

  Future<void> _fetch() async {
    final res = await ApiRepository().getKnowledgeTypes();
    final t = res.body?['types'];
    if (t is List && mounted) {
      setState(() => _types = _cache = t.map((e) => '$e').toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: widget.value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppTokens.textSecondary,
          ),
          style: AppTokens.manrope(
            size: 14,
            weight: 600,
            color: AppTokens.textPrimary,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All types'),
            ),
            for (final t in _types)
              DropdownMenuItem<String?>(
                value: t,
                child: Text(
                  t == 'sop'
                      ? 'SOPs'
                      : '${t[0].toUpperCase()}${t.substring(1)}',
                ),
              ),
          ],
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 18C / 18D • Category
// ---------------------------------------------------------------------------

class KnowledgeCategoryPage extends StatefulWidget {
  final int categoryId;
  final List<KnowledgeCategory> categories;
  const KnowledgeCategoryPage({
    super.key,
    required this.categoryId,
    required this.categories,
  });

  @override
  State<KnowledgeCategoryPage> createState() => _KnowledgeCategoryPageState();
}

class _KnowledgeCategoryPageState extends State<KnowledgeCategoryPage> {
  final _repo = ApiRepository();
  List<KnowledgeItem> _items_ = [];
  String _query = '';
  String? _type;
  bool _loading = true;
  bool _error = false;

  List<KnowledgeCategory> get _all => widget.categories;
  KnowledgeCategory? get _cat => _all.byId(widget.categoryId);

  /// This category plus every descendant (items may live in subcategories).
  List<int> get _ids {
    final out = <int>[];
    void walk(int id) {
      out.add(id);
      for (final c in _all.childrenOf(id)) {
        walk(c.id);
      }
    }

    walk(widget.categoryId);
    return out;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    final responses = await Future.wait([
      for (final id in _ids)
        _repo.getKnowledgeItems(
          categoryId: id,
          search: _query,
          type: _type,
          limit: 100,
        ),
    ]);
    if (!mounted) return;
    final seen = <int>{};
    final merged = <KnowledgeItem>[];
    var anyOk = false;
    for (final r in responses) {
      final list = _items(r.body);
      if (list == null) continue;
      anyOk = true;
      for (final i in list) {
        if (seen.add(i.id)) merged.add(i);
      }
    }
    setState(() {
      _items_ = merged;
      _error = !anyOk;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cat = _cat;
    final name = cat?.name ?? 'Category';
    final path = cat == null ? <KnowledgeCategory>[] : _all.pathTo(cat.id);
    final kids = _all.childrenOf(widget.categoryId);
    return _KrScaffold(
      title: name,
      subtitle: kids.isEmpty
          ? 'Guides and knowledge in this category'
          : 'Browse knowledge and subcategories',
      body: RefreshIndicator(
        color: AppTokens.primary,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppTokens.screenPadding,
            18,
            AppTokens.screenPadding,
            28,
          ),
          children: [
            _Breadcrumb(['Repository', ...path.map((c) => c.name)]),
            const SizedBox(height: 14),
            Text(
              name,
              style: AppTokens.manrope(
                size: 26,
                weight: 700,
                color: AppTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              kids.isEmpty
                  ? 'Guides, documentation and FAQs in $name.'
                  : 'Explore $name knowledge by subcategory, or search below.',
              style: AppTokens.manrope(
                size: 14,
                weight: 400,
                height: 20,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            const _Eyebrow('Explore'),
            const SizedBox(height: 4),
            Text(
              'Subcategories',
              style: AppTokens.manrope(
                size: 20,
                weight: 700,
                color: AppTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (kids.isEmpty)
              const _Message(
                icon: Icons.folder_outlined,
                title: 'No subcategories',
                body: 'This category does not contain subcategories.',
              )
            else
              _categoryGrid(context, kids, _all),
            const SizedBox(height: 24),
            Text(
              'Search',
              style: AppTokens.manrope(
                size: 14,
                weight: 600,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SearchBar(
                    showButton: false,
                    initial: _query,
                    onSubmit: (q) {
                      _query = q;
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                _TypeFilter(
                  value: _type,
                  onChanged: (t) {
                    _type = t;
                    _load();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Knowledge',
              style: AppTokens.manrope(
                size: 20,
                weight: 700,
                color: AppTokens.textPrimary,
              ),
            ),
            if (!_loading && !_error) ...[
              const SizedBox(height: 2),
              Text(
                '${_items_.length} ${_items_.length == 1 ? 'item' : 'items'} found',
                style: AppTokens.manrope(
                  size: 13,
                  weight: 400,
                  color: AppTokens.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (_loading)
              const SizedBox(height: 240, child: SkeletonCards(count: 2))
            else if (_error)
              _Message(
                icon: Icons.cloud_off_rounded,
                title: 'Couldn’t load knowledge',
                body: 'Check your connection and try again.',
                onRetry: _load,
              )
            else if (_items_.isEmpty)
              _Message(
                icon: Icons.search_off_rounded,
                title: _query.isNotEmpty || _type != null
                    ? 'No matching knowledge'
                    : 'No knowledge yet',
                body: _query.isNotEmpty || _type != null
                    ? 'Try a different search or type.'
                    : 'Items added to $name will appear here.',
              )
            else
              for (final i in _items_) ...[
                _ItemCard(i),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search / tag / type results
// ---------------------------------------------------------------------------

class KnowledgeResultsPage extends StatefulWidget {
  final String? query;
  final KnowledgeTag? tag;

  /// Types to include (merged), e.g. ['policy', 'sop'].
  final List<String>? types;
  final String? title;
  final List<KnowledgeCategory>? categories;
  const KnowledgeResultsPage({
    super.key,
    this.query,
    this.tag,
    this.types,
    this.title,
    this.categories,
  });

  @override
  State<KnowledgeResultsPage> createState() => _KnowledgeResultsPageState();
}

class _KnowledgeResultsPageState extends State<KnowledgeResultsPage> {
  final _repo = ApiRepository();
  late String _query = widget.query ?? '';
  String? _type;
  List<KnowledgeItem> _results = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    final tagId = widget.tag?.id;
    final List<String?> types =
        _type != null ? [_type] : (widget.types ?? const [null]);
    final responses = await Future.wait([
      for (final t in types)
        _query.isNotEmpty
            ? _repo.searchKnowledge(_query, type: t, tagId: tagId)
            : _repo.getKnowledgeItems(type: t, tagId: tagId, limit: 100),
    ]);
    if (!mounted) return;
    final seen = <int>{};
    final merged = <KnowledgeItem>[];
    var anyOk = false;
    for (final r in responses) {
      final list = _items(r.body);
      if (list == null) continue;
      anyOk = true;
      for (final i in list) {
        if (seen.add(i.id)) merged.add(i);
      }
    }
    setState(() {
      _results = merged;
      _error = !anyOk;
      _loading = false;
    });
  }

  String get _heading {
    if (_query.isNotEmpty) return 'Results for “$_query”';
    if (widget.tag != null) return 'Tagged “${widget.tag!.name}”';
    return widget.title ?? 'Knowledge';
  }

  @override
  Widget build(BuildContext context) {
    return _KrScaffold(
      title: widget.title ?? 'Search',
      subtitle: 'Knowledge Repository',
      body: RefreshIndicator(
        color: AppTokens.primary,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppTokens.screenPadding,
            18,
            AppTokens.screenPadding,
            28,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: _SearchBar(
                    showButton: false,
                    initial: _query,
                    onSubmit: (q) {
                      _query = q;
                      _load();
                    },
                  ),
                ),
                if (widget.types == null) ...[
                  const SizedBox(width: 10),
                  _TypeFilter(
                    value: _type,
                    onChanged: (t) {
                      _type = t;
                      _load();
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 22),
            Text(
              _heading,
              style: AppTokens.manrope(
                size: 20,
                weight: 700,
                color: AppTokens.textPrimary,
              ),
            ),
            if (!_loading && !_error)
              Text(
                '${_results.length} ${_results.length == 1 ? 'item' : 'items'} found',
                style: AppTokens.manrope(
                  size: 13,
                  weight: 400,
                  color: AppTokens.textSecondary,
                ),
              ),
            const SizedBox(height: 12),
            if (_loading)
              const SizedBox(height: 240, child: SkeletonCards(count: 2))
            else if (_error)
              _Message(
                icon: Icons.cloud_off_rounded,
                title: 'Couldn’t load knowledge',
                body: 'Check your connection and try again.',
                onRetry: _load,
              )
            else if (_results.isEmpty)
              _Message(
                icon: Icons.search_off_rounded,
                title: 'No record found',
                body: _query.isEmpty
                    ? 'There is nothing to show here yet.'
                    : 'Try a different search term.',
              )
            else
              for (final i in _results) ...[
                _ItemCard(i),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 18E • Article
// ---------------------------------------------------------------------------

Map<String, Style> _htmlStyle() => {
  'body': Style(
    margin: Margins.zero,
    padding: HtmlPaddings.zero,
    fontFamily: AppTokens.fontFamily,
    fontSize: FontSize(15),
    lineHeight: const LineHeight(1.5),
    color: AppTokens.textSecondary,
  ),
  'h1': Style(
    fontSize: FontSize(22),
    fontWeight: FontWeight.w700,
    color: AppTokens.textPrimary,
    margin: Margins.only(top: 18, bottom: 6),
  ),
  'h2': Style(
    fontSize: FontSize(19),
    fontWeight: FontWeight.w700,
    color: AppTokens.textPrimary,
    margin: Margins.only(top: 16, bottom: 6),
  ),
  'h3': Style(
    fontSize: FontSize(17),
    fontWeight: FontWeight.w700,
    color: AppTokens.textPrimary,
    margin: Margins.only(top: 14, bottom: 4),
  ),
  'p': Style(margin: Margins.only(top: 4, bottom: 8)),
  'li': Style(margin: Margins.only(bottom: 4)),
  'strong': Style(fontWeight: FontWeight.w700, color: AppTokens.textPrimary),
  'a': Style(color: AppTokens.primary),
};

Widget _html(String data) => Html(
  data: data,
  style: _htmlStyle(),
  onLinkTap: (url, _, __) {
    final uri = Uri.tryParse(url ?? '');
    if (uri != null && uri.hasScheme) {
      openExternalUrl(uri.toString());
    }
  },
);

class KnowledgeArticlePage extends StatefulWidget {
  final KnowledgeItem item;
  const KnowledgeArticlePage({super.key, required this.item});

  @override
  State<KnowledgeArticlePage> createState() => _KnowledgeArticlePageState();
}

class _KnowledgeArticlePageState extends State<KnowledgeArticlePage> {
  final _repo = ApiRepository();
  KnowledgeArticle? _article;
  List<KnowledgeAttachment> _attachments = [];
  List<KnowledgeItem> _related = [];
  bool _loading = true;
  bool _error = false;
  int? _downloading;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = '${widget.item.id}';
    final results = await Future.wait([
      _repo.getKnowledgeResource(id),
      _repo.getKnowledgeAttachments(id),
      _repo.getKnowledgeRelated(id),
    ]);
    if (!mounted) return;
    final body = results[0].body;
    final article = (body != null && body['id'] != null)
        ? KnowledgeArticle.fromJson(body)
        : null;
    final att = results[1].body?['attachments'];
    final rel = results[2].body?['related'];
    setState(() {
      _article = article ?? _article;
      _attachments = att is List
          ? att
                .whereType<Map>()
                .map(
                  (e) => KnowledgeAttachment.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : (article?.attachments ?? _attachments);
      _related =
          (rel is List
                  ? rel
                        .whereType<Map>()
                        .map(
                          (e) => KnowledgeItem.fromJson(
                            Map<String, dynamic>.from(e),
                          ),
                        )
                        .toList()
                  : (article?.related ?? _related))
              .where((r) => r.id != widget.item.id)
              .toList();
      _error = _article == null;
      _loading = false;
    });
  }

  void _snack(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? AppTokens.primary : null,
          content: Text(msg),
        ),
      );
  }

  /// Streams `knowledge/download/{id}` (authenticated) into Downloads.
  Future<void> _download(KnowledgeAttachment a) async {
    if (_downloading != null) return;
    setState(() => _downloading = a.id);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final env = GetIt.I<Env>();
      if (!env.baseUrl.startsWith('https://')) {
        throw StateError('Insecure API base URL: HTTPS is required.');
      }
      final base = env.baseUrl.endsWith('/') ? env.baseUrl : '${env.baseUrl}/';
      final req = await client.postUrl(
        Uri.parse('$base${AppUrls.knowledgeDownload}/${a.id}'),
      );
      req.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/x-www-form-urlencoded',
      );
      req.headers.set('X-Requested-From', 'MobileApp');
      final token = GetIt.I<AuthBloc>().state.token ?? '';
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final cookie = SessionStore.instance.cookie;
      if (cookie != null) req.headers.set(HttpHeaders.cookieHeader, cookie);
      req.write(
        'auth=${Uri.encodeQueryComponent(token)}'
        '&attachmentId=${a.id}',
      );
      final res = await req.close();
      final bytes = await consolidateHttpClientResponseBytes(res);
      final ctype = res.headers.contentType?.mimeType ?? '';
      if (res.statusCode != 200 || ctype == 'application/json') {
        throw HttpException('HTTP ${res.statusCode}');
      }
      final mime = a.mimeType.isNotEmpty
          ? a.mimeType
          : (ctype.isNotEmpty ? ctype : 'application/octet-stream');
      final saved = await Downloads.save(
        filename: a.filename.isNotEmpty ? a.filename : 'attachment-${a.id}',
        mimeType: mime,
        bytes: bytes,
      );
      if (mounted) {
        Downloads.showSaved(context,
            name: saved.name, uri: saved.uri, mimeType: mime);
      }
        _snack('Saved to Downloads: ${saved ?? a.filename}', ok: true);
    } catch (_) {
      if (mounted) _snack('Could not download the attachment.');
    } finally {
      client.close(force: true);
      if (mounted) setState(() => _downloading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _article;
    final item = a?.item ?? widget.item;
    return _KrScaffold(
      title: item.title,
      subtitle: 'Knowledge article',
      body: _loading && a == null
          ? const SkeletonCards(count: 4)
          : _error
          ? ListView(
              padding: const EdgeInsets.all(AppTokens.screenPadding),
              children: [
                _Message(
                  icon: Icons.cloud_off_rounded,
                  title: 'Couldn’t open this article',
                  body:
                      'It may have been removed, or check your '
                      'connection.',
                  onRetry: () {
                    setState(() => _loading = true);
                    _load();
                  },
                ),
              ],
            )
          : RefreshIndicator(
              color: AppTokens.primary,
              onRefresh: _load,
              child: _content(context, a!),
            ),
    );
  }

  Widget _content(BuildContext context, KnowledgeArticle a) {
    final item = a.item;
    final published = formatKnowledgeDate(item.publishedAt);
    final updated = formatKnowledgeDate(item.updatedAt);
    final htmlBlocks = a.blocks.where((b) => !b.isFaq).toList();
    final faqBlocks = a.blocks.where((b) => b.isFaq).toList();
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppTokens.screenPadding,
        18,
        AppTokens.screenPadding,
        28,
      ),
      children: [
        _Breadcrumb([
          if (item.categoryName.isNotEmpty) item.categoryName,
          item.title,
        ]),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconTile(_typeIcon(item.type), size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTokens.manrope(
                      size: 24,
                      weight: 700,
                      height: 30,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  if (item.type.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.lightGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _typeLabel(item.type),
                        style: AppTokens.manrope(
                          size: 11,
                          weight: 700,
                          color: AppTokens.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (published.isNotEmpty || updated.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            [
              if (published.isNotEmpty) 'Published $published',
              if (updated.isNotEmpty) 'Updated $updated',
            ].join('  •  '),
            style: AppTokens.manrope(
              size: 13,
              weight: 400,
              color: AppTokens.textSecondary,
            ),
          ),
        ],
        if (a.tags.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in a.tags)
                _Chip(
                  t.name,
                  onTap: () => _push(context, KnowledgeResultsPage(tag: t)),
                ),
            ],
          ),
        ],
        if (item.summary.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            item.summary,
            style: AppTokens.manrope(
              size: 15,
              weight: 400,
              height: 22,
              color: AppTokens.textSecondary,
            ),
          ),
        ],
        for (var i = 0; i < htmlBlocks.length; i++) ...[
          const SizedBox(height: 22),
          if (htmlBlocks[i].title.isNotEmpty)
            Text(
              '${i + 1}. ${htmlBlocks[i].title}',
              style: AppTokens.manrope(
                size: 19,
                weight: 700,
                color: AppTokens.textPrimary,
              ),
            ),
          if (htmlBlocks[i].html.isNotEmpty) _html(htmlBlocks[i].html),
        ],
        for (final f in faqBlocks) ...[
          const SizedBox(height: 18),
          _Card(
            onTap: () => _push(context, KnowledgeFaqPage(article: a, block: f)),
            child: Row(
              children: [
                const _IconTile(Icons.help_outline_rounded, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.title.isNotEmpty ? f.title : '${item.title} FAQs',
                        style: AppTokens.manrope(
                          size: 15,
                          weight: 700,
                          color: AppTokens.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${f.faqs.length} ${f.faqs.length == 1 ? 'question' : 'questions'}',
                        style: AppTokens.manrope(
                          size: 12,
                          weight: 500,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTokens.primary),
              ],
            ),
          ),
        ],
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 26),
          Text(
            'Attachments',
            style: AppTokens.manrope(
              size: 19,
              weight: 700,
              color: AppTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final att in _attachments) ...[
            _Card(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Row(
                children: [
                  const _IconTile(Icons.description_outlined, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          att.filename,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTokens.manrope(
                            size: 14,
                            weight: 600,
                            color: AppTokens.textPrimary,
                          ),
                        ),
                        if (att.sizeLabel.isNotEmpty)
                          Text(
                            att.sizeLabel,
                            style: AppTokens.manrope(
                              size: 12,
                              weight: 400,
                              color: AppTokens.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Download',
                    onPressed: _downloading == null
                        ? () => _download(att)
                        : null,
                    icon: _downloading == att.id
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTokens.primary,
                            ),
                          )
                        : const Icon(
                            Icons.download_rounded,
                            color: AppTokens.primary,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
        if (_related.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'Related knowledge',
            style: AppTokens.manrope(
              size: 19,
              weight: 700,
              color: AppTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final r in _related) ...[
            _ItemCard(r),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 18F • FAQs
// ---------------------------------------------------------------------------

class KnowledgeFaqPage extends StatefulWidget {
  final KnowledgeArticle article;
  final KnowledgeBlock block;
  const KnowledgeFaqPage({
    super.key,
    required this.article,
    required this.block,
  });

  @override
  State<KnowledgeFaqPage> createState() => _KnowledgeFaqPageState();
}

class _KnowledgeFaqPageState extends State<KnowledgeFaqPage> {
  final _open = <int>{0};

  @override
  Widget build(BuildContext context) {
    final item = widget.article.item;
    final faqs = widget.block.faqs;
    return _KrScaffold(
      title: '${item.title} FAQs',
      subtitle: '${item.title} knowledge article',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.screenPadding,
          18,
          AppTokens.screenPadding,
          28,
        ),
        children: [
          _Breadcrumb([
            if (item.categoryName.isNotEmpty) item.categoryName,
            item.title,
            'FAQs',
          ]),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconTile(_typeIcon(item.type), size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTokens.manrope(
                    size: 24,
                    weight: 700,
                    color: AppTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Frequently Asked Questions',
            style: AppTokens.manrope(
              size: 19,
              weight: 700,
              color: AppTokens.textPrimary,
            ),
          ),
          if (widget.block.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              widget.block.description,
              style: AppTokens.manrope(
                size: 14,
                weight: 400,
                color: AppTokens.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (faqs.isEmpty)
            const _Message(
              icon: Icons.help_outline_rounded,
              title: 'No questions yet',
              body: 'FAQs added to this article will appear here.',
            ),
          for (var i = 0; i < faqs.length; i++) ...[
            _faqCard(i, faqs[i]),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _faqCard(int i, KnowledgeFaq f) {
    final open = _open.contains(i);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: open ? AppTokens.lightGreen.withOpacity(0.5) : AppTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: open ? const Color(0xFFD6E6CF) : AppTokens.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => open ? _open.remove(i) : _open.add(i)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      f.question,
                      style: AppTokens.manrope(
                        size: 15,
                        weight: 700,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppTokens.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _html(f.answer),
            ),
        ],
      ),
    );
  }
}
