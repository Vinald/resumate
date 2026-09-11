import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/document_store.dart';
import '../../data/settings_store.dart';
import '../../models/document.dart';
import '../letter_editor/letter_editor_screen.dart';
import '../pdf_combiner/pdf_combiner_screen.dart';
import '../resume_editor/resume_editor_screen.dart';
import '../settings/settings_screen.dart';
import '../tutorial/tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _promptedTutorial = false;

  /// Shows the "Welcome" prompt once, the first time settings have finished
  /// loading and no prior launch has already dismissed it.
  void _maybeShowTutorialPrompt(SettingsStore settingsStore) {
    if (_promptedTutorial ||
        settingsStore.loading ||
        settingsStore.settings.tutorialSeen) {
      return;
    }
    _promptedTutorial = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showTutorialPrompt(settingsStore);
    });
  }

  Future<void> _showTutorialPrompt(SettingsStore settingsStore) async {
    final openTutorial = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Welcome to Resumate'),
            content: const Text(
              'New here? A quick walkthrough covers editing, previewing, '
              'signatures and exporting.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Skip'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Show me'),
              ),
            ],
          ),
    );
    await settingsStore.update(
      settingsStore.settings.copyWith(tutorialSeen: true),
    );
    if (openTutorial == true && mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const TutorialScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    _maybeShowTutorialPrompt(context.watch<SettingsStore>());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resumate'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Resumes'), Tab(text: 'Letters')],
          ),
          actions: [
            IconButton(
              tooltip: 'How Resumate works',
              icon: const Icon(Icons.help_outline),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TutorialScreen()),
                  ),
            ),
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
        final colorScheme = Theme.of(context).colorScheme;
        final type = await showModalBottomSheet<DocumentType>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder:
              (_) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Row(
                        children: [
                          Text(
                            'New document',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final t in DocumentType.values)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              t == DocumentType.resume
                                  ? colorScheme.primaryContainer
                                  : colorScheme.secondaryContainer,
                          foregroundColor:
                              t == DocumentType.resume
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSecondaryContainer,
                          child: Icon(
                            t == DocumentType.resume
                                ? Icons.description_outlined
                                : Icons.mail_outline,
                            size: 20,
                          ),
                        ),
                        title: Text(t.label),
                        onTap: () => Navigator.of(context).pop(t),
                      ),
                    const SizedBox(height: 8),
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
    final colorScheme = Theme.of(context).colorScheme;

    if (documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.note_add_outlined,
                size: 56,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                emptyLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap New to create one.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final fmt = DateFormat.yMMMd().add_jm();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 96),
      itemCount: documents.length,
      itemBuilder: (context, i) {
        final doc = documents[i];
        final isResume = doc.type == DocumentType.resume;
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            leading: CircleAvatar(
              backgroundColor:
                  isResume
                      ? colorScheme.primaryContainer
                      : colorScheme.secondaryContainer,
              foregroundColor:
                  isResume
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
              child: Icon(
                isResume ? Icons.description_outlined : Icons.mail_outline,
                size: 20,
              ),
            ),
            title: Text(
              doc.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
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
