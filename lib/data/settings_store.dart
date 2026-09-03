import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import 'settings_repository.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore(this._repo);

  final SettingsRepository _repo;
  AppSettings _settings = AppSettings();
  bool _loading = true;

  AppSettings get settings => _settings;
  bool get loading => _loading;

  Future<void> load() async {
    _settings = await _repo.load();
    _loading = false;
    notifyListeners();
  }

  Future<void> update(AppSettings settings) async {
    _settings = settings;
    await _repo.save(settings);
    notifyListeners();
  }
}
