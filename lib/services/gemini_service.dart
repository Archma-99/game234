import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

// Note: This service requires the 'http' package.
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
    - Condition: ${weather.mainCondition}
    - Temperature: ${weather.temperature.toStringAsFixed(0)}°C
    - Humidity: ${weather.humidity}%
    - Wind Speed: ${weather.windSpeed.toStringAsFixed(1)} km/h

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
        // Navigate through the JSON to get the text.
        // The exact path might vary, adjust if needed based on actual API response.
        final advice = responseBody['candidates'][0]['content']['parts'][0]['text'];
        return advice.trim();
      } else {
        // Log the error for debugging
        print('Gemini API Error: ${response.statusCode} ${response.body}');
        return "Could not generate AI advice at this time.";
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return "Could not connect to AI service.";
    }
  }
}
