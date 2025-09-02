import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

// Note: This service requires the 'http' package and the 'weather' package.
// It is also designed to work with the Gemini AI API.
// You will need a Gemini API key.

class GeminiService {
  // TODO: Replace with your actual Gemini API key
  static const _apiKey = "YOUR_GEMINI_API_KEY";
  static const String _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

  Future<String> getWeatherAdvice(Weather weather) async {
    final url = Uri.parse("$_baseUrl?key=$_apiKey");

    final prompt = """
    Today's weather:
    - Condition: ${weather.weatherMain}
    - Temperature: ${weather.temperature?.celsius?.toStringAsFixed(0)}°C
    - Humidity: ${weather.humidity}%
    - Wind Speed: ${weather.windSpeed} m/s

    Give me one short, friendly, and helpful piece of advice (max 1-2 sentences) for the user. Include a relevant emoji.
    """;

    final requestBody = jsonEncode({
      "contents": [{
        "parts": [{
          "text": prompt
        }]
      }]
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final advice = responseBody['candidates'][0]['content']['parts'][0]['text'];
        return advice.trim();
      } else {
        print('Gemini API Error: ${response.statusCode} ${response.body}');
        return "Could not generate AI advice at this time.";
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return "Could not connect to AI service.";
    }
  }

  Future<String> getMultiDayAdvice(List<Weather> forecasts) async {
    final url = Uri.parse("$_baseUrl?key=$_apiKey");

    // Take the next 3 days for the summary
    final forecastSubset = forecasts.take(3).toList();

    String forecastString = "";
    for (var f in forecastSubset) {
      forecastString += "- ${DateFormat('EEEE').format(f.date!)}: ${f.weatherMain}, max temp ${f.tempMax?.celsius?.toStringAsFixed(0)}°C\n";
    }

    final prompt = """
    Here is the weather forecast for the next 3 days:
    $forecastString

    Based on this, give me a short, helpful summary (max 2 sentences) for the user. For example, "The next three days will be hotter than usual; plan light clothing."
    """;

    final requestBody = jsonEncode({
      "contents": [{
        "parts": [{
          "text": prompt
        }]
      }]
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final advice = responseBody['candidates'][0]['content']['parts'][0]['text'];
        return advice.trim();
      } else {
        return "Could not generate AI summary.";
      }
    } catch (e) {
      return "Could not connect to AI service.";
    }
  }
}
