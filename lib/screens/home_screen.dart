import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

import '../main.dart'; // To access global settingsService
import '../services/gemini_service.dart';
import '../services/notification_service.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../widgets/daily_forecast_widget.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/weather_details_grid.dart';
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
      _fetchWeatherByCity("San Francisco");
    }
  }

  Future<void> _fetchWeatherByCoord(double lat, double lon) async {
    setState(() { _isLoading = true; _errorMessage = ''; _aiAdvice = ''; });
    try {
      final results = await Future.wait([
        _weatherService.getCurrentWeatherByCoord(lat, lon),
        _weatherService.getFiveDayForecastByCoord(lat, lon),
      ]);
      _updateWeatherState(results[0] as Weather, results[1] as List<Weather>);
    } catch (e) {
      setState(() { _errorMessage = "Could not fetch weather for your location."; _isLoading = false; });
    }
  }

  Future<void> _fetchWeatherByCity(String cityName) async {
    if (cityName.isEmpty) return;
    setState(() { _isLoading = true; _errorMessage = ''; _aiAdvice = ''; });
    try {
      final results = await Future.wait([
        _weatherService.getCurrentWeather(cityName),
        _weatherService.getFiveDayForecast(cityName),
      ]);
      _updateWeatherState(results[0] as Weather, results[1] as List<Weather>);
    } catch (e) {
      setState(() { _errorMessage = "Could not find weather for '$cityName'."; _isLoading = false; });
    }
  }

  Future<void> _updateWeatherState(Weather newWeather, List<Weather> newForecast) async {
    setState(() {
      _weather = newWeather;
      _forecast = newForecast;
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage, style: TextStyle(color: Theme.of(context).colorScheme.error)))
                : _buildWeatherContent(),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildCurrentWeatherCard(),
          const SizedBox(height: 24),
          _buildWeatherAdviceCard(),
          const SizedBox(height: 24),
          _buildHourlyForecast(),
          const SizedBox(height: 24),
          _buildDailyForecast(),
          const SizedBox(height: 24),
          _buildWeatherDetailsGrid(),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildHeader() {
    final now = _weather?.date ?? DateTime.now();
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 400;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weather?.areaName ?? 'Loading...',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('EEEE, h:mm a').format(now),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: isWide ? 0 : 16, width: isWide ? 16 : 0),
            SizedBox(
              width: isWide ? 250 : double.infinity,
              child: TextField(
                controller: _searchController,
                decoration: Theme.of(context).inputDecorationTheme.copyWith(
                  hintText: 'Search for a city...',
                  prefixIcon: const Icon(Icons.search),
                ),
                onSubmitted: _fetchWeatherByCity,
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForCondition(String? condition) {
    if (condition == null) return Icons.wb_sunny;
    switch (condition.toLowerCase()) {
      case 'rain': return Icons.grain;
      case 'clouds': return Icons.cloud;
      case 'clear': return Icons.wb_sunny;
      case 'thunderstorm': return Icons.thunderstorm;
      case 'snow': return Icons.cloudy_snowing;
      default: return Icons.wb_sunny;
    }
  }

  Widget _buildCurrentWeatherCard() {
    final temp = _weather?.temperature?.celsius?.toStringAsFixed(0) ?? 'N/A';
    final high = _weather?.tempMax?.celsius?.toStringAsFixed(0) ?? 'N/A';
    final low = _weather?.tempMin?.celsius?.toStringAsFixed(0) ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_getIconForCondition(_weather?.weatherMain), size: 80, color: Colors.white),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$temp°', style: const TextStyle(fontSize: 72, color: Colors.white, fontWeight: FontWeight.w200)),
              Text(_weather?.weatherMain ?? '', style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Row(children: [const Icon(Icons.trending_up, color: Colors.white70), const SizedBox(width: 4), Text('$high°', style: const TextStyle(color: Colors.white, fontSize: 20))]),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.trending_down, color: Colors.white70), const SizedBox(width: 4), Text('$low°', style: const TextStyle(color: Colors.white, fontSize: 20))]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAdviceCard() {
    if (_isFetchingAdvice) return const Center(child: CircularProgressIndicator());
    if (_aiAdvice.isEmpty || _aiAdvice.contains("Could not")) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(_aiAdvice, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return HourlyForecastWidget(hourlyForecast: _forecast);
  }

  Widget _buildDailyForecast() {
    return DailyForecastWidget(dailyForecast: _forecast);
  }

  Widget _buildWeatherDetailsGrid() {
    return WeatherDetailsGrid(weather: _weather!);
  }
}
