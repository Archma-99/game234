import 'package:shared_preferences/shared_preferences.dart';

// Note: This service requires the 'shared_preferences' package.
// Add `shared_preferences: ^2.0.15` (or a newer version) to your pubspec.yaml.

class SettingsService {
  late SharedPreferences _prefs;

  // Keys for storage
  static const String _tempUnitKey = 'temp_unit';
  static const String _windSpeedUnitKey = 'wind_speed_unit';
  static const String _themeKey = 'theme';
  static const String _dailyNotificationKey = 'daily_notification';
  static const String _severeNotificationKey = 'severe_notification';

  // Default values
  String _temperatureUnit = 'Celsius';
  String _windSpeedUnit = 'km/h';
  String _theme = 'System';
  bool _dailyNotifications = true;
  bool _severeNotifications = true;

  // Getters
  String get temperatureUnit => _temperatureUnit;
  String get windSpeedUnit => _windSpeedUnit;
  String get theme => _theme;
  bool get dailyNotifications => _dailyNotifications;
  bool get severeNotifications => _severeNotifications;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _temperatureUnit = _prefs.getString(_tempUnitKey) ?? 'Celsius';
    _windSpeedUnit = _prefs.getString(_windSpeedUnitKey) ?? 'km/h';
    _theme = _prefs.getString(_themeKey) ?? 'System';
    _dailyNotifications = _prefs.getBool(_dailyNotificationKey) ?? true;
    _severeNotifications = _prefs.getBool(_severeNotificationKey) ?? true;
  }

  Future<void> setTemperatureUnit(String unit) async {
    _temperatureUnit = unit;
    await _prefs.setString(_tempUnitKey, unit);
  }

  Future<void> setWindSpeedUnit(String unit) async {
    _windSpeedUnit = unit;
    await _prefs.setString(_windSpeedUnitKey, unit);
  }

  Future<void> setTheme(String theme) async {
    _theme = theme;
    await _prefs.setString(_themeKey, theme);
  }

  Future<void> setDailyNotifications(bool value) async {
    _dailyNotifications = value;
    await _prefs.setBool(_dailyNotificationKey, value);
  }

  Future<void> setSevereNotifications(bool value) async {
    _severeNotifications = value;
    await _prefs.setBool(_severeNotificationKey, value);
  }
}
