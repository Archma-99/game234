import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Note: This service requires the 'flutter_local_notifications' package.
// Add `flutter_local_notifications: ^9.0.0` (or a newer version) to your pubspec.yaml.

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // default icon

    // TODO: Add iOS initialization settings if needed
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        // Handle notification tapped
      },
    );
  }

  static Future<void> showWeatherAdvice(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'weather_advice_channel', // id
      'Weather Advice',         // name
      channelDescription: 'Provides users with weather-based advice.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0,       // notification id
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
