import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class GeminiService {
  static const String apiKey = "YOUR_GEMINI_API_KEY";
  static const String _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

  Future<String> getWeatherAdvice(Weather weather) async {
    final url = Uri.parse("$_baseUrl?key=$apiKey");
    final prompt = """
    Today's weather:
    - Condition: ${weather.weatherMain}
    - Temperature: ${weather.temperature?.celsius?.toStringAsFixed(0)}°C
    - Humidity: ${weather.humidity}%
    - Wind Speed: ${weather.windSpeed} m/s
    Give me one short, friendly, and helpful piece of advice (max 1-2 sentences) for the user. Include a relevant emoji.
    """;
    return _callGemini(prompt);
  }

  Future<String> getMultiDayAdvice(List<Weather> forecasts) async {
    final url = Uri.parse("$_baseUrl?key=$apiKey");
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
    return _callGemini(prompt);
  }

  Future<String> _callGemini(String prompt) async {
    if (apiKey == "YOUR_GEMINI_API_KEY") {
      return "AI advice disabled. Please add your Gemini API key.";
    }
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [{"parts": [{"text": prompt}]}]
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return responseBody['candidates'][0]['content']['parts'][0]['text'].trim();
      } else {
        return "Could not generate AI advice.";
      }
    } catch (e) {
      return "Could not connect to AI service.";
    }
  }
}
