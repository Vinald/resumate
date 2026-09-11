import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resumate/data/document_repository.dart';
import 'package:resumate/data/document_store.dart';
import 'package:resumate/data/settings_repository.dart';
import 'package:resumate/data/settings_store.dart';
import 'package:resumate/models/document.dart';
import 'package:resumate/ui/export/export_sheet.dart';

/// Only checks that the sheet lists every export format with the right
/// label/icon and can be dismissed. Tapping a format actually calls
/// `ExportService.share`, which does real file I/O and hits the `share_plus`
/// platform channel — out of scope here for the same reason other screens'
/// save/share actions are, per this repo's testing-seam notes.
void main() {
  late Directory tempDir;
  late DocumentStore documentStore;
  late SettingsStore settingsStore;
  late String resumeId;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resumate_export_test');
    documentStore = DocumentStore(DocumentRepository(baseDir: tempDir));
    await documentStore.load();
    settingsStore = SettingsStore(SettingsRepository(baseDir: tempDir));
    await settingsStore.load();
    resumeId = documentStore.documents
        .firstWhere((d) => d.type == DocumentType.resume)
        .id;
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
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showExportSheet(context, resumeId),
              child: const Text('Open export sheet'),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('lists every export format', (tester) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.text('Open export sheet'));
    await settle(tester);

    expect(find.text('Export as'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('Word (DOCX)'), findsOneWidget);
    expect(find.text('LaTeX (.tex)'), findsOneWidget);
    expect(find.text('Plain text'), findsOneWidget);
    expect(find.text('Markdown'), findsOneWidget);
  });

  testWidgets('tapping outside dismisses the sheet without exporting', (
    tester,
  ) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.text('Open export sheet'));
    await settle(tester);

    // Tap the barrier above the sheet, not a format row.
    await tester.tapAt(const Offset(200, 50));
    await settle(tester);

    expect(find.text('Export as'), findsNothing);
  });
}
