import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/common/downloads.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/data/api_repository.dart';
import 'package:sevenup_mobile/models/certificate.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-screen certificate preview.
///
/// Fetches the Fabric.js render payload (`/api/certificates/render`), rebuilds
/// the exact design in a WebView (bundled `fabric.min.js`), substitutes the
/// `[tags]` with the backend's `substitutions`, then captures the rendered
/// canvas as an image — offered as PDF + image via the share sheet.
class CertificatePreviewPage extends StatefulWidget {
  final Certificate certificate;

  /// Render data already returned by `certificates/generate` — when given,
  /// the render API isn't called again.
  final Map<String, dynamic>? renderData;

  /// 'pdf' | 'jpg': save this format automatically once the render is ready.
  final String? autoDownload;

  const CertificatePreviewPage({
    super.key,
    required this.certificate,
    this.renderData,
    this.autoDownload,
  });

  @override
  State<CertificatePreviewPage> createState() => _CertificatePreviewPageState();
}

class _CertificatePreviewPageState extends State<CertificatePreviewPage> {

  WebViewController? _controller;
  bool _loading = true;
  bool _error = false;
  String _errorMsg = 'Could not load this certificate.';

  // Captured render output.
  List<int>? _imageBytes;
  int _imgW = 840;
  int _imgH = 600;
  bool _ready = false;
  String? _saving; // 'pdf' | 'jpg' | null (which format is being saved)
  bool _autoDone = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final c = widget.certificate;
      final raw =
          widget.renderData ??
          (await ApiRepository().getCertificateRender(
            c.id.toString(),
            c.courseId.toString(),
          )).body;
      if (raw == null) {
        return _fail('This certificate could not be generated.');
      }
      final designRaw = raw['design'];
      if (designRaw is! Map) {
        return _fail('This certificate could not be generated.');
      }
      final design = Map<String, dynamic>.from(designRaw);
      final structure = design['structure'];
      final subsRaw = raw['substitutions'];
      final subs = (subsRaw is Map)
          ? Map<String, dynamic>.from(subsRaw)
          : <String, dynamic>{};
      if (structure is! Map) {
        return _fail('This certificate has no design to render.');
      }

