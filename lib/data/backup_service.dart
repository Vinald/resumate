import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/app_settings.dart';
import '../models/document.dart';
import 'document_store.dart';
import 'settings_store.dart';

/// Outcome of a successful [BackupService.import].
class BackupImportResult {
  const BackupImportResult({required this.documentCount, required this.hasSignature});

  final int documentCount;
  final bool hasSignature;
}

/// Bundles all app data (documents, settings, signature image) into a single
/// `.zip` file for backup, and restores from one on another device.
class BackupService {
  static const schemaVersion = 1;
  static const _uuid = Uuid();

  /// Writes a backup zip to [tempDir] (defaults to the system temp
  /// directory) and returns it.
  static Future<File> export(
    DocumentStore documents,
    SettingsStore settingsStore, {
    Directory? tempDir,
  }) async {
    final settings = settingsStore.settings;
    final archive = Archive();

    final manifest = {
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.toJson(),
      'documents': [for (final d in documents.documents) d.toJson()],
    };
    final manifestBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(manifest),
    );
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );

    if (settings.signatureImagePath != null) {
      final sig = File(settings.signatureImagePath!);
      if (await sig.exists()) {
        final bytes = await sig.readAsBytes();
        archive.addFile(ArchiveFile('signature.png', bytes.length, bytes));
      }
    }

    final zipBytes = ZipEncoder().encode(archive)!;
    final dir = tempDir ?? await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/resumate_backup_$timestamp.zip');
    await file.writeAsBytes(zipBytes);
    return file;
  }

  /// Reads [zipFile], adds its documents to [documents], and overwrites
  /// [settingsStore]'s settings (and signature image, written under
  /// [appDocsDir], which defaults to the app documents directory).
  ///
  /// Throws a [FormatException] if the file isn't a recognised backup.
  static Future<BackupImportResult> import(
    File zipFile,
    DocumentStore documents,
    SettingsStore settingsStore, {
    Directory? appDocsDir,
  }) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
    } catch (_) {
      throw const FormatException('Not a Resumate backup file.');
    }

    final manifestFile = archive.files.firstWhereOrNull(
      (f) => f.name == 'manifest.json',
    );
    if (manifestFile == null) {
      throw const FormatException('Not a Resumate backup file.');
    }
    final manifest =
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>;

    if (manifest['schemaVersion'] != schemaVersion) {
      throw FormatException(
        'Unsupported backup version: ${manifest['schemaVersion']}',
      );
    }

    String? signaturePath;
    final sigFile = archive.files.firstWhereOrNull(
      (f) => f.name == 'signature.png',
    );
    if (sigFile != null) {
      final dir = appDocsDir ?? await getApplicationDocumentsDirectory();
      final saved = File('${dir.path}/signature.png');
      await saved.writeAsBytes(sigFile.content as List<int>);
      signaturePath = saved.path;
    }

    final importedSettings = AppSettings.fromJson(
      (manifest['settings'] as Map).cast<String, dynamic>(),
    ).copyWith(signatureImagePath: signaturePath, clearSignature: signaturePath == null);
    await settingsStore.update(importedSettings);

    final docsJson = (manifest['documents'] as List)
        .map((j) => (j as Map).cast<String, dynamic>())
        .toList();
    for (final json in docsJson) {
      final doc = GeneratedDocument.fromJson(
        json,
      ).copyWith(id: _uuid.v4(), updatedAt: DateTime.now());
      await documents.save(doc);
    }

    return BackupImportResult(
      documentCount: docsJson.length,
      hasSignature: signaturePath != null,
    );
  }
}
