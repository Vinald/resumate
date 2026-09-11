import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../data/document_store.dart';
import '../../data/settings_store.dart';
import '../../export/filename.dart';
import '../../render/document_pdf.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context) {
    final doc = context.read<DocumentStore>().byId(documentId)!;
    final settings = context.watch<SettingsStore>().settings;

    return Scaffold(
      appBar: AppBar(title: Text('Preview · ${doc.title}')),
      body: PdfPreview(
        build: (format) => buildDocumentPdf(doc, settings, pageFormat: format),
        canDebug: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: '${safeExportFilename(doc)}.pdf',
      ),
    );
  }
}
