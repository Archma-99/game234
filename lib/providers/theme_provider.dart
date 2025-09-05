import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class ThemeProvider with ChangeNotifier {
  final SettingsService _settingsService;
  late ThemeMode _themeMode;

  ThemeProvider(this._settingsService) {
    _themeMode = _getThemeModeFromString(_settingsService.theme);
  }

  ThemeMode get themeMode => _themeMode;

  void setTheme(String theme) {
    _settingsService.setTheme(theme);
    _themeMode = _getThemeModeFromString(theme);
    notifyListeners();
  }

  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
