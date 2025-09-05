import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ForecastScreen extends StatelessWidget {
  final List<Weather> dailyForecast;

  const ForecastScreen({
    Key? key,
    required this.dailyForecast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Detailed Forecast', style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: _buildForecastGrid(),
    );
  }

  Widget _buildForecastGrid() {
    final Map<int, Weather> dailySummaries = {};
    for (var f in dailyForecast) {
      if (!dailySummaries.containsKey(f.date?.day)) {
        dailySummaries[f.date!.day] = f;
      }
    }
    final dailyList = dailySummaries.values.toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400.0,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 0.8,
      ),
      itemCount: dailyList.length > 7 ? 7 : dailyList.length,
      itemBuilder: (context, index) {
        return _DetailedForecastCard(forecast: dailyList[index])
            .animate()
            .fadeIn(delay: (100 * index).ms)
            .slideY(begin: 0.5, end: 0);
      },
    );
  }
}

class _DetailedForecastCard extends StatelessWidget {
  final Weather forecast;

  const _DetailedForecastCard({Key? key, required this.forecast}) : super(key: key);

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
    final theme = Theme.of(context);
    final highTemp = forecast.tempMax?.celsius?.toStringAsFixed(0) ?? 'N/A';
    final lowTemp = forecast.tempMin?.celsius?.toStringAsFixed(0) ?? 'N/A';

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(_getIconForCondition(forecast.weatherMain), size: 48, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('EEEE').format(forecast.date!), style: theme.textTheme.titleLarge),
                    Text(forecast.weatherMain ?? '', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTempColumn('High', '$highTemp°', theme),
                _buildTempColumn('Low', '$lowTemp°', theme),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(Icons.air, 'Wind', '${forecast.windSpeed?.toStringAsFixed(1) ?? 'N/A'} m/s', theme),
            _buildDetailRow(Icons.water_drop, 'Humidity', '${forecast.humidity?.toStringAsFixed(0) ?? 'N/A'}%', theme),
            // UV Index is not available in the 5-day forecast from the API, so it is omitted.
          ],
        ),
      ),
    );
  }

  Widget _buildTempColumn(String label, String temp, ThemeData theme) {
    return Column(
      children: [
        Text(temp, style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w300)),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: theme.iconTheme.color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