      final fabric = await rootBundle.loadString('assets/js/fabric.min.js');
      final html = _buildHtml(
        fabric: fabric,
        structureJson: jsonEncode(structure),
        subsJson: jsonEncode(subs),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/cert_${c.id}.html');
      await file.writeAsString(html);

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..addJavaScriptChannel(
          'Certificate',
          onMessageReceived: (m) => _onMessage(m.message),
        )
        ..loadFile(file.path);

      if (!mounted) return;
      setState(() {
        _controller = controller;
        _loading = false;
      });
    } catch (_) {
      _fail('Something went wrong preparing this certificate.');
    }
  }

  void _fail(String msg) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = true;
      _errorMsg = msg;
    });
  }

  void _onMessage(String message) {
    try {
      final m = jsonDecode(message);
      if (m is Map && m['img'] is String) {
        final url = m['img'] as String;
        final bytes = base64Decode(url.substring(url.indexOf(',') + 1));
        if (!mounted) return;
        setState(() {
          _imageBytes = bytes;
          _imgW = (m['w'] as num?)?.toInt() ?? _imgW;
          _imgH = (m['h'] as num?)?.toInt() ?? _imgH;
          _ready = true;
        });
        // Came from "Generate → Download PDF/JPG": save straight away.
        final fmt = widget.autoDownload;
        if (fmt != null && !_autoDone) {
          _autoDone = true;
          _download(fmt);
        }
      } else if (m is Map && m['error'] != null) {
        _fail('The certificate could not be rendered.');
      }
    } catch (_) {
      /* ignore malformed messages */
    }
  }

  /// Save the rendered certificate to the phone's Downloads folder as [fmt]
  /// ('pdf' or 'jpg').
  Future<void> _download(String fmt) async {
    final bytes = _imageBytes;
    if (bytes == null || _saving != null) return;
    setState(() => _saving = fmt);
    try {
      final c = widget.certificate;
      final safe = c.course.isEmpty
          ? 'certificate'
          : c.course.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
      final base = '${safe}_${c.id}';

      final List<int> data;
      final String name;
      final String mime;
      if (fmt == 'pdf') {
        final pdf = pw.Document();
        final image = pw.MemoryImage(Uint8List.fromList(bytes));
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(_imgW.toDouble(), _imgH.toDouble()),
            build: (_) =>
                pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
          ),
        );
        data = await pdf.save();
        name = '$base.pdf';
        mime = 'application/pdf';
      } else {
        data = bytes;
        name = '$base.jpg';
        mime = 'image/jpeg';
      }

      final saved = await Downloads.save(
        filename: name,
        mimeType: mime,
        bytes: data,
      );
      if (mounted) {
        Downloads.showSaved(context,
            name: saved.name, uri: saved.uri, mimeType: mime);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Could not save the certificate to Downloads.'),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _saving = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.certificate;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: c.title.isEmpty ? 'Certificate' : c.title,
              subtitle: c.course.isEmpty ? 'Your certificate' : c.course,
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: _error
                  ? _ErrorView(
                      message: _errorMsg,
                      onRetry: () {
                        setState(() {
                          _error = false;
                          _loading = true;
                        });
                        _prepare();
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTokens.screenPadding,
                        12,
                        AppTokens.screenPadding,
                        0,
                      ),
                      // Card hugs the certificate's own shape instead of
                      // filling the screen with empty white.
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: AspectRatio(
                          aspectRatio: _imgH == 0 ? 1.4 : _imgW / _imgH,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: AppTokens.surface,
                                    child: _controller == null
                                        ? const SizedBox.shrink()
                                        : WebViewWidget(
                                            controller: _controller!,
                                          ),
                                  ),
                                ),
                                if (_loading || !_ready)
                                  const _CenteredLoader(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            if (!_error)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding,
                  14,
                  AppTokens.screenPadding,
                  18,
                ),
                child: Row(
                  children: [
                    Expanded(child: _downloadBtn('pdf', 'PDF')),
                    const SizedBox(width: 12),
                    Expanded(child: _downloadBtn('jpg', 'JPG')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _downloadBtn(String fmt, String label) {
    final busy = _saving == fmt;
    final enabled = _ready && _saving == null;
    // White pill with a green border and green label (design update).
    final green = enabled
        ? AppTokens.primary
        : AppTokens.primary.withValues(alpha: 0.4);
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTokens.surface,
          side: BorderSide(color: green, width: 1.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: enabled ? () => _download(fmt) : null,
        icon: busy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: green),
              )
            : Icon(Icons.download_rounded, color: green, size: 20),
        label: Text(
          _ready ? label : '…',
          style: AppTokens.manrope(size: 15, weight: 700, color: green),
        ),
      ),
    );
  }

  String _buildHtml({
    required String fabric,
    required String structureJson,
    required String subsJson,
  }) {
    // Guard the injected JSON from prematurely closing the <script> block.
    final struct = structureJson.replaceAll('</', '<\\/');
    final subs = subsJson.replaceAll('</', '<\\/');
    return '''<!DOCTYPE html>
<html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,400;0,600;0,700;1,400;1,700&family=Open+Sans:wght@0,400;0,600;0,700&family=Roboto:wght@400;700&display=swap" rel="stylesheet">
<style>
  html,body{margin:0;padding:0;background:#ffffff;}
  #wrap{padding:10px;box-sizing:border-box;display:flex;justify-content:center;align-items:flex-start;}
  canvas{max-width:100%;height:auto!important;border-radius:6px;box-shadow:0 6px 20px rgba(0,0,0,.15);}
</style>
<script>$fabric</script>
</head><body>
<div id="wrap"><canvas id="c"></canvas></div>
<script>
var STRUCTURE=$struct;var SUBS=$subs;
function sub(t){if(typeof t!=='string')return t;for(var k in SUBS){if(t.indexOf(k)!==-1){var v=SUBS[k];t=t.split(k).join(v==null?'':String(v));}}return t;}
var canvas=new fabric.Canvas('c',{enableRetinaScaling:false,selection:false,interactive:false});
function paint(){
  try{
    canvas.loadFromJSON(STRUCTURE,function(){
      var w=(STRUCTURE.backgroundImage&&STRUCTURE.backgroundImage.width)||840;
      var h=(STRUCTURE.backgroundImage&&STRUCTURE.backgroundImage.height)||600;
      canvas.setWidth(w);canvas.setHeight(h);
      canvas.getObjects().forEach(function(o){
        if(o.text!==undefined&&o.text!==null){o.set('text',sub(o.text));}
      });
      canvas.renderAll();
      setTimeout(grab,400);
    });
  }catch(e){Certificate.postMessage(JSON.stringify({error:String(e)}));}
}
function grab(){
  try{
    var url=canvas.toDataURL({format:'jpeg',quality:0.95});
    Certificate.postMessage(JSON.stringify({img:url,w:canvas.width,h:canvas.height}));
  }catch(e){Certificate.postMessage(JSON.stringify({error:String(e)}));}
}
if(document.fonts&&document.fonts.ready){document.fonts.ready.then(function(){setTimeout(paint,60);});}else{setTimeout(paint,60);}
</script>
</body></html>''';
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEF0EE),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTokens.primary),
          const SizedBox(height: 16),
          Text(
            'Generating your certificate…',
            style: AppTokens.manrope(
              size: 14,
              weight: 500,
              color: AppTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTokens.accent, size: 44),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                size: 15,
                weight: 600,
                color: AppTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTokens.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onRetry,
              child: Text(
                'Try again',
                style: AppTokens.manrope(
                  size: 14,
                  weight: 700,
                  color: AppTokens.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
