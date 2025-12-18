import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    print("[DEBUG] NotificationService: Starting Init...");
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    bool? initialized = await _plugin.initialize(
    const InitializationSettings(android: androidInit),
    onDidReceiveNotificationResponse: (details) {
      print("[DEBUG] Notification Tapped: ${details.payload}");
    },
  );
  print("[DEBUG] Plugin Initialized: $initialized");
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

    final androidPlatform = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlatform?.createNotificationChannel(resourceChannel);

    print("[DEBUG] Android Platform Implementation: ${androidPlatform != null}");
    await androidPlatform?.createNotificationChannel(chatChannel);
    print("[DEBUG] Notification Channel 'chat_id' Created.");
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