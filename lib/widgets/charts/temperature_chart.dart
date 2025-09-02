import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

// Note: This widget requires the 'fl_chart' package.

class TemperatureChart extends StatelessWidget {
  final List<Weather> hourlyForecast;

  const TemperatureChart({Key? key, required this.hourlyForecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Take a subset of the data for readability, e.g., next 12 hours
    final chartData = hourlyForecast.take(12).toList();

    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 3, // Show title for every 3 hours
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < chartData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('h a').format(chartData[index].date!),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(chartData.length, (index) {
                return FlSpot(index.toDouble(), chartData[index].temperature!.celsius!);
              }),
              isCurved: true,
              color: Colors.blue[500],
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue[200]?.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
