import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resumate/data/document_repository.dart';
import 'package:resumate/data/document_store.dart';
import 'package:resumate/models/document.dart';
import 'package:resumate/ui/resume_editor/resume_editor_screen.dart';

/// Regression coverage for the resume editor's dirty-state flow: editing a
/// field should show the "Save" FAB, and it should stay hidden until
/// something actually changes.
///
/// Real `dart:io` setup happens in `setUp()`, not inside a `testWidgets`
/// body — see `test/home_screen_tutorial_test.dart`'s header comment for why.
/// The FAB *disappearing* after a save isn't asserted here for the same
/// reason that file documents: `_save()` gates its `setState` behind a real
/// file write, which `flutter_test`'s fake clock doesn't reliably resume
/// within a pump budget.
void main() {
  late Directory tempDir;
  late DocumentStore documentStore;
  late String resumeId;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resumate_editor_test');
    documentStore = DocumentStore(DocumentRepository(baseDir: tempDir));
    await documentStore.load();
    resumeId =
        documentStore.documents
            .firstWhere((d) => d.type == DocumentType.resume)
            .id;
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Widget harness() => ChangeNotifierProvider.value(
    value: documentStore,
    child: MaterialApp(home: ResumeEditorScreen(documentId: resumeId)),
  );

  testWidgets('no unsaved changes: the Save FAB is not shown', (
    tester,
  ) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FloatingActionButton, 'Save'), findsNothing);
  });

  testWidgets('editing a field marks the document dirty and shows Save', (
    tester,
  ) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Professional summary'),
      'Updated summary text',
    );
    await tester.pump();

    expect(find.widgetWithText(FloatingActionButton, 'Save'), findsOneWidget);
  });
}
