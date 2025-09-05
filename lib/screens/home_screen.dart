import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather/weather.dart';

import '../main.dart'; // To access global settingsService
import '../services/gemini_service.dart';
import '../services/notification_service.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../widgets/forecast_list.dart';
import 'forecast_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final GeminiService _geminiService = GeminiService();
  final LocationService _locationService = LocationService();
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
    _determinePositionAndFetchWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePositionAndFetchWeather() async {
    try {
      final position = await _locationService.getCurrentPosition();
      _fetchWeatherByCoord(position.latitude, position.longitude);
    } catch (e) {
      _fetchWeatherByCity("Tokyo");
    }
  }

  Future<void> _fetchWeatherByCoord(double lat, double lon) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _aiAdvice = '';
    });
    try {
      final results = await Future.wait([
        _weatherService.getCurrentWeatherByCoord(lat, lon),
        _weatherService.getFiveDayForecastByCoord(lat, lon),
      ]);
      _updateWeatherState(results[0] as Weather, results[1] as List<Weather>);
    } catch (e) {
      setState(() {
        _errorMessage = "Could not fetch weather for your location.";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherByCity(String cityName) async {
    if (cityName.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _aiAdvice = '';
    });
    try {
      final results = await Future.wait([
        _weatherService.getCurrentWeather(cityName),
        _weatherService.getFiveDayForecast(cityName),
      ]);
      _updateWeatherState(results[0] as Weather, results[1] as List<Weather>);
    } catch (e) {
      setState(() {
        _errorMessage = "Could not find weather for '$cityName'.";
        _isLoading = false;
      });
    }
  }

  Future<void> _updateWeatherState(Weather newWeather, List<Weather> newForecast) async {
    setState(() {
      _weather = newWeather;
      _forecast = newForecast;
      _hourlyForecast = newForecast;
      _isLoading = false;
      _isFetchingAdvice = true;
    });

    if (settingsService.dailyNotifications) {
      final advice = await _geminiService.getWeatherAdvice(newWeather);
      if (advice.isNotEmpty && !advice.contains("Could not")) {
        await NotificationService.showWeatherAdvice('Weather Tip!', advice);
      }
      if (mounted) setState(() => _aiAdvice = advice);
    } else {
      if (mounted) setState(() => _aiAdvice = '');
    }

    if (mounted) setState(() => _isFetchingAdvice = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16)))
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
          icon: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((_) {
              if (_weather?.areaName != null) {
                _fetchWeatherByCity(_weather!.areaName!);
              } else {
                _determinePositionAndFetchWeather();
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
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: Theme.of(context).inputDecorationTheme.copyWith(
        hintText: 'Search for a city',
      ),
      onSubmitted: (value) {
        _fetchWeatherByCity(value);
        _searchController.clear();
      },
    );
  }

  Widget _buildWeatherView() {
    if (_weather == null) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Flexible(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_weather!.areaName ?? 'Your Location', style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Rain last hour: ${(_forecast.first.rainLastHour ?? 0).toStringAsFixed(2)} mm',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  double fontSize = constraints.maxHeight * 0.5;
                  if (fontSize < 20) fontSize = 20;
                  if (fontSize > 96) fontSize = 96;
                  return Text(
                    '${_getFormattedTemperature()}°${settingsService.temperatureUnit == 'Celsius' ? 'C' : 'F'}',
                    style: textTheme.headlineLarge?.copyWith(fontSize: fontSize),
                  );
                }
              ),
              Image.network(
                'https://openweathermap.org/img/wn/${_weather!.weatherIcon}@4x.png',
                width: 100,
                height: 100,
                errorBuilder: (c, o, s) => Icon(Icons.wb_cloudy, size: 100, color: textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 8),
              Text(_weather!.weatherMain ?? '', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Wind: ${_weather!.windSpeed?.toStringAsFixed(1)} m/s', style: textTheme.bodyMedium),
              const SizedBox(height: 16),
              _buildAiAdviceCard(),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
        ),
        Flexible(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
          ),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0)),
      );
    }
    if (_aiAdvice.isEmpty || _aiAdvice.contains("Could not")) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          _aiAdvice,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
    );
  }
}
