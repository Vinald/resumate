import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../pdf_tools/pdf_combiner_service.dart';

class PdfCombinerScreen extends StatefulWidget {
  const PdfCombinerScreen({super.key});

  @override
  State<PdfCombinerScreen> createState() => _PdfCombinerScreenState();
}

class _PickedPdf {
  _PickedPdf(this.name, this.path);
  final String name;
  final String path;
}

class _PdfCombinerScreenState extends State<PdfCombinerScreen> {
  final List<_PickedPdf> _files = [];
  bool _busy = false;
  String? _resultPath;

  Future<void> _pick() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    setState(() {
      for (final f in result.files) {
        if (f.path != null) _files.add(_PickedPdf(f.name, f.path!));
      }
      _resultPath = null;
    });
  }

  Future<void> _combine() async {
    setState(() => _busy = true);
    final res = await PdfCombinerService.merge(
      _files.map((f) => f.path).toList(),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _resultPath = res.ok ? res.path : null;
    });
    if (!res.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'Merge failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combine PDFs'),
        actions: [
          if (_resultPath != null)
            IconButton(
              tooltip: 'Share result',
              icon: const Icon(Icons.ios_share),
              onPressed:
                  () => SharePlus.instance.share(
                    ShareParams(
                      files: [XFile(_resultPath!)],
                      subject: 'Combined PDF',
                    ),
                  ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _files.isEmpty
                    ? const Center(
                      child: Text('Add PDFs, reorder them, then combine.'),
                    )
                    : ReorderableListView.builder(
                      itemCount: _files.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          _files.insert(newIndex, _files.removeAt(oldIndex));
                          _resultPath = null;
                        });
                      },
                      itemBuilder: (context, i) {
                        final f = _files[i];
                        return ListTile(
                          key: ValueKey('${f.path}#$i'),
                          leading: const Icon(Icons.picture_as_pdf),
                          title: Text(f.name, overflow: TextOverflow.ellipsis),
                          subtitle: Text('Position ${i + 1}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed:
                                () => setState(() {
                                  _files.removeAt(i);
                                  _resultPath = null;
                                }),
                          ),
                        );
                      },
                    ),
          ),
          if (_resultPath != null)
            SizedBox(
              height: 260,
              child: PdfPreview(
                build: (_) => _readBytes(_resultPath!),
                canDebug: false,
                allowPrinting: false,
                allowSharing: false,
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _pick,
                      icon: const Icon(Icons.add),
                      label: const Text('Add PDFs'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          _busy || _files.length < 2 ? null : _combine,
                      icon:
                          _busy
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                              : const Icon(Icons.merge_type),
                      label: const Text('Combine'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<Uint8List> _readBytes(String path) async {
  return await File(path).readAsBytes();
}
