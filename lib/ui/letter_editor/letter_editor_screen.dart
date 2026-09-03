import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/document_store.dart';
import '../../models/document.dart';
import '../../models/letter.dart';
import '../export/export_sheet.dart';
import '../latex_editor/latex_editor_screen.dart';
import '../preview/preview_screen.dart';
import '../resume_editor/contact_section.dart';
import '../widgets/editor_widgets.dart';
import '../widgets/signature_picker.dart';

class LetterEditorScreen extends StatefulWidget {
  const LetterEditorScreen({super.key, required this.documentId});

  final String documentId;

  @override
  State<LetterEditorScreen> createState() => _LetterEditorScreenState();
}

class _LetterEditorScreenState extends State<LetterEditorScreen> {
  late GeneratedDocument _doc;
  late LetterData _data;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _doc = context.read<DocumentStore>().byId(widget.documentId)!;
    _data = _doc.letter!.copy();
  }

  void _edit(VoidCallback change) {
    setState(() {
      change();
      _dirty = true;
    });
  }

  Future<void> _save() async {
    _doc.letter = _data.copy();
    await context.read<DocumentStore>().save(_doc);
    setState(() => _dirty = false);
  }

  @override
  Widget build(BuildContext context) {
    final placeholders = _data.placeholderNames.toList()..sort();

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _save();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_doc.title),
          actions: [
            IconButton(
              tooltip: 'LaTeX source',
              icon: const Icon(Icons.code),
              onPressed: () async {
                await _save();
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LatexEditorScreen(documentId: _doc.id),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Preview',
              icon: const Icon(Icons.visibility),
              onPressed: () async {
                await _save();
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PreviewScreen(documentId: _doc.id),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Export',
              icon: const Icon(Icons.ios_share),
              onPressed: () async {
                await _save();
                if (!context.mounted) return;
                showExportSheet(context, _doc.id);
              },
            ),
          ],
        ),
        floatingActionButton:
            _dirty
                ? FloatingActionButton.extended(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                )
                : null,
        body: ListView(
          children: [
            if (placeholders.isNotEmpty)
              SectionCard(
                title: 'Placeholders',
                children: [
                  const Text(
                    'These fill every {{token}} in the letter before export.',
                  ),
                  const SizedBox(height: 8),
                  for (final name in placeholders)
                    EditorField(
                      label: name,
                      value: _data.placeholders[name] ?? '',
                      onChanged:
                          (v) => _edit(() => _data.placeholders[name] = v),
                    ),
                ],
              ),
            ContactSection(
              contact: _data.contact,
              onChanged: (c) => _edit(() => _data.contact = c),
            ),
            SectionCard(
              title: 'Recipient',
              children: [
                EditorField(
                  label: 'Date (blank = today)',
                  value: _data.date,
                  onChanged: (v) => _edit(() => _data.date = v),
                ),
                EditorField(
                  label: 'Department line',
                  value: _data.recipientDept,
                  onChanged: (v) => _edit(() => _data.recipientDept = v),
                ),
                EditorField(
                  label: 'Company name',
                  value: _data.companyName,
                  onChanged: (v) => _edit(() => _data.companyName = v),
                ),
                EditorField(
                  label: 'Company address',
                  value: _data.companyAddress,
                  maxLines: 2,
                  onChanged: (v) => _edit(() => _data.companyAddress = v),
                ),
                EditorField(
                  label: 'Salutation',
                  value: _data.salutation,
                  onChanged: (v) => _edit(() => _data.salutation = v),
                ),
              ],
            ),
            SectionCard(
              title: 'Body',
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _edit(() => _data.body.add('')),
              ),
              children: [
                StringListEditor(
                  label: 'Paragraphs',
                  values: _data.body,
                  itemHint: 'Paragraph',
                  multiline: true,
                  onChanged: (v) => _edit(() => _data.body = v),
                ),
              ],
            ),
            SectionCard(
              title: 'Sign-off',
              children: [
                EditorField(
                  label: 'Closing',
                  value: _data.closing,
                  onChanged: (v) => _edit(() => _data.closing = v),
                ),
                EditorField(
                  label: 'Signature name',
                  value: _data.signatureName,
                  onChanged: (v) => _edit(() => _data.signatureName = v),
                ),
                const SizedBox(height: 8),
                const SignaturePicker(),
              ],
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
