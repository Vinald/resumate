import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';

import '../models/app_settings.dart';
import '../models/document.dart';
import 'pdf_theme.dart';
import 'template_registry.dart';

/// Renders a [GeneratedDocument] to PDF bytes using the configured template
/// and [AppSettings].
Future<Uint8List> buildDocumentPdf(
  GeneratedDocument doc,
  AppSettings settings, {
  PdfPageFormat pageFormat = PdfPageFormat.a4,
}) async {
  final theme = await PdfTheme.create(settings);

  if (doc.type == DocumentType.resume) {
    final template = TemplateRegistry.resume(doc.templateId);
    return template.build(doc.resume!, theme, pageFormat: pageFormat).save();
  }

  List<int>? signature;
  final path = settings.signatureImagePath;
  if (path != null && path.isNotEmpty) {
    final file = File(path);
    if (await file.exists()) {
      signature = await file.readAsBytes();
    }
  }

  final template = TemplateRegistry.letter('classic_letter');
  return template
      .build(doc.letter!, theme, signature: signature, pageFormat: pageFormat)
      .save();
}
