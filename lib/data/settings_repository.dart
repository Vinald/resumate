import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/app_settings.dart';

/// Reads / writes [AppSettings] as a single `settings.json` file.
class SettingsRepository {
  SettingsRepository({Directory? baseDir}) : _injectedBase = baseDir;

  final Directory? _injectedBase;

  Future<File> _file() async {
    final base = _injectedBase ?? await getApplicationDocumentsDirectory();
    return File('${base.path}/settings.json');
  }

  Future<AppSettings> load() async {
    final file = await _file();
    if (!await file.exists()) return AppSettings();
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (_) {
      return AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    final file = await _file();
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(settings.toJson()),
    );
  }
}
