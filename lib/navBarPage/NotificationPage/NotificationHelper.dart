import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'NotificationModel.dart';

class NotificationHelper {
  static const String _notificationsKey = 'notifications';

  static Future<void> saveNotification(NotificationModel notification) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notifications = prefs.getStringList(_notificationsKey) ?? [];
    notifications.add(jsonEncode(notification.toJson()));

    // Son 50 bildirimi tut
    if (notifications.length > 50) {
      notifications = notifications.sublist(notifications.length - 50);
    }

    await prefs.setStringList(_notificationsKey, notifications);
  }

  static Future<List<NotificationModel>> getNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notifications = prefs.getStringList(_notificationsKey) ?? [];
    List<NotificationModel> notificationList = notifications.map((item) {
      Map<String, dynamic> json = jsonDecode(item);
      return NotificationModel.fromJson(json);
    }).toList();

    // Bildirimleri ters sırada döndür
    notificationList = notificationList.reversed.toList();

    return notificationList;
  }

  static Future<void> markAsRead(int originalIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notifications = prefs.getStringList(_notificationsKey) ?? [];

    if (originalIndex < notifications.length) {
      NotificationModel notification = NotificationModel.fromJson(jsonDecode(notifications[originalIndex]));
      notification.isRead = true;
      notifications[originalIndex] = jsonEncode(notification.toJson());
      await prefs.setStringList(_notificationsKey, notifications);

      // Log messages for debugging
      print("Updated notification at original index $originalIndex: ${notifications[originalIndex]}");
    } else {
      print("Index $originalIndex out of range");
    }
  }
}
