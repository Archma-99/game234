import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/gemini_service.dart';
import '../services/notification_service.dart';
import '../widgets/forecast_list.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Note: Add flutter_animate to pubspec.yaml

// TODO: import 'package:intl/intl.dart'; // Add to pubspec.yaml for date formatting

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _searchController = TextEditingController();

  Weather? _weather;
  List<Forecast> _forecast = [];
  double _chanceOfRain = 0.0;
  String _aiAdvice = '';
  bool _isLoading = true;
  bool _isFetchingAdvice = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather("Tokyo"); // Default city from new design
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
      final coordinates = await _apiService.getCoordinates(cityName);
      final lat = coordinates['lat']!;
      final lon = coordinates['lon']!;
      final weatherData = await _apiService.getWeatherData(lat, lon);
      final newWeather = Weather.fromJson(weatherData['current'], cityName);
      final dailyData = weatherData['daily'] as List;
      final newForecast = dailyData.map((d) => Forecast.fromJson(d)).toList();
      final chanceOfRain = (dailyData[0]['pop'] as num).toDouble();
      if (newForecast.isNotEmpty) newForecast.removeAt(0);

      setState(() {
        _weather = newWeather;
        _forecast = newForecast;
        _chanceOfRain = chanceOfRain;
        _isLoading = false;
        _isFetchingAdvice = true;
      });

      final advice = await _geminiService.getWeatherAdvice(newWeather);
      if (advice.isNotEmpty && !advice.contains("Could not")) {
        await NotificationService.showWeatherAdvice('Weather Tip!', advice);
      }
      setState(() {
        _aiAdvice = advice;
        _isFetchingAdvice = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = "Could not find weather for '$cityName'. Please try another city.";
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('10:24', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
        Row(
          children: [
            Icon(Icons.signal_cellular_alt, size: 20, color: Colors.grey[700]),
            SizedBox(width: 4),
            Icon(Icons.wifi, size: 20, color: Colors.grey[700]),
            SizedBox(width: 4),
            Icon(Icons.battery_full, size: 20, color: Colors.grey[700]),
          ],
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _weather!.cityName,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              ),
              SizedBox(height: 4),
              Text(
                'Chance of rain: ${(_chanceOfRain * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
              SizedBox(height: 16),
              Text(
                '${_weather!.temperature.toStringAsFixed(0)}°',
                style: TextStyle(fontSize: 96, fontWeight: FontWeight.w300, color: Colors.grey[800]),
              ),
              Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuD-1YfI3h3Tsd9qg6tP5sXk-UjL-R3Vw4j3K3a2O3R2b6m3N5l8Y7c4D9h7A8r2T1k7l3o5W8x0s4r4v9p9z9g3a9f0b8d7c6e5a4b3c2d1',
                width: 128,
                height: 128,
                errorBuilder: (c, o, s) => Icon(Icons.wb_cloudy, size: 128, color: Colors.grey[400]),
              ),
              SizedBox(height: 8),
              Text(
                _weather!.mainCondition,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.grey[800]),
              ),
              SizedBox(height: 16),
              _buildAiAdviceCard(),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
        ),
        if (_forecast.isNotEmpty) ForecastList(forecast: _forecast),
      ],
    );
  }

  Widget _buildAiAdviceCard() {
    if (_isFetchingAdvice) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.grey[400]),
        ),
      );
    }
    if (_aiAdvice.isEmpty || _aiAdvice.contains("Could not")) {
      return SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue[100]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Center(
        child: Text(
          _aiAdvice,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
