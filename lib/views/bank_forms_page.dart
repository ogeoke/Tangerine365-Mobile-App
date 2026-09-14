import 'package:flutter/material.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/models/banking.dart';

/// Forms categories (Figma 19D): a searchable list of form-category folders.
/// Tapping a category opens its downloadable files (19E). Forms (PDFs) come
/// from the CLIENT's forms endpoint — sample data until that endpoint exists.
class BankFormsPage extends StatefulWidget {
  const BankFormsPage({super.key});

  @override
  State<BankFormsPage> createState() => _BankFormsPageState();
}

class _BankFormsPageState extends State<BankFormsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _categories = sampleFormCategories();
  String _query = '';

  List<FormCategory> get _visible {
    if (_query.trim().isEmpty) return _categories;
    final q = _query.toLowerCase();
    return _categories
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            c.subtitle.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Forms',
              subtitle: 'Download bank-supplied documents',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 16, AppTokens.screenPadding, 6),
              child: Column(
                children: [
                  const _InfoBanner(
                      'Forms download to your device and cannot be previewed '
                      'in the app.'),
                  const SizedBox(height: 16),
                  _SearchField(
                    hint: 'Search form categories...',
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 12, AppTokens.screenPadding, 24),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) => _CategoryCard(
                  category: visible[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => FormsListPage(category: visible[i])),
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

class _CategoryCard extends StatelessWidget {
  final FormCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTokens.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder_rounded,
                    color: AppTokens.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.title,
                        style: AppTokens.manrope(
                            size: 17,
                            weight: 700,
                            color: AppTokens.textPrimary)),
                    const SizedBox(height: 4),
                    Text(category.subtitle,
                        style: AppTokens.manrope(
                            size: 14,
                            weight: 400,
                            color: AppTokens.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppTokens.textSecondary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Downloadable forms within a category (Figma 19E). Each row is a PDF with a
/// Download action. The actual download needs the file URL from the CLIENT's
/// forms endpoint; until that endpoint exists, Download reports it's pending.
class FormsListPage extends StatelessWidget {
  final FormCategory category;
  const FormsListPage({super.key, required this.category});

  void _download(BuildContext context, BankForm form) {
    // No forms endpoint yet — the file URL comes from the client's forms
    // endpoint. When wired, this opens/saves form.url. For now, acknowledge.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text('“${form.name}” will download once forms are '
              'published from the backend.')));
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: '${category.title} Forms',
              subtitle: 'Download files to your device',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 16, AppTokens.screenPadding, 6),
              child: const _InfoBanner(
                  'Files cannot be viewed in the app. Select Download to save '
                  'a copy.'),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 12, AppTokens.screenPadding, 24),
                itemCount: category.forms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) => _FormCard(
                  form: category.forms[i],
                  onDownload: () => _download(context, category.forms[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final BankForm form;
  final VoidCallback onDownload;
  const _FormCard({required this.form, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokens.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTokens.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_rounded,
                    color: AppTokens.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(form.name,
                        style: AppTokens.manrope(
                            size: 17,
                            weight: 700,
                            color: AppTokens.textPrimary)),
                    const SizedBox(height: 4),
                    Text(form.sizeLabel,
                        style: AppTokens.manrope(
                            size: 14,
                            weight: 400,
                            color: AppTokens.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: AppTokens.lightGreen,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onDownload,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_downward,
                          color: AppTokens.primary, size: 18),
                      const SizedBox(width: 8),
                      Text('Download',
                          style: AppTokens.manrope(
                              size: 15,
                              weight: 700,
                              color: AppTokens.primary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.lightGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text,
          style: AppTokens.manrope(
              size: 15, weight: 500, height: 21, color: AppTokens.primary)),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTokens.manrope(size: 15, color: AppTokens.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTokens.manrope(size: 15, color: AppTokens.placeholder),
        filled: true,
        fillColor: AppTokens.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
