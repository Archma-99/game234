import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Note: Add provider to pubspec.yaml
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'providers/theme_provider.dart';
import 'services/gemini_service.dart';

final settingsService = SettingsService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await NotificationService.init();
  await settingsService.init();

  // Check for placeholder API key
  if (GeminiService.apiKey == "YOUR_GEMINI_API_KEY") {
    print("\n" * 5);
    print("*****************************************************************");
    print("WARNING: Gemini API key is a placeholder.");
    print("AI features will not work until you replace it in lib/services/gemini_service.dart");
    print("*****************************************************************");
    print("\n" * 5);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(settingsService),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Weather App',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: SplashScreen(),
    );
  }
}
