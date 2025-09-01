import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../widgets/forecast_list.dart';
// TODO: import 'package:intl/intl.dart'; // Add to pubspec.yaml for date formatting

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  Weather? _weather;
  List<Forecast> _forecast = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather("London"); // Default city
  }

  Future<void> _fetchWeather(String cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final coordinates = await _apiService.getCoordinates(cityName);
      final lat = coordinates['lat']!;
      final lon = coordinates['lon']!;

      final weatherData = await _apiService.getWeatherData(lat, lon);

      setState(() {
        _weather = Weather.fromJson(weatherData['current'], cityName);

        final dailyData = weatherData['daily'] as List;
        _forecast = dailyData.map((d) => Forecast.fromJson(d)).toList();
        // Remove the current day from the forecast
        if (_forecast.isNotEmpty) {
          _forecast.removeAt(0);
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to fetch weather data for $cityName. Please try again.";
        _isLoading = false;
      });
    }
  }

  Color _getBackgroundColor() {
    if (_weather == null) return Colors.lightBlue;
    switch (_weather!.mainCondition) {
      case 'Clear':
        return Colors.blue.shade300;
      case 'Clouds':
        return Colors.blueGrey.shade400;
      case 'Rain':
      case 'Drizzle':
      case 'Thunderstorm':
        return Colors.grey.shade600;
      case 'Snow':
        return Colors.lightBlue.shade100;
      case 'Mist':
        return Colors.grey.shade400;
      default:
        return Colors.lightBlue;
    }
  }

  void _navigateToSearchScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );

    if (result != null && result is String && result.isNotEmpty) {
      _fetchWeather(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _navigateToSearchScreen,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          color: _getBackgroundColor(),
          child: Center(
            child: _buildWeatherContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_isLoading) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else if (_errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_weather != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Current Weather Details
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _isLoading ? 0.0 : 1.0,
              child: Column(
                children: [
                  Text(
                    _weather!.cityName,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${_weather!.temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _weather!.mainCondition,
                    style: TextStyle(fontSize: 24, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Forecast Section
            if (_forecast.isNotEmpty)
              Column(
                children: [
                  Text(
                    '7-Day Forecast',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ForecastList(forecast: _forecast),
                ],
              ),
          ],
        ),
      );
    } else {
      return Text('No weather data.', style: TextStyle(color: Colors.white));
    }
  }
}
