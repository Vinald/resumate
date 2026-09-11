import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumate/ui/widgets/editor_widgets.dart';

/// Regression test for REVIEW.md M1: reordering a row must keep its text with it,
/// both in the emitted list and in what the fields display.
void main() {
  Future<void> pumpEditor(
    WidgetTester tester,
    List<String> initial,
    void Function(List<String>) onChanged,
  ) async {
    var values = initial;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => StringListEditor(
              label: 'Bullets',
              values: values,
              onChanged: (v) {
                onChanged(v);
                setState(() => values = v);
              },
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('move up reorders the row and its text', (tester) async {
    List<String> latest = [];
    await pumpEditor(tester, ['alpha', 'beta', 'gamma'], (v) => latest = v);

    // The "Move up" button on the second row (index 1).
    final moveUp = find.widgetWithIcon(IconButton, Icons.arrow_upward);
    await tester.tap(moveUp.at(1));
    await tester.pumpAndSettle();

    expect(latest, ['beta', 'alpha', 'gamma']);

    final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields.map((f) => f.controller!.text), ['beta', 'alpha', 'gamma']);
  });

  testWidgets('removing a middle row keeps the rest aligned', (tester) async {
    List<String> latest = [];
    await pumpEditor(tester, ['one', 'two', 'three'], (v) => latest = v);

    await tester.tap(
      find.widgetWithIcon(IconButton, Icons.close).at(1),
    );
    await tester.pumpAndSettle();

    expect(latest, ['one', 'three']);
    final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields.map((f) => f.controller!.text), ['one', 'three']);
  });

  testWidgets('typing in a row emits the edit', (tester) async {
    List<String> latest = [];
    await pumpEditor(tester, ['x'], (v) => latest = v);

    await tester.enterText(find.byType(TextField).first, 'xyz');
    await tester.pump();

    expect(latest, ['xyz']);
  });
}
