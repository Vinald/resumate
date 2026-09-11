import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/document_repository.dart';
import 'data/document_store.dart';
import 'data/settings_repository.dart';
import 'data/settings_store.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final documentStore = DocumentStore(DocumentRepository())..load();
  final settingsStore = SettingsStore(SettingsRepository())..load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: documentStore),
        ChangeNotifierProvider.value(value: settingsStore),
      ],
      child: const ResumateApp(),
    ),
  );
}
