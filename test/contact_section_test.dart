import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumate/models/contact_info.dart';
import 'package:resumate/ui/resume_editor/contact_section.dart';

/// `contact_section.dart` is shared by the resume editor, the letter editor
/// and the settings screen, so a bug here would surface in all three. It's a
/// plain `StatelessWidget` over a callback, so no store/provider is needed.
void main() {
  Widget harness(ContactInfo contact, ValueChanged<ContactInfo> onChanged) =>
      MaterialApp(
        home: Scaffold(
          body: ContactSection(contact: contact, onChanged: onChanged),
        ),
      );

  testWidgets('shows the contact fields pre-filled from the model', (
    tester,
  ) async {
    const contact = ContactInfo(
      name: 'Alex Doe',
      title: 'Software Engineer',
      email: 'alex@example.com',
    );

    await tester.pumpWidget(harness(contact, (_) {}));

    expect(find.widgetWithText(TextFormField, 'Full name'), findsOneWidget);
    expect(find.text('Alex Doe'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);
  });

  testWidgets('editing a field reports a copy with only that field changed', (
    tester,
  ) async {
    const contact = ContactInfo(name: 'Alex Doe', phone: '555-0100');
    ContactInfo? updated;

    await tester.pumpWidget(harness(contact, (c) => updated = c));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone'),
      '555-0199',
    );

    expect(updated, isNotNull);
    expect(updated!.phone, '555-0199');
    expect(updated!.name, 'Alex Doe'); // untouched fields survive copyWith
  });

  testWidgets('editing the GitHub URL does not touch the GitHub label', (
    tester,
  ) async {
    const contact = ContactInfo(githubUrl: 'old', githubLabel: 'GitHub');
    ContactInfo? updated;

    await tester.pumpWidget(harness(contact, (c) => updated = c));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'GitHub URL'),
      'https://github.com/alex',
    );

    expect(updated!.githubUrl, 'https://github.com/alex');
    expect(updated!.githubLabel, 'GitHub');
  });
}
