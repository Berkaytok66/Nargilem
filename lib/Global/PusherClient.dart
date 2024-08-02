import 'dart:convert';
import 'package:nargilem/navBarPage/NotificationPage/NotificationHelper.dart';
import 'package:nargilem/navBarPage/NotificationPage/NotificationModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NotificationService.dart';
import 'package:pusher_client/pusher_client.dart';

class PusherClientManager {
  static final PusherClientManager _instance = PusherClientManager._internal();
  late PusherClient pusher;
  Channel? channel;
  late String token;
  late Function(dynamic) onEventReceived;
  late NotificationService notificationService;

  factory PusherClientManager() {
    return _instance;
  }

  PusherClientManager._internal() {
    notificationService = NotificationService();
  }

  void initialize(String token, Function(dynamic) onEventReceived) {
    this.token = token;
    this.onEventReceived = onEventReceived;

    PusherOptions options = PusherOptions(
      host: 'socket.mebu.com.tr',
      wssPort: 6002,
      encrypted: true,
      auth: PusherAuth(
        'https://nargile.mebu.com.tr/broadcasting/auth',
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    pusher = PusherClient(
      '9kib2q85k1wxjfk7ersb',
      options,
      autoConnect: false,
    );

    pusher.onConnectionStateChange((state) {
      print("previousState: ${state!.previousState}, currentState: ${state.currentState}");
      if (state.currentState == 'CONNECTED') {
        _subscribeToChannel();
      }
    });

    pusher.onConnectionError((error) {
      print("error: ${error!.message}");
      pusher.connect();

    });

    pusher.connect();
  }

  void _retryConnection() {
    print("Retrying connection...");
    Future.delayed(Duration(seconds: 5), () {
      if (pusher.connect() != 'CONNECTED') {
        pusher.connect();
      }
    });
  }

  Future<void> _subscribeToChannel() async {
    if (channel != null) {
      print("Already subscribed to the channel");
      return;
    }

    try {
      channel = pusher.subscribe('private-terminal-channel');
      channel?.bind('App\\Events\\TerminalEvent', (dynamic event) async {
        print("Event received: ${event.data}");
        onEventReceived(event.data); // Mesajı ilgili widget'a ilet

        // Bildirim gönderme
        final parsedData = jsonDecode(event.data);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool allNotifications = prefs.getBool('all_notifications') ?? true;
        bool orderUpdates = prefs.getBool('order_updates') ?? true;
        bool emberUpdates = prefs.getBool('emberPage_updates') ?? true;

        if (allNotifications) {
          bool notificationSent = false;

          if (orderUpdates && parsedData["data"] is Map && parsedData["data"]["order_status"] == 1) {
            notificationService.showNotification(
              'Nargilem',
              'Hey!!! Yeni bir siparişiniz var🧐',
            );
            notificationSent = true;
          }

          if (emberUpdates && parsedData["pageName"] == "emberPage") {
            notificationService.showNotification(
              'Nargilem',
              'Hey!!! Müşteri Köz İstiyor🔥',
            );
            notificationSent = true;
          }

          if (!notificationSent && parsedData.containsKey('pageName') && parsedData["pageName"] == "orders") {
            notificationService.showNotification(
              'Nargilem',
              'Hey!!! Yeni bir bildiriminiz var🧐',
            );
          }
        }

        if (parsedData["status"] == 200 && parsedData.containsKey('data')) {
          List<dynamic> dataList = parsedData["data"] is List ? parsedData["data"] : [parsedData["data"]];
          for (var data in dataList) {
            NotificationModel notification;
            if (data["order_status"] == 1) {
              notification = NotificationModel(
                title: 'Masa  ${data["table_id"]}',
                body: 'Yeni bir siparişiniz var🧐',
                isRead: false,
                uuid: '${data["uuid"]}',
                timestamp: DateTime.now(),

              );
            } else if (parsedData["pageName"] == "emberPage") {
              notification = NotificationModel(
                title: 'Masa  ${data["table_id"]}',
                body: 'Müşteri Köz Talebinde Bulunudu🔥',
                isRead: false,
                uuid: '${data["uuid"]}',
                timestamp: DateTime.now(),
              );
            } else {
              notification = NotificationModel(
                title: 'Masa  ${data["table_id"]}',
                body: 'Spariş Durumu Gücellendi🧐',
                isRead: false,
                uuid: '${data["uuid"]}',
                timestamp: DateTime.now(),
              );
            }
            await NotificationHelper.saveNotification(notification);
          }
        }
      });
    } catch (e) {
      print("Error subscribing to channel: $e");
      _retryConnection();
    }
  }

  void disconnect() {
    if (channel != null) {
      pusher.unsubscribe(channel!.name);
      channel = null;
    }
    pusher.disconnect();
  }
}
