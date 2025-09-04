import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather/weather.dart'; // Note: Add weather: ^3.2.1 to pubspec.yaml

import '../main.dart'; // To access global settingsService
import '../services/gemini_service.dart';
import '../services/notification_service.dart';
import '../services/weather_service.dart';
import '../widgets/forecast_list.dart';
import 'forecast_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _searchController = TextEditingController();

  Weather? _weather;
  List<Weather> _forecast = [];
  List<Weather> _hourlyForecast = [];
  String _aiAdvice = '';
  bool _isLoading = true;
  bool _isFetchingAdvice = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather("Tokyo");
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather(String cityName) async {
    if (cityName.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _aiAdvice = '';
    });
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _weatherService.getCurrentWeather(cityName),
        _weatherService.getFiveDayForecast(cityName),
      ]);

      final newWeather = results[0] as Weather;
      final newForecast = results[1] as List<Weather>;

      setState(() {
        _weather = newWeather;
        _forecast = newForecast;
        // The 5-day forecast from the package is also the hourly forecast
        _hourlyForecast = newForecast;
        _isLoading = false;
        _isFetchingAdvice = true;
      });

      // AI Advice and Notifications
      if (settingsService.dailyNotifications) {
        final advice = await _geminiService.getWeatherAdvice(newWeather);
        if (advice.isNotEmpty && !advice.contains("Could not")) {
          await NotificationService.showWeatherAdvice('Weather Tip!', advice);
        }
        setState(() => _aiAdvice = advice);
      } else {
        setState(() => _aiAdvice = '');
      }

      // The `weather` package does not support severe weather alerts directly.
      // This functionality is lost in the refactor.

      setState(() => _isFetchingAdvice = false);

    } catch (e) {
      setState(() {
        _errorMessage = "Could not find weather for '$cityName'.";
        _isLoading = false;
        _isFetchingAdvice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildTopBar(),
              SizedBox(height: 24),
              _buildSearchBar(),
              SizedBox(height: 24),
              Expanded(
                child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 16)))
                      : _buildWeatherView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.grey[700]),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ).then((_) {
              if (_weather?.areaName != null) {
                _fetchWeather(_weather!.areaName!);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search for a city',
        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
      ),
      onSubmitted: (value) {
        _fetchWeather(value);
        _searchController.clear();
      },
    );
  }

  Widget _buildWeatherView() {
    if (_weather == null) return SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _weather!.areaName ?? '',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              ),
              SizedBox(height: 4),
              Text(
                'Chance of rain: ${(_forecast.first.rain ?? 0).toStringAsFixed(0)} mm/h',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
              SizedBox(height: 16),
              Text(
                '${_getFormattedTemperature()}°${settingsService.temperatureUnit == 'Celsius' ? 'C' : 'F'}',
                style: TextStyle(fontSize: 96, fontWeight: FontWeight.w300, color: Colors.grey[800]),
              ),
              Image.network(
                'https://openweathermap.org/img/wn/${_weather!.weatherIcon}@4x.png',
                width: 128,
                height: 128,
                errorBuilder: (c, o, s) => Icon(Icons.wb_cloudy, size: 128, color: Colors.grey[400]),
              ),
              SizedBox(height: 8),
              Text(
                _weather!.weatherMain ?? '',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.grey[800]),
              ),
              SizedBox(height: 8),
              Text(
                'Wind: ${_weather!.windSpeed?.toStringAsFixed(1)} m/s',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
              SizedBox(height: 16),
              _buildAiAdviceCard(),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
        ),
        if (_forecast.isNotEmpty)
          GestureDetector(
            onTap: () {
              if (_weather != null && _forecast.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForecastScreen(
                      weather: _weather!,
                      dailyForecast: _forecast,
                      hourlyForecast: _hourlyForecast,
                    ),
                  ),
                );
              }
            },
            child: ForecastList(forecast: _forecast),
          ),
      ],
    );
  }

  String _getFormattedTemperature() {
    if (_weather == null) return '';
    if (settingsService.temperatureUnit == 'Celsius') {
      return _weather!.temperature!.celsius!.toStringAsFixed(0);
    } else {
      return _weather!.temperature!.fahrenheit!.toStringAsFixed(0);
    }
  }

  Widget _buildAiAdviceCard() {
    if (_isFetchingAdvice) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.grey[400])),
      );
    }
    if (_aiAdvice.isEmpty || _aiAdvice.contains("Could not")) return SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue[100]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Center(
        child: Text(_aiAdvice, textAlign: TextAlign.center, style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500, fontSize: 14)),
      ),
    );
  }
}
