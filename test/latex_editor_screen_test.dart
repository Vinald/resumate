import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resumate/data/document_repository.dart';
import 'package:resumate/data/document_store.dart';
import 'package:resumate/data/settings_repository.dart';
import 'package:resumate/data/settings_store.dart';
import 'package:resumate/models/document.dart';
import 'package:resumate/ui/latex_editor/latex_editor_screen.dart';

/// `_load()` fills the text field via `LatexEngine`/`rootBundle.loadString`.
/// That resolves reliably the *first* time a `testWidgets` in this file
/// loads it, but not in a second, independent `testWidgets` in the same
/// file/isolate — the (already-cached) `Future` from `rootBundle` never
/// completes there, so `_loading` stays true forever. This is the same
/// family of issue as the `dart:io`-hangs-inside-`testWidgets` gotchas
/// documented in `home_screen_tutorial_test.dart`, just via the asset
/// channel instead of real file I/O. Rather than fight it, every scenario
/// that needs the loaded screen is covered by one combined test, so
/// `_load()` only ever runs once per file. `_shareTex` (real file write +
/// share_plus) is not exercised, same as other screens' share/export
/// actions.
void main() {
  late Directory tempDir;
  late DocumentStore documentStore;
  late SettingsStore settingsStore;
  late String resumeId;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resumate_latex_test');
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
    child: MaterialApp(home: LatexEditorScreen(documentId: resumeId)),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets(
    'loads the .tex, shows the unsaved banner, tokens sheet and Copy',
    (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await tester.pumpWidget(harness());
      await settle(tester);

      // Generated with every token filled in.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isNot(contains('<<')));
      expect(field.controller!.text, contains(r'\begin{document}'));

      // Unsaved-edits banner, dismissible.
      expect(find.byType(MaterialBanner), findsOneWidget);
      await tester.tap(find.text('Got it'));
      await settle(tester);
      expect(find.byType(MaterialBanner), findsNothing);

      // Token reference sheet.
      await tester.tap(find.byTooltip('Tokens'));
      await settle(tester);
      expect(find.text('Template tokens'), findsOneWidget);
      expect(find.text('<<NAME>>'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10)); // dismiss the sheet
      await settle(tester);

      // Copy puts the (possibly-edited) buffer on the clipboard.
      await tester.tap(find.byTooltip('Copy'));
      await settle(tester);
      expect(copied, hasLength(1));
      expect(copied.single, contains(r'\begin{document}'));
      expect(find.text('LaTeX copied'), findsOneWidget);
    },
  );
}
