import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/document.dart';
import '../models/letter.dart';
import '../models/resume.dart';
import 'document_repository.dart';
import 'seed_data.dart';

/// In-memory list of documents, backed by [DocumentRepository].
class DocumentStore extends ChangeNotifier {
  DocumentStore(this._repo);

  final DocumentRepository _repo;
  static const _uuid = Uuid();

  final List<GeneratedDocument> _documents = [];
  bool _loading = true;

  List<GeneratedDocument> get documents => List.unmodifiable(_documents);
  bool get loading => _loading;

  List<GeneratedDocument> byType(bool Function(DocumentType) test) =>
      _documents.where((d) => test(d.type)).toList();

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    if (await _repo.isEmpty()) {
      for (final doc in SeedData.initialDocuments()) {
        await _repo.save(doc);
      }
    }
    _documents
      ..clear()
      ..addAll(await _repo.loadAll());
    _loading = false;
    notifyListeners();
  }

  GeneratedDocument? byId(String id) {
    for (final d in _documents) {
      if (d.id == id) return d;
    }
    return null;
  }

  Future<void> save(GeneratedDocument doc) async {
    doc.touch();
    await _repo.save(doc);
    final index = _documents.indexWhere((d) => d.id == doc.id);
    if (index == -1) {
      _documents.insert(0, doc);
    } else {
      _documents[index] = doc;
    }
    _sort();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _documents.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  Future<GeneratedDocument> create(DocumentType type) async {
    final doc = GeneratedDocument(
      id: _uuid.v4(),
      type: type,
      title: 'New ${type.label}',
      updatedAt: DateTime.now(),
      resume: type == DocumentType.resume ? SeedData.resume() : null,
      letter:
          type.isLetter
              ? LetterData(
                contact: SeedData.contact,
                kind: type.letterKind,
              )
              : null,
    );
    await save(doc);
    return doc;
  }

  Future<GeneratedDocument> duplicate(GeneratedDocument source) async {
    final copy = source.copyWith(
      id: _uuid.v4(),
      title: '${source.title} (copy)',
      updatedAt: DateTime.now(),
      resume: source.resume?.copy(),
      letter: source.letter?.copy(),
    );
    await save(copy);
    return copy;
  }

  void _sort() =>
      _documents.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
}

/// Convenience for building empty payloads in tests / callers.
ResumeData emptyResume() => ResumeData(contact: SeedData.contact);
