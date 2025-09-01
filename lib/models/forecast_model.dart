class Forecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String mainCondition;
  final String icon;

  Forecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.mainCondition,
    required this.icon,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMin: json['temp']['min'].toDouble(),
      tempMax: json['temp']['max'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
    );
  }
}
