import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_settings.dart';
import '../models/document.dart';
import '../render/document_pdf.dart';
import 'docx_export.dart';
import 'filename.dart';
import 'tex_export.dart';
import 'text_export.dart';

enum ExportFormat {
  pdf('PDF', 'pdf'),
  docx('Word (DOCX)', 'docx'),
  tex('LaTeX (.tex)', 'tex'),
  txt('Plain text', 'txt'),
  markdown('Markdown', 'md');

  const ExportFormat(this.label, this.extension);

  final String label;
  final String extension;
}

class ExportService {
  /// Writes [doc] in [format] to a temp file and returns its path.
  static Future<File> writeToFile(
    GeneratedDocument doc,
    AppSettings settings,
    ExportFormat format,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/${safeExportFilename(doc)}.${format.extension}',
    );

    switch (format) {
      case ExportFormat.pdf:
        await file.writeAsBytes(await buildDocumentPdf(doc, settings));
      case ExportFormat.docx:
        await file.writeAsBytes(DocxExport.build(doc));
      case ExportFormat.tex:
        await file.writeAsString(await buildDocumentTex(doc, settings));
      case ExportFormat.txt:
        await file.writeAsString(TextExport.plain(doc));
      case ExportFormat.markdown:
        await file.writeAsString(TextExport.markdown(doc));
    }
    return file;
  }

  /// Writes [doc] in [format] and opens the system share sheet. For `.tex` with
  /// a configured signature, `signature.png` is attached alongside so it can be
  /// dropped straight into Overleaf.
  static Future<void> share(
    GeneratedDocument doc,
    AppSettings settings,
    ExportFormat format,
  ) async {
    final file = await writeToFile(doc, settings, format);
    final files = [XFile(file.path)];

    if (format == ExportFormat.tex &&
        doc.type.isLetter &&
        settings.signatureImagePath != null) {
      final sig = File(settings.signatureImagePath!);
      if (await sig.exists()) {
        files.add(XFile(sig.path, name: 'signature.png'));
      }
    }

    await Share.shareXFiles(files, subject: doc.title);
  }
}
