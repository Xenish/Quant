import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';

class SettingsService {
  static const String _baseUrlKey = 'base_url';

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? AppConfig.defaultBaseUrl;
  }

  Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }
}
