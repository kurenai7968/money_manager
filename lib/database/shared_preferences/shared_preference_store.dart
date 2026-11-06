import 'package:flutter/foundation.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceManager {
  static final SharedPreferenceManager instance = SharedPreferenceManager._();
  SharedPreferenceStore? _store;

  SharedPreferenceManager._();

  SharedPreferenceStore get store {
    final store = _store;
    if (store == null) {
      throw const CacheException(
        'Shared preferences are not initialized. Call initialize() first.',
      );
    }
    return store;
  }

  Future<void> initialize() async {
    if (_store != null) return;
    _store = SharedPreferenceStore(await SharedPreferences.getInstance());
  }

  @visibleForTesting
  void reset() {
    _store = null;
  }
}

class SharedPreferenceStore {
  final SharedPreferences _preferences;

  SharedPreferenceStore(this._preferences);

  String? getString(String key) => _preferences.getString(key);

  Future<void> setString(String key, String value) async {
    final saved = await _preferences.setString(key, value);
    if (!saved) {
      throw CacheException('Could not write $key.');
    }
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }
}
