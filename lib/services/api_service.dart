import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

// Note: This service requires the 'http' package.
// Add `http: ^0.13.3` to your pubspec.yaml and run `flutter pub get`.

class ApiService {
  static const _apiKey = "8518f88fbaead827e348b823dcf7386f";
  static const String _geoApiBaseUrl = "http://api.openweathermap.org/geo/1.0";
  static const String _oneCallApiBaseUrl = "https://api.openweathermap.org/data/3.0/onecall";

  Future<Map<String, double>> getCoordinates(String cityName) async {
    final String url = "$_geoApiBaseUrl/direct?q=$cityName&limit=1&appid=$_apiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return {
          'lat': data[0]['lat'].toDouble(),
          'lon': data[0]['lon'].toDouble(),
        };
      } else {
        throw Exception('City not found');
      }
    } else {
      throw Exception('Failed to load coordinates');
    }
  }

  Future<Map<String, dynamic>> getWeatherData(double lat, double lon) async {
    final String url = "$_oneCallApiBaseUrl?lat=$lat&lon=$lon&exclude=minutely,hourly,alerts&appid=$_apiKey&units=metric";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
