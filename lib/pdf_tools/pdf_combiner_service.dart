import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
import 'package:pdf_combiner/responses/pdf_combiner_status.dart';

class PdfCombineResult {
  PdfCombineResult({required this.ok, this.path, this.error});
  final bool ok;
  final String? path;
  final String? error;
}

/// Merges the given PDF files (in order) into a single PDF in temp storage.
class PdfCombinerService {
  static Future<PdfCombineResult> merge(List<String> inputPaths) async {
    if (inputPaths.length < 2) {
      return PdfCombineResult(
        ok: false,
        error: 'Pick at least two PDFs to combine.',
      );
    }
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${dir.path}/combined_$stamp.pdf';

    try {
      final response = await PdfCombiner.mergeMultiplePDFs(
        inputPaths: inputPaths,
        outputPath: outputPath,
      );
      if (response.status == PdfCombinerStatus.success) {
        final resolved = response.response ?? outputPath;
        if (await File(resolved).exists()) {
          return PdfCombineResult(ok: true, path: resolved);
        }
        return PdfCombineResult(
          ok: false,
          error: 'Merge reported success but no file was written.',
        );
      }
      return PdfCombineResult(
        ok: false,
        error: response.message ?? 'Merge failed.',
      );
    } catch (e) {
      return PdfCombineResult(ok: false, error: '$e');
    }
  }
}
