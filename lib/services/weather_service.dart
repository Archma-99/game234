import 'package:weather/weather.dart';
// Note: This service requires the 'weather' package.
// Add `weather: ^3.2.1` to your pubspec.yaml.

class WeatherService {
  final WeatherFactory _wf;

  WeatherService()
      : _wf = WeatherFactory("8518f88fbaead827e348b823dcf7386f");

  Future<Weather> getCurrentWeather(String cityName) async {
    try {
      Weather weather = await _wf.currentWeatherByCityName(cityName);
      return weather;
    } catch (e) {
      print("Error getting current weather: $e");
      rethrow;
    }
  }

  Future<List<Weather>> getFiveDayForecast(String cityName) async {
    try {
      List<Weather> forecast = await _wf.fiveDayForecastByCityName(cityName);
      return forecast;
    } catch (e) {
      print("Error getting 5-day forecast: $e");
      rethrow;
    }
  }

  // The weather package does not have a separate hourly forecast method.
  // The fiveDayForecast returns data in 3-hour intervals. We can use this.
  // This method will simply return the same data as the 5-day forecast,
  // and the UI will be responsible for interpreting it as hourly.
  Future<List<Weather>> getHourlyForecast(String cityName) async {
    try {
      List<Weather> forecast = await _wf.fiveDayForecastByCityName(cityName);
      return forecast;
    } catch (e) {
      print("Error getting hourly forecast: $e");
      rethrow;
    }
  }

  Future<Weather> getCurrentWeatherByCoord(double lat, double lon) async {
    try {
      Weather weather = await _wf.currentWeatherByLocation(lat, lon);
      return weather;
    } catch (e) {
      print("Error getting current weather by coord: $e");
      rethrow;
    }
  }

  Future<List<Weather>> getFiveDayForecastByCoord(double lat, double lon) async {
    try {
      List<Weather> forecast = await _wf.fiveDayForecastByLocation(lat, lon);
      return forecast;
    } catch (e) {
      print("Error getting 5-day forecast by coord: $e");
      rethrow;
    }
  }
}
