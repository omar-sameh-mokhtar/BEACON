import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
    const InitializationSettings(android: androidInit)
    );
    const resourceChannel = AndroidNotificationChannel(
      'emergency_alerts', 'Emergency Alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const chatChannel = AndroidNotificationChannel(
      'chat_messages', 'Chat Messages',
      importance: Importance.defaultImportance,
    );
    const clientChannel = AndroidNotificationChannel(
      'client_joins', 'Client Joins',
      importance: Importance.defaultImportance,
    );
    

    final androidPlatform = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlatform?.createNotificationChannel(resourceChannel);

    await androidPlatform?.createNotificationChannel(chatChannel);

    await androidPlatform?.createNotificationChannel(clientChannel);
  }

  static Future<void> showAlert(String title, String body, String channelId) async {
    await _plugin.show(
      DateTime.now().millisecond,
      title, body,
      NotificationDetails(
        android: AndroidNotificationDetails(channelId, channelId,
            importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher'),
      ),
    );
  }
}