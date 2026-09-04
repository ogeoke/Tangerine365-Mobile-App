// One-off: normalize the Home service-module icons so every glyph has the same
// visual size. Each source PNG is 128x128 but the artwork fills a different
// fraction of the canvas; we trim the transparent padding, then rescale each
// glyph to an equal footprint centered on a uniform 128x128 canvas.
//
// Run from the project root:  dart run tool/normalize_icons.dart
import 'dart:io';
import 'package:image/image.dart' as img;

const canvas = 128; // output size
const target = 96; // glyph footprint (max dimension) inside the canvas

void main() {
  const files = [
    'assets/images/mod_courses.png',
    'assets/images/mod_repository.png',
    'assets/images/mod_banking.png',
    'assets/images/mod_information.png',
  ];

  for (final path in files) {
    final src = img.decodePng(File(path).readAsBytesSync());
    if (src == null) {
      stderr.writeln('skip (decode failed): $path');
      continue;
    }

    // Bounding box of non-transparent pixels.
    int minX = src.width, minY = src.height, maxX = -1, maxY = -1;
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        if (src.getPixel(x, y).a > 8) {
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }
    if (maxX < minX || maxY < minY) {
      stderr.writeln('skip (empty): $path');
      continue;
    }

    final cropW = maxX - minX + 1;
    final cropH = maxY - minY + 1;
    final cropped =
        img.copyCrop(src, x: minX, y: minY, width: cropW, height: cropH);

    // Scale so the larger side becomes `target`, preserving aspect ratio.
    final scale = target / (cropW > cropH ? cropW : cropH);
    final newW = (cropW * scale).round();
    final newH = (cropH * scale).round();
    final resized = img.copyResize(cropped,
        width: newW, height: newH, interpolation: img.Interpolation.cubic);

    final out = img.Image(width: canvas, height: canvas, numChannels: 4);
    img.compositeImage(out, resized,
        dstX: ((canvas - newW) / 2).round(),
        dstY: ((canvas - newH) / 2).round());

    File(path).writeAsBytesSync(img.encodePng(out));
    stdout.writeln('normalized $path  (glyph ${cropW}x$cropH -> ${newW}x$newH)');
  }
}
