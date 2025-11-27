import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../data/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

class BaseUrlNotifier extends StateNotifier<String> {
  final SettingsService _service;

  BaseUrlNotifier(this._service) : super(AppConfig.defaultBaseUrl) {
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final url = await _service.getBaseUrl();
    state = url;
  }

  Future<void> updateUrl(String newUrl) async {
    var url = newUrl.trim();
    if (url.isEmpty) {
      return;
    }
    if (!url.startsWith('http')) {
      url = 'http://$url';
    }
    await _service.saveBaseUrl(url);
    state = url;
  }
}

final baseUrlProvider = StateNotifierProvider<BaseUrlNotifier, String>((ref) {
  return BaseUrlNotifier(ref.watch(settingsServiceProvider));
});
