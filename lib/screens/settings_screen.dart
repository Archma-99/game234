import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // To access the global settingsService instance
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _tempUnit;
  late String _windSpeedFormat;
  late String _appTheme;
  late bool _dailyForecastNotification;
  late bool _severeAlertsNotification;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _tempUnit = settingsService.temperatureUnit;
      _windSpeedFormat = settingsService.windSpeedUnit;
      _appTheme = settingsService.theme;
      _dailyForecastNotification = settingsService.dailyNotifications;
      _severeAlertsNotification = settingsService.severeNotifications;
    });
  }

  void _showTemperatureUnitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Temperature Unit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Celsius (°C)'),
                value: 'Celsius',
                groupValue: _tempUnit,
                onChanged: (value) {
                  if (value != null) {
                    settingsService.setTemperatureUnit(value);
                    _loadSettings();
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Fahrenheit (°F)'),
                value: 'Fahrenheit',
                groupValue: _tempUnit,
                onChanged: (value) {
                  if (value != null) {
                    settingsService.setTemperatureUnit(value);
                    _loadSettings();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select App Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('System'),
                value: 'System',
                groupValue: _appTheme,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setTheme(value);
                    _loadSettings();
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Light'),
                value: 'Light',
                groupValue: _appTheme,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setTheme(value);
                    _loadSettings();
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Dark'),
                value: 'Dark',
                groupValue: _appTheme,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setTheme(value);
                    _loadSettings();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildSectionHeader("General"),
          _buildSettingRow("Temperature Unit", _tempUnit, _showTemperatureUnitDialog),
          _buildSettingRow("Wind Speed Format", _windSpeedFormat, _showWindSpeedUnitDialog),
          _buildSettingRow("Language", "English (Not implemented)", () {}),
          _buildSettingRow("App Theme", _appTheme, _showThemeDialog),
          const SizedBox(height: 16),
          _buildSectionHeader("Notifications"),
          _buildSwitchSettingRow("Daily Forecast", "Receive daily weather updates", _dailyForecastNotification, (value) {
            settingsService.setDailyNotifications(value);
            _loadSettings();
          }),
          _buildSwitchSettingRow("Severe Weather Alerts", "Get alerts for severe weather changes", _severeAlertsNotification, (value) {
            settingsService.setSevereNotifications(value);
            _loadSettings();
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  void _showWindSpeedUnitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Wind Speed Unit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('km/h'),
                value: 'km/h',
                groupValue: _windSpeedFormat,
                onChanged: (value) {
                  if (value != null) {
                    settingsService.setWindSpeedUnit(value);
                    _loadSettings();
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('m/s'),
                value: 'm/s',
                groupValue: _windSpeedFormat,
                onChanged: (value) {
                  if (value != null) {
                    settingsService.setWindSpeedUnit(value);
                    _loadSettings();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingRow(String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSettingRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: Colors.blue),
    );
  }
}
