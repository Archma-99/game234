class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final double feelsLike;
  final int humidity;
  final double windSpeed;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
  });

  factory Weather.fromJson(Map<String, dynamic> json, String cityName) {
    return Weather(
      cityName: cityName,
      temperature: json['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      feelsLike: json['feels_like'].toDouble(),
      humidity: json['humidity'],
      windSpeed: json['wind_speed'].toDouble(),
    );
  }
}
