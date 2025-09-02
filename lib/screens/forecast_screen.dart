import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import '../widgets/charts/temperature_chart.dart';
import '../widgets/charts/rain_chance_chart.dart';
import '../widgets/charts/uv_index_gauge.dart';
import '../widgets/charts/daily_temperature_chart.dart';
import '../services/gemini_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class ForecastScreen extends StatefulWidget {
  final Weather weather;
  final List<Weather> dailyForecast;
  final List<Weather> hourlyForecast;

  const ForecastScreen({
    Key? key,
    required this.weather,
    required this.dailyForecast,
    required this.hourlyForecast,
  }) : super(key: key);

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  int _selectedSegment = 0; // 0: Hourly, 1: Daily, 2: Weekly
  String _multiDayAdvice = '';
  bool _isFetchingAdvice = true;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _fetchMultiDayAdvice();
  }

  Future<void> _fetchMultiDayAdvice() async {
    final advice = await _geminiService.getMultiDayAdvice(widget.dailyForecast);
    if (mounted) {
      setState(() {
        _multiDayAdvice = advice;
        _isFetchingAdvice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Predictions',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.grey[800]),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSegmentedControl(),
            SizedBox(height: 24),
            _buildChartView(),
            SizedBox(height: 24),
            _buildWeatherAiCard(),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSegment("Hourly", 0),
          _buildSegment("Daily", 1),
          _buildSegment("Weekly", 2),
        ],
      ),
    );
  }

  Widget _buildSegment(String text, int index) {
    bool isSelected = _selectedSegment == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSegment = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[500] : Colors.transparent,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.blue.withOpacity(0.3), spreadRadius: 1, blurRadius: 5)]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  IconData _getIconForCondition(String? condition) {
    if (condition == null) return Icons.wb_sunny;
    switch (condition.toLowerCase()) {
      case 'rain':
        return Icons.water_drop;
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.wb_cloudy;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
        return Icons.ac_unit;
      case 'drizzle':
        return Icons.grain;
      default:
        return Icons.wb_sunny;
    }
  }

  Widget _buildChartView() {
    if (_selectedSegment == 0) { // Hourly View
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Temperature', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          SizedBox(height: 8),
          TemperatureChart(hourlyForecast: widget.hourlyForecast),
          SizedBox(height: 24),
          Text('Chance of Rain', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          SizedBox(height: 8),
          RainChanceChart(hourlyForecast: widget.hourlyForecast),
          SizedBox(height: 24),
          UvIndexGauge(uvIndex: widget.weather.uvi ?? 0.0),
        ],
      );
    } else if (_selectedSegment == 1) { // Daily View
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next 6 Days Temperature (°C)', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          SizedBox(height: 8),
          DailyTemperatureChart(dailyForecast: widget.dailyForecast),
        ],
      );
    } else { // Weekly View
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.dailyForecast.length,
        itemBuilder: (context, index) {
          final day = widget.dailyForecast[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      DateFormat('EEEE').format(day.date!),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Icon(_getIconForCondition(day.weatherMain), color: Colors.blue[500]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${day.tempMax?.celsius?.toStringAsFixed(0) ?? ''}° / ${day.tempMin?.celsius?.toStringAsFixed(0) ?? ''}°',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildWeatherAiCard() {
    if (_isFetchingAdvice) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularProgressIndicator(strokeWidth: 2.0),
      ));
    }
    if (_multiDayAdvice.isEmpty || _multiDayAdvice.contains("Could not")) {
      return SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.blue[500]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather AI',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                SizedBox(height: 4),
                Text(
                  _multiDayAdvice,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
