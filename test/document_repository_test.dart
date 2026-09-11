import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumate/data/document_repository.dart';
import 'package:resumate/data/seed_data.dart';
import 'package:resumate/models/document.dart';
import 'package:resumate/models/resume.dart';

void main() {
  late Directory tempDir;
  late DocumentRepository repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resume_repo_test');
    repo = DocumentRepository(baseDir: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('starts empty, then persists saved documents', () async {
    expect(await repo.isEmpty(), isTrue);

    for (final doc in SeedData.initialDocuments()) {
      await repo.save(doc);
    }

    expect(await repo.isEmpty(), isFalse);
    final all = await repo.loadAll();
    expect(all.length, 3);
  });

  test('save overwrites the same id and loadAll sorts newest first', () async {
    final a = GeneratedDocument(
      id: 'a',
      type: DocumentType.resume,
      title: 'A',
      updatedAt: DateTime(2026, 1, 1),
      resume: ResumeData(),
    );
    final b = GeneratedDocument(
      id: 'b',
      type: DocumentType.resume,
      title: 'B',
      updatedAt: DateTime(2026, 2, 1),
      resume: ResumeData(),
    );
    await repo.save(a);
    await repo.save(b);

    a.title = 'A-updated';
    a.updatedAt = DateTime(2026, 3, 1);
    await repo.save(a);

    final all = await repo.loadAll();
    expect(all.map((d) => d.title), ['A-updated', 'B']);
  });

  test('delete removes the file', () async {
    final doc = GeneratedDocument(
      id: 'gone',
      type: DocumentType.resume,
      title: 'Gone',
      updatedAt: DateTime.now(),
      resume: ResumeData(),
    );
    await repo.save(doc);
    await repo.delete('gone');
    expect(await repo.loadAll(), isEmpty);
  });
}
