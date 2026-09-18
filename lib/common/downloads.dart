import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevenup_mobile/common/safety.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';

/// Saves files into the phone's Downloads folder through the native MediaStore
/// bridge, and can open one afterwards in the phone's viewer.
class Downloads {
  static const _channel = MethodChannel('certificate/downloads');

  /// Writes [bytes] to Downloads as [filename]. Returns the saved name and the
  /// content URI used to open it.
  static Future<({String name, String? uri})> save({
    required String filename,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final safe = safeFileName(filename);
    final res = await _channel.invokeMethod<dynamic>('saveToDownloads', {
      'filename': safe,
      'mimeType': mimeType,
      'bytes': Uint8List.fromList(bytes),
    });
    if (res is Map) {
      return (
        name: res['name']?.toString() ?? safe,
        uri: res['uri']?.toString(),
      );
    }
    // Older bridge returned just the file name.
    return (name: res?.toString() ?? safe, uri: null);
  }

  /// Opens a saved download in whatever app handles [mimeType]. Returns false
  /// when the phone has nothing that can display it.
  static Future<bool> open(String? uri, String mimeType) async {
    if (uri == null || uri.isEmpty) return false;
    try {
      return await _channel.invokeMethod<bool>('openDownload', {
            'uri': uri,
            'mimeType': mimeType,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Standard "Saved to Downloads: x" confirmation with an OPEN action.
  static void showSaved(
    BuildContext context, {
    required String name,
    required String? uri,
    required String mimeType,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTokens.primary,
        duration: const Duration(seconds: 6),
        content: Text('Saved to Downloads: $name',
            style: AppTokens.manrope(
                size: 14, weight: 600, color: Colors.white)),
        action: uri == null
            ? null
            : SnackBarAction(
                label: 'OPEN',
                textColor: Colors.white,
                onPressed: () async {
                  final opened = await open(uri, mimeType);
                  if (!opened) {
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text(
                            'No app on this phone can open this file type.'),
                      ));
                  }
                },
              ),
      ));
  }
}
