import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resumate/data/settings_repository.dart';
import 'package:resumate/data/settings_store.dart';
import 'package:resumate/models/app_settings.dart';
import 'package:resumate/ui/settings/settings_screen.dart';

/// Real `dart:io` setup happens in `setUp()`, not inside a `testWidgets`
/// body — see `test/home_screen_tutorial_test.dart`'s header comment for why.
///
/// `SettingsStore.update` notifies listeners synchronously and only
/// *debounces* the disk write behind a `Timer` (see settings_store.dart), so
/// unlike the editor screens' save flow, interactions here don't need
/// `runAsync` — but a test that edits a field must still pump forward past
/// the ~400ms debounce (or dispose the store) before it ends, or
/// `flutter_test` fails it for a still-pending `Timer`.
///
/// The settings page is taller than the default 800x600 test surface, so
/// every test enlarges it — simpler and more robust than scrolling a
/// `ListView` that also contains several `TextFormField`s (each with its own
/// internal horizontal `Scrollable`, which trips up `scrollUntilVisible`'s
/// default "find the one Scrollable" behaviour).
void main() {
  late Directory tempDir;
  late SettingsStore settingsStore;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resumate_settings_test');
    settingsStore = SettingsStore(SettingsRepository(baseDir: tempDir));
    await settingsStore.load();
  });

  tearDown(() async {
    settingsStore.dispose(); // cancels any pending debounce Timer
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Widget harness() => ChangeNotifierProvider.value(
    value: settingsStore,
    child: const MaterialApp(home: SettingsScreen()),
  );

  Future<void> pumpSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
  }

  testWidgets('renders the contact, style and signature sections', (
    tester,
  ) async {
    await pumpSettings(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.text('Style'), findsOneWidget);
    expect(find.text('Signature'), findsOneWidget);
    expect(find.text('Accent colour'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<BodyFont>), findsOneWidget);
  });

  testWidgets('changing the body font dropdown updates the store', (
    tester,
  ) async {
    await pumpSettings(tester);

    expect(settingsStore.settings.bodyFont, BodyFont.ebGaramond);

    await tester.tap(find.byType(DropdownButtonFormField<BodyFont>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Helvetica').last);
    await tester.pumpAndSettle();

    expect(settingsStore.settings.bodyFont, BodyFont.helvetica);
  });

  testWidgets('dragging the margin slider updates the store', (tester) async {
    await pumpSettings(tester);

    final initial = settingsStore.settings.marginInches;
    final slider = find.byType(Slider).first;

    await tester.drag(slider, const Offset(80, 0));
    // Advance past SettingsStore's ~400ms save debounce Timer (see above).
    await tester.pump(const Duration(milliseconds: 500));

    expect(settingsStore.settings.marginInches, isNot(initial));
  });

  testWidgets('editing the default contact name updates the store', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Jordan Lee',
    );
    // Advance past SettingsStore's ~400ms save debounce so its Timer fires
    // (and is no longer "pending") before the test ends — see settings_store.dart.
    await tester.pump(const Duration(milliseconds: 500));

    expect(settingsStore.settings.defaultContact.name, 'Jordan Lee');
  });
}
