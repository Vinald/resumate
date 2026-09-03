import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/document_store.dart';
import '../../models/document.dart';
import '../letter_editor/letter_editor_screen.dart';
import '../pdf_combiner/pdf_combiner_screen.dart';
import '../resume_editor/resume_editor_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resume Generator'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Resumes'), Tab(text: 'Letters')],
          ),
          actions: [
            IconButton(
              tooltip: 'Combine PDFs',
              icon: const Icon(Icons.merge_type),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PdfCombinerScreen(),
                    ),
                  ),
            ),
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
            ),
          ],
        ),
        body: Consumer<DocumentStore>(
          builder: (context, store, _) {
            if (store.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _DocumentList(
                  documents: store.byType((t) => t == DocumentType.resume),
                  emptyLabel: 'No resumes yet',
                ),
                _DocumentList(
                  documents: store.byType((t) => t.isLetter),
                  emptyLabel: 'No letters yet',
                ),
              ],
            );
          },
        ),
        floatingActionButton: _CreateFab(),
      ),
    );
  }
}

class _CreateFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final type = await showModalBottomSheet<DocumentType>(
          context: context,
          builder:
              (_) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final t in DocumentType.values)
                      ListTile(
                        leading: Icon(
                          t == DocumentType.resume
                              ? Icons.description
                              : Icons.mail_outline,
                        ),
                        title: Text(t.label),
                        onTap: () => Navigator.of(context).pop(t),
                      ),
                  ],
                ),
              ),
        );
        if (type == null || !context.mounted) return;
        final store = context.read<DocumentStore>();
        final doc = await store.create(type);
        if (!context.mounted) return;
        _openDocument(context, doc);
      },
      icon: const Icon(Icons.add),
      label: const Text('New'),
    );
  }
}

void _openDocument(BuildContext context, GeneratedDocument doc) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder:
          (_) =>
              doc.type == DocumentType.resume
                  ? ResumeEditorScreen(documentId: doc.id)
                  : LetterEditorScreen(documentId: doc.id),
    ),
  );
}

class _DocumentList extends StatelessWidget {
  const _DocumentList({required this.documents, required this.emptyLabel});

  final List<GeneratedDocument> documents;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Center(
        child: Text(emptyLabel, style: Theme.of(context).textTheme.bodyLarge),
      );
    }
    final fmt = DateFormat.yMMMd().add_jm();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: documents.length,
      itemBuilder: (context, i) {
        final doc = documents[i];
        return ListTile(
          leading: Icon(
            doc.type == DocumentType.resume
                ? Icons.description_outlined
                : Icons.mail_outline,
          ),
          title: Text(doc.title),
          subtitle: Text('${doc.type.label} · ${fmt.format(doc.updatedAt)}'),
          onTap: () => _openDocument(context, doc),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _onMenu(context, doc, value),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
          ),
        );
      },
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    GeneratedDocument doc,
    String action,
  ) async {
    final store = context.read<DocumentStore>();
    switch (action) {
      case 'rename':
        final name = await _promptText(context, 'Rename', doc.title);
        if (name != null && name.isNotEmpty) {
          doc.title = name;
          await store.save(doc);
        }
      case 'duplicate':
        await store.duplicate(doc);
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Delete document?'),
                content: Text('"${doc.title}" will be permanently removed.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        );
        if (ok == true) await store.delete(doc.id);
    }
  }
}

Future<String?> _promptText(
  BuildContext context,
  String title,
  String initial,
) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: Text(title),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
  );
}
