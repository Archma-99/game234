import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Note: Add flutter_animate to pubspec.yaml
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';

class ForecastList extends StatelessWidget {
  final List<Forecast> forecast;

  ForecastList({required this.forecast});

  IconData _getIconForCondition(String condition) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '6-Day Forecast',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 100, // Constrain the height of the GridView
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: forecast.length > 6 ? 6 : forecast.length,
            itemBuilder: (context, index) {
              final dayForecast = forecast[index];
              return _ForecastCard(
                day: DateFormat('EEE').format(dayForecast.date),
                icon: _getIconForCondition(dayForecast.mainCondition),
                temperature: dayForecast.tempMax.toStringAsFixed(0) + '°',
                isHighlighted: index == 1, // Highlight Tuesday
              ).animate().fadeIn(delay: (index * 100).ms).moveY(begin: 20, end: 0);
            },
          ),
        ),
      ],
    ).animate().slideY(begin: 0.5, end: 0, duration: 500.ms, delay: 400.ms);
  }
}

class _ForecastCard extends StatelessWidget {
  final String day;
  final IconData icon;
  final String temperature;
  final bool isHighlighted;

  const _ForecastCard({
    required this.day,
    required this.icon,
    required this.temperature,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blue[500] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: isHighlighted
            ? [BoxShadow(color: Colors.blue.withOpacity(0.3), spreadRadius: 1, blurRadius: 5)]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isHighlighted ? Colors.white : Colors.grey[700],
            ),
          ),
          Icon(
            icon,
            color: isHighlighted ? Colors.white : Colors.blue[500],
            size: 24,
          ),
          Text(
            temperature,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isHighlighted ? Colors.white : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
