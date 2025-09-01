import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Note: Add intl: ^0.17.0 to your pubspec.yaml
import '../models/forecast_model.dart';

class ForecastList extends StatelessWidget {
  final List<Forecast> forecast;

  ForecastList({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length,
        itemBuilder: (context, index) {
          final dayForecast = forecast[index];
          return _ForecastCard(
            date: dayForecast.date,
            iconCode: dayForecast.icon,
            minTemp: dayForecast.tempMin,
            maxTemp: dayForecast.tempMax,
          );
        },
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final DateTime date;
  final String iconCode;
  final double minTemp;
  final double maxTemp;

  const _ForecastCard({
    required this.date,
    required this.iconCode,
    required this.minTemp,
    required this.maxTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEE').format(date), // e.g., 'Mon'
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Image.network(
              'https://openweathermap.org/img/wn/$iconCode@2x.png',
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.cloud_off, color: Colors.white),
            ),
            Text(
              '${maxTemp.toStringAsFixed(0)}° / ${minTemp.toStringAsFixed(0)}°',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
