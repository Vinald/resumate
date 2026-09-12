import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumate/data/backup_service.dart';
import 'package:resumate/data/document_repository.dart';
import 'package:resumate/data/document_store.dart';
import 'package:resumate/data/settings_repository.dart';
import 'package:resumate/data/settings_store.dart';
import 'package:resumate/models/document.dart';
import 'package:resumate/models/resume.dart';

void main() {
  late Directory sourceDir;
  late Directory destDir;
  late Directory zipDir;

  setUp(() async {
    sourceDir = await Directory.systemTemp.createTemp('resumate_backup_src');
    destDir = await Directory.systemTemp.createTemp('resumate_backup_dest');
    zipDir = await Directory.systemTemp.createTemp('resumate_backup_zip');
  });

  tearDown(() async {
    for (final d in [sourceDir, destDir, zipDir]) {
      if (await d.exists()) await d.delete(recursive: true);
    }
  });

  test('export then import round-trips documents, settings and signature', () async {
    final sourceDocuments = DocumentStore(
      DocumentRepository(baseDir: sourceDir),
    );
    final sourceSettings = SettingsStore(SettingsRepository(baseDir: sourceDir));
    await sourceDocuments.load();
    await sourceSettings.load();

    // Seed data starts non-empty; add one more document to check the count.
    final startingCount = sourceDocuments.documents.length;
    await sourceDocuments.save(
      GeneratedDocument(
        id: 'extra',
        type: DocumentType.resume,
        title: 'Extra resume',
        updatedAt: DateTime(2026, 1, 1),
        resume: ResumeData(summary: 'Backed up'),
      ),
    );

    final sigFile = File('${sourceDir.path}/signature.png');
    await sigFile.writeAsBytes([1, 2, 3, 4]);
    await sourceSettings.update(
      sourceSettings.settings.copyWith(signatureImagePath: sigFile.path),
    );

    final zip = await BackupService.export(
      sourceDocuments,
      sourceSettings,
      tempDir: zipDir,
    );
    expect(await zip.exists(), isTrue);

    final destDocuments = DocumentStore(DocumentRepository(baseDir: destDir));
    final destSettings = SettingsStore(SettingsRepository(baseDir: destDir));
    await destDocuments.load();
    await destSettings.load();

    final result = await BackupService.import(
      zip,
      destDocuments,
      destSettings,
      appDocsDir: destDir,
    );

    expect(result.documentCount, startingCount + 1);
    expect(result.hasSignature, isTrue);
    expect(
      destDocuments.documents.map((d) => d.title),
      contains('Extra resume'),
    );
    // Imported documents get fresh ids rather than colliding with seed data.
    expect(destDocuments.documents.where((d) => d.id == 'extra'), isEmpty);

    expect(destSettings.settings.signatureImagePath, '${destDir.path}/signature.png');
    expect(
      await File(destSettings.settings.signatureImagePath!).readAsBytes(),
      [1, 2, 3, 4],
    );
  });

  test('import throws on a non-backup file', () async {
    final documents = DocumentStore(DocumentRepository(baseDir: destDir));
    final settings = SettingsStore(SettingsRepository(baseDir: destDir));
    await documents.load();
    await settings.load();

    final notAZip = File('${zipDir.path}/not_a_backup.zip');
    await notAZip.writeAsString('not actually a zip');

    expect(
      () => BackupService.import(
        notAZip,
        documents,
        settings,
        appDocsDir: destDir,
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
