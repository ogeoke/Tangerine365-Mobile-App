import 'package:url_launcher/url_launcher.dart';

/// Strip any directory parts and unsafe characters from a server-supplied
/// file name before it reaches the native download bridge.
String safeFileName(String name, {String fallback = 'download'}) {
  final base = name.split(RegExp(r'[\/]')).last.trim();
  final cleaned = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  final trimmed = cleaned.replaceAll(RegExp(r'^\.+'), '');
  return trimmed.isEmpty ? fallback : trimmed;
}

/// Schemes we are willing to hand to the OS. Blocks `javascript:`, `intent:`,
/// `file:` and `content:` links coming from backend-authored HTML.
const _allowedUrlSchemes = {'https', 'mailto', 'tel'};

/// Open [raw] externally when it is a safe, absolute URL. Returns false when
/// the link was rejected or could not be opened.
Future<bool> openExternalUrl(String? raw) async {
  final uri = Uri.tryParse((raw ?? '').trim());
  if (uri == null || !uri.hasScheme) return false;
  if (!_allowedUrlSchemes.contains(uri.scheme.toLowerCase())) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
