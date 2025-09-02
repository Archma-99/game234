import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../services/gemini_service.dart';
import '../services/notification_service.dart';
import '../widgets/forecast_list.dart';
// TODO: import 'package:intl/intl.dart'; // Add to pubspec.yaml for date formatting

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final GeminiService _geminiService = GeminiService();
  Weather? _weather;
  List<Forecast> _forecast = [];
  String _aiAdvice = '';
  bool _isLoading = true;
  bool _isFetchingAdvice = false;
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
      if (newForecast.isNotEmpty) {
        newForecast.removeAt(0);
      }

      setState(() {
        _weather = newWeather;
        _forecast = newForecast;
        _isLoading = false;
        _isFetchingAdvice = true;
      });

      // Fetch AI advice
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
        _errorMessage = "Failed to fetch weather data for $cityName. Please try again.";
        _isLoading = false;
        _isFetchingAdvice = false;
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

            // AI Advice Section
            _buildAiAdviceCard(),

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

  Widget _buildAiAdviceCard() {
    if (_isFetchingAdvice) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
            ),
            SizedBox(width: 10),
            Text("Getting AI advice...", style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_aiAdvice.isEmpty || _aiAdvice.contains("Could not")) {
      return SizedBox.shrink(); // Don't show anything if there's no advice or an error
    }

    return Card(
      color: Colors.white.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _aiAdvice,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
