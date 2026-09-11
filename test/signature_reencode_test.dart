import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:resumate/ui/widgets/signature_picker.dart';

/// Regression coverage: `SignaturePicker` used to copy
/// whatever `image_picker` returned straight to `signature.png`, so a HEIC
/// or WebP asset saved under a `.png` name would later crash
/// `pw.MemoryImage` in letter exports. `decodeAndReencodeSignaturePng` is the
/// fix's core: it's a plain function (no platform channels), so it's tested
/// directly here rather than by driving the real gallery picker.
void main() {
  group('decodeAndReencodeSignaturePng', () {
    test('re-encodes a non-PNG image (e.g. BMP) into a valid, decodable PNG', () {
      final source = img.Image(width: 4, height: 3);
      img.fill(source, color: img.ColorRgb8(10, 20, 30));
      final bmpBytes = Uint8List.fromList(img.encodeBmp(source));

      final result = decodeAndReencodeSignaturePng(bmpBytes);

      expect(result, isNotNull);
      final decoded = img.decodePng(result!);
      expect(decoded, isNotNull);
      expect(decoded!.width, 4);
      expect(decoded.height, 3);
    });

    test('is a no-op re-encode for bytes that are already a PNG', () {
      final source = img.Image(width: 2, height: 2);
      final pngBytes = Uint8List.fromList(img.encodePng(source));

      final result = decodeAndReencodeSignaturePng(pngBytes);

      expect(result, isNotNull);
      expect(img.decodePng(result!)?.width, 2);
    });

    test('returns null for bytes that are not a decodable image at all', () {
      final garbage = Uint8List.fromList('definitely not an image'.codeUnits);

      expect(decodeAndReencodeSignaturePng(garbage), isNull);
    });

    test('returns null for empty bytes', () {
      expect(decodeAndReencodeSignaturePng(Uint8List(0)), isNull);
    });
  });
}
