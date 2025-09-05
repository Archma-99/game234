import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../services/gemini_service.dart';
import '../widgets/charts/daily_temperature_chart.dart';
import '../widgets/charts/rain_chance_chart.dart';
import '../widgets/charts/temperature_chart.dart';
import '../widgets/charts/uv_index_gauge.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Predictions', style: theme.textTheme.titleMedium),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: theme.iconTheme.color),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSegmentedControl(theme),
            const SizedBox(height: 24),
            _buildChartView(theme),
            const SizedBox(height: 24),
            _buildWeatherAiCard(theme),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ),
    );
  }

  Widget _buildSegmentedControl(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSegment("Hourly", 0, theme),
          _buildSegment("Daily", 1, theme),
          _buildSegment("Weekly", 2, theme),
        ],
      ),
    );
  }

  Widget _buildSegment(String text, int index, ThemeData theme) {
    bool isSelected = _selectedSegment == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedSegment = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: isSelected
              ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), spreadRadius: 1, blurRadius: 5)]
              : [],
        ),
        child: Text(text, style: TextStyle(
          color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
          fontWeight: FontWeight.w600,
        )),
      ),
    );
  }

  IconData _getIconForCondition(String? condition) {
    if (condition == null) return Icons.wb_sunny;
    switch (condition.toLowerCase()) {
      case 'rain': return Icons.water_drop;
      case 'clear': return Icons.wb_sunny;
      case 'clouds': return Icons.wb_cloudy;
      case 'thunderstorm': return Icons.thunderstorm;
      case 'snow': return Icons.ac_unit;
      case 'drizzle': return Icons.grain;
      default: return Icons.wb_sunny;
    }
  }

  Widget _buildChartView(ThemeData theme) {
    if (_selectedSegment == 0) { // Hourly View
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Temperature', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          TemperatureChart(hourlyForecast: widget.hourlyForecast, screenWidth: MediaQuery.of(context).size.width),
          const SizedBox(height: 24),
          Text('Precipitation (mm/h)', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          RainChanceChart(hourlyForecast: widget.hourlyForecast),
          const SizedBox(height: 24),
          UvIndexGauge(uvIndex: widget.weather.uvIndex ?? 0.0),
        ],
      );
    } else if (_selectedSegment == 1) { // Daily View
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next 5 Days Temperature', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          DailyTemperatureChart(dailyForecast: widget.dailyForecast, screenWidth: MediaQuery.of(context).size.width),
        ],
      );
    } else { // Weekly View
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
                  Expanded(flex: 2, child: Text(DateFormat('EEEE').format(day.date!), style: theme.textTheme.titleMedium)),
                  Expanded(flex: 1, child: Icon(_getIconForCondition(day.weatherMain), color: theme.colorScheme.primary)),
                  Expanded(flex: 2, child: Text(
                    '${day.tempMax?.celsius?.toStringAsFixed(0) ?? ''}° / ${day.tempMin?.celsius?.toStringAsFixed(0) ?? ''}°',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.titleMedium,
                  )),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildWeatherAiCard(ThemeData theme) {
    if (_isFetchingAdvice) {
      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 2.0)));
    }
    if (_multiDayAdvice.isEmpty || _multiDayAdvice.contains("Could not")) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.colorScheme.surface),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weather AI', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(_multiDayAdvice, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
