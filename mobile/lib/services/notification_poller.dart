import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_service.dart';

const taskName = 'checkNotifications';
const _baseUrl = 'http://10.254.20.74:8080';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != taskName) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return true;

      final lastCount = prefs.getInt('last_unread_count') ?? 0;

      final countRes = await http.get(
        Uri.parse('$_baseUrl/notifications/unread'),
        headers: {'X-User-Id': userId},
      );
      if (countRes.statusCode != 200) return true;

      final currentCount = jsonDecode(countRes.body)['data']['unread'] as int;

      if (currentCount > lastCount) {
        final notifRes = await http.get(
          Uri.parse('$_baseUrl/notifications?limit=1&offset=0'),
          headers: {'X-User-Id': userId},
        );
        if (notifRes.statusCode == 200) {
          final list = jsonDecode(notifRes.body)['data'] as List;
          if (list.isNotEmpty) {
            final actor = list.first['actor']?['username'] ?? 'Alguém';
            await NotificationService.showLikeNotification(actor);
          }
        }
        await prefs.setInt('last_unread_count', currentCount);
      }
    } catch (_) {}

    return true;
  });
}