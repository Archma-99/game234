import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

// Note: This widget requires the 'fl_chart' package.

class DailyTemperatureChart extends StatelessWidget {
  final List<Weather> dailyForecast;

  const DailyTemperatureChart({Key? key, required this.dailyForecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dailyForecast.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('EEE').format(dailyForecast[index].date!),
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
            // Max Temp Line
            LineChartBarData(
              spots: List.generate(dailyForecast.length, (index) {
                return FlSpot(index.toDouble(), dailyForecast[index].tempMax!.celsius!);
              }),
              isCurved: true,
              color: Colors.blue[500],
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
            ),
            // Min Temp Line
            LineChartBarData(
              spots: List.generate(dailyForecast.length, (index) {
                return FlSpot(index.toDouble(), dailyForecast[index].tempMin!.celsius!);
              }),
              isCurved: true,
              color: Colors.blue[200],
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
