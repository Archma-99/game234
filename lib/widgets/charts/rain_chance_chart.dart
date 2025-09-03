import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

// Note: This widget requires the 'fl_chart' package.

class RainChanceChart extends StatelessWidget {
  final List<Weather> hourlyForecast;

  const RainChanceChart({Key? key, required this.hourlyForecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Take a subset of the data, e.g., next 12 hours
    final chartData = hourlyForecast.take(12).toList();

    return AspectRatio(
      aspectRatio: 3,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(chartData.length, (index) {
            final rain = chartData[index].rainLastHour ?? 0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: rain.toDouble(),
                  color: Colors.blue[200],
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
