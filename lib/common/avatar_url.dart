import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/constants/env.dart';

/// Resolve a user photo from whatever the API returns.
///
/// The LMS stores user photos under `files/appCore/photo/`, but the API's
/// `avatar` comes back as a site-root URL (e.g.
/// `https://host/195453a_74_1788355786.png`), which 404s. So a URL (or path)
/// whose filename sits at the root is re-pointed at the photo directory;
/// anything already inside a folder is used as-is.
String? resolveAvatarUrl(String? avatar) {
  final a = avatar?.trim();
  if (a == null || a.isEmpty) return null;

  final base = GetIt.I<Env>().baseUrl;
  final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  const photoDir = '/files/appCore/photo/';

  if (a.startsWith('http')) {
    final uri = Uri.tryParse(a);
    if (uri == null) return a;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    // Root-level file (single segment) → the LMS photo directory.
    if (segments.length == 1) return '$b$photoDir${segments.first}';
    return a;
  }

  final path = a.startsWith('/') ? a : '/$a';
  // Bare filename (no directory) → the LMS photo directory.
  if (path.split('/').where((s) => s.isNotEmpty).length == 1) {
    return '$b$photoDir${path.substring(1)}';
  }
  return '$b$path';
}
