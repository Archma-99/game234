import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<Weather> dailyForecast;

  const DailyForecastWidget({Key? key, required this.dailyForecast}) : super(key: key);

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
    final Map<int, Weather> dailySummaries = {};
    for (var f in dailyForecast) {
      if (!dailySummaries.containsKey(f.date?.day)) {
        dailySummaries[f.date!.day] = f;
      }
    }
    final dailyList = dailySummaries.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('7-Day Forecast', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyList.length > 7 ? 7 : dailyList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = dailyList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        DateFormat('EEEE').format(item.date!),
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Icon(_getIconForCondition(item.weatherMain), color: Colors.grey[800]),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${item.tempMin?.celsius?.toStringAsFixed(0) ?? ''}°',
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${item.tempMax?.celsius?.toStringAsFixed(0) ?? ''}°',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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
