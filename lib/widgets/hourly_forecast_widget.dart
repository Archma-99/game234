import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<Weather> hourlyForecast;

  const HourlyForecastWidget({Key? key, required this.hourlyForecast}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hourly Forecast', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyForecast.length > 12 ? 12 : hourlyForecast.length,
            itemBuilder: (context, index) {
              final item = hourlyForecast[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      DateFormat('h a').format(item.date!),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Icon(_getIconForCondition(item.weatherMain), size: 40, color: Colors.grey[800]),
                    Text(
                      '${item.temperature?.celsius?.toStringAsFixed(0)}°',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
