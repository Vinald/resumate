import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/document_store.dart';
import '../../data/settings_store.dart';
import '../../latex/tokens.dart';
import '../../models/document.dart';
import '../../export/tex_export.dart';

class LatexEditorScreen extends StatefulWidget {
  const LatexEditorScreen({super.key, required this.documentId});

  final String documentId;

  @override
  State<LatexEditorScreen> createState() => _LatexEditorScreenState();
}

class _LatexEditorScreenState extends State<LatexEditorScreen> {
  final _controller = TextEditingController();
  bool _loading = true;
  late GeneratedDocument _doc;

  @override
  void initState() {
    super.initState();
    _doc = context.read<DocumentStore>().byId(widget.documentId)!;
    _load();
  }

  Future<void> _load() async {
    final settings = context.read<SettingsStore>().settings;
    _controller.text = await buildDocumentTex(_doc, settings);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _shareTex() async {
    final dir = await getTemporaryDirectory();
    final safe = _doc.title.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    final file = File('${dir.path}/$safe.tex');
    await file.writeAsString(_controller.text);
    await Share.shareXFiles([XFile(file.path)], subject: '${_doc.title}.tex');
  }

  void _showTokens() {
    final tokens =
        _doc.type == DocumentType.resume ? resumeTokens : letterTokens;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => DraftScrollSheet(
            child: ListView(
              shrinkWrap: true,
              children: [
                const ListTile(
                  title: Text('Template tokens'),
                  subtitle: Text('Filled from your document data on export'),
                ),
                for (final t in tokens)
                  ListTile(
                    dense: true,
                    title: Text(
                      t.token,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    subtitle: Text(t.description),
                  ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LaTeX source'),
        actions: [
          IconButton(
            tooltip: 'Tokens',
            icon: const Icon(Icons.help_outline),
            onPressed: _showTokens,
          ),
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: _controller.text),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('LaTeX copied')),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Share .tex',
            icon: const Icon(Icons.ios_share),
            onPressed: _shareTex,
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.35,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
    );
  }
}

/// Simple sheet wrapper that keeps content within the viewport.
class DraftScrollSheet extends StatelessWidget {
  const DraftScrollSheet({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: child,
      ),
    );
  }
}
