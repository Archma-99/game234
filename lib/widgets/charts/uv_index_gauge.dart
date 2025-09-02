import 'package:flutter/material.dart';

class UvIndexGauge extends StatelessWidget {
  final double uvIndex;

  const UvIndexGauge({Key? key, required this.uvIndex}) : super(key: key);

  String _getUvIndexCategory(double uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  @override
  Widget build(BuildContext context) {
    // Normalize uvIndex to a 0.0 - 1.0 scale, capping at a max of 11 for the scale.
    final double percent = (uvIndex / 11.0).clamp(0.0, 1.0);
    final String category = _getUvIndexCategory(uvIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('UV Index', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            Text(
              '${uvIndex.toStringAsFixed(0)} $category',
              style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: constraints.maxWidth * percent,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.yellow[600]!, Colors.red[500]!],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
