import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class WeatherDetailsGrid extends StatelessWidget {
  final Weather weather;

  const WeatherDetailsGrid({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weather Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildDetailCard(
              icon: Icons.water_drop,
              title: 'Humidity',
              value: '${weather.humidity?.toStringAsFixed(0) ?? 'N/A'}%',
            ),
            _buildDetailCard(
              icon: Icons.air,
              title: 'Wind',
              value: '${weather.windSpeed?.toStringAsFixed(1) ?? 'N/A'} m/s',
            ),
            _buildDetailCard(
              icon: Icons.wb_sunny,
              title: 'Sunrise',
              value: weather.sunrise != null ? DateFormat('h:mm a').format(weather.sunrise!) : 'N/A',
            ),
            _buildDetailCard(
              icon: Icons.wb_twilight,
              title: 'Sunset',
              value: weather.sunset != null ? DateFormat('h:mm a').format(weather.sunset!) : 'N/A',
            ),
            _buildDetailCard(
              icon: Icons.compress,
              title: 'Pressure',
              value: '${weather.pressure?.toStringAsFixed(0) ?? 'N/A'} hPa',
            ),
            _buildDetailCard(
              icon: Icons.local_fire_department,
              title: 'UV Index',
              value: weather.uvIndex?.toStringAsFixed(1) ?? 'N/A',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.grey[800]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
