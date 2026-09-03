import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_settings.dart';
import '../models/document.dart';
import '../render/document_pdf.dart';
import 'docx_export.dart';
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
    final safeName = doc.title.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    final file = File('${dir.path}/$safeName.${format.extension}');

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

  /// Writes [doc] in [format] and opens the system share sheet.
  static Future<void> share(
    GeneratedDocument doc,
    AppSettings settings,
    ExportFormat format,
  ) async {
    final file = await writeToFile(doc, settings, format);
    await Share.shareXFiles([XFile(file.path)], subject: doc.title);
  }
}
