import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import 'settings_repository.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore(this._repo);

  final SettingsRepository _repo;
  AppSettings _settings = AppSettings();
  bool _loading = true;
  Timer? _saveDebounce;

  AppSettings get settings => _settings;
  bool get loading => _loading;

  Future<void> load() async {
    try {
      _settings = await _repo.load();
    } catch (e) {
      debugPrint('SettingsStore: using defaults ($e)');
      _settings = AppSettings();
    }
    _loading = false;
    notifyListeners();
  }

  /// Updates the in-memory settings (and notifies listeners) synchronously,
  /// but debounces the actual disk write: dragging a slider or typing in a
  /// text field previously fired one `settings.json` write per frame /
  /// keystroke. The trade-off is that the very last edit before a hard kill
  /// (rather than a normal app close) can be lost — acceptable for
  /// preferences that aren't safety-critical.
  Future<void> update(AppSettings settings) async {
    _settings = settings;
    notifyListeners();

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        await _repo.save(_settings);
      } catch (e) {
        debugPrint('SettingsStore: save skipped ($e)');
      }
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }
}
