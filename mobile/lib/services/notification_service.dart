import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  static Future<void> showLikeNotification(String actorUsername) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'likes_channel',
        'Curtidas',
        channelDescription: 'Notificações de curtidas nas suas artes',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.show(
      0,
      'Nova curtida! ❤️',
      '$actorUsername curtiu sua arte',
      details,
    );
  }
}