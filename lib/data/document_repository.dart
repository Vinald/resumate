import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/document.dart';

/// File-backed storage for [GeneratedDocument]s.
///
/// Each document is a single JSON file, `<id>.json`, inside a `documents`
/// directory. A [baseDir] can be injected for tests; otherwise the app
/// documents directory is used.
class DocumentRepository {
  DocumentRepository({Directory? baseDir}) : _injectedBase = baseDir;

  final Directory? _injectedBase;
  Directory? _dir;

  Future<Directory> _documentsDir() async {
    if (_dir != null) return _dir!;
    final base = _injectedBase ?? await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/documents');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _dir = dir;
    return dir;
  }

  Future<List<GeneratedDocument>> loadAll() async {
    final dir = await _documentsDir();
    final files =
        dir.listSync().whereType<File>().where(
          (f) => f.path.endsWith('.json'),
        );
    final docs = <GeneratedDocument>[];
    for (final file in files) {
      try {
        final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        docs.add(GeneratedDocument.fromJson(json));
      } catch (_) {
        // Skip unreadable / corrupt files rather than failing the whole load.
      }
    }
    docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return docs;
  }

  Future<void> save(GeneratedDocument doc) async {
    final dir = await _documentsDir();
    final file = File('${dir.path}/${doc.id}.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(doc.toJson()),
    );
  }

  Future<void> delete(String id) async {
    final dir = await _documentsDir();
    final file = File('${dir.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> isEmpty() async {
    final dir = await _documentsDir();
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .isEmpty;
  }
}
