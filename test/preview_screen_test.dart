import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:resumate/data/document_repository.dart';
import 'package:resumate/data/document_store.dart';
import 'package:resumate/data/settings_repository.dart';
import 'package:resumate/data/settings_store.dart';
import 'package:resumate/models/document.dart';
import 'package:resumate/ui/preview/preview_screen.dart';

/// Only the screen's own wiring (title, which document it asks for, the
/// `PdfPreview` it's built around) is covered here. The actual raster
/// preview goes through the `printing` plugin's platform channel, which has
/// no mock in this environment — not exercised, same rationale as the other
/// screens' native-plugin actions.
void main() {
  late Directory tempDir;
  late DocumentStore documentStore;
  late SettingsStore settingsStore;
  late String resumeId;
  late String resumeTitle;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resumate_preview_test');
    documentStore = DocumentStore(DocumentRepository(baseDir: tempDir));
    await documentStore.load();
    settingsStore = SettingsStore(SettingsRepository(baseDir: tempDir));
    await settingsStore.load();
    final resume = documentStore.documents.firstWhere(
      (d) => d.type == DocumentType.resume,
    );
    resumeId = resume.id;
    resumeTitle = resume.title;
  });

  tearDown(() async {
    settingsStore.dispose();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Widget harness() => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: documentStore),
      ChangeNotifierProvider.value(value: settingsStore),
    ],
    child: MaterialApp(home: PreviewScreen(documentId: resumeId)),
  );

  testWidgets('titles the AppBar with the document and builds a PdfPreview', (
    tester,
  ) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.text('Preview · $resumeTitle'), findsOneWidget);
    expect(find.byType(PdfPreview), findsOneWidget);
  });
}
