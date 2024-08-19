import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:async';

class NotificationService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static const String channelId = 'order_updates';
  static const String channelName = 'Order Updates';

  NotificationService() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _requestBatteryOptimizationException(); // Güç yönetimi hariç tutma
    scheduleBackgroundNotifications(); // Arka planda bildirimleri planlama
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> _requestBatteryOptimizationException() async {
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  // Sürekli bildirim göstermek için bu fonksiyonu ekliyoruz
  Future<void> showOngoingNotification(String title, String body) async {
    await _requestNotificationPermission(); // İzin kontrolü ve isteme işlemi

    const AndroidNotificationDetails ongoingNotificationDetails =
    AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // Sürekli bildirim ayarı
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: ongoingNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> showNotification(String title, String body) async {
    await _requestNotificationPermission(); // İzin kontrolü ve isteme işlemi

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  // WorkManager ile arka planda periyodik bildirim gönderme
  void scheduleBackgroundNotifications() {
    Workmanager().registerPeriodicTask(
      "1",
      "simplePeriodicTask",
      frequency: Duration(minutes: 15), // Her 15 dakikada bir
    );
  }
}
