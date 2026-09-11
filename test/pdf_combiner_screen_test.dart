import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumate/ui/pdf_combiner/pdf_combiner_screen.dart';

/// `PdfCombinerScreen` needs no store/provider. "Add PDFs" and "Combine" both
/// hit real platform plugins (`file_picker`, `pdf_combiner`) with no mock
/// registered in the test environment, so only the initial empty state and
/// the button-enablement logic are covered here — not the pick/merge flow
/// itself.
void main() {
  Widget harness() => const MaterialApp(home: PdfCombinerScreen());

  testWidgets('starts empty with Combine disabled', (tester) async {
    await tester.pumpWidget(harness());

    expect(find.text('Combine PDFs'), findsOneWidget);
    expect(find.text('Add PDFs, reorder them, then combine.'), findsOneWidget);

    // `FilledButton.icon` returns a `FilledButton` subtype, not a
    // `FilledButton` instance, so `find.byType`/`widgetWithText` (exact
    // runtimeType match) miss it — match by `is` instead.
    final combineButton = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Combine'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ),
    );
    expect(combineButton.onPressed, isNull);
  });

  testWidgets('has no share action before anything is combined', (
    tester,
  ) async {
    await tester.pumpWidget(harness());

    expect(find.byTooltip('Share result'), findsNothing);
  });
}
