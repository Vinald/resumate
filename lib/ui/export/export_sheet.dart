import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/document_store.dart';
import '../../data/settings_store.dart';
import '../../export/export_service.dart';

/// Bottom sheet offering every export format for a document.
void showExportSheet(BuildContext context, String documentId) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Export as', style: TextStyle(fontSize: 16)),
            ),
            for (final format in ExportFormat.values)
              ListTile(
                leading: Icon(_iconFor(format)),
                title: Text(format.label),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final store = context.read<DocumentStore>();
                  final settings = context.read<SettingsStore>().settings;
                  final doc = store.byId(documentId);
                  if (doc == null) return;
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await ExportService.share(doc, settings, format);
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                },
              ),
          ],
        ),
      );
    },
  );
}

IconData _iconFor(ExportFormat format) => switch (format) {
  ExportFormat.pdf => Icons.picture_as_pdf,
  ExportFormat.docx => Icons.description,
  ExportFormat.tex => Icons.code,
  ExportFormat.txt => Icons.notes,
  ExportFormat.markdown => Icons.text_snippet,
};
