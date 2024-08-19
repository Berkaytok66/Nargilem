import 'dart:async';
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
  String currentState = '';
  bool isInitialized = false;
  bool isSubscribed = false;
  int retryCount = 0;
  final int maxRetries = 5;
  Timer? reconnectTimer;

  factory PusherClientManager() {
    return _instance;
  }

  PusherClientManager._internal() {
    notificationService = NotificationService();
  }

  void initialize(String token, Function(dynamic) onEventReceived) {
    if (isInitialized) {
      print("PusherClientManager zaten başlatıldı");
      return;
    }

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
      autoConnect: true,
    );

    pusher.onConnectionStateChange((state) {
      print("previousState: ${state?.previousState}, currentState: ${state?.currentState}");

      currentState = state?.currentState ?? '';

      if (currentState == 'CONNECTED' && !isSubscribed) {
        _subscribeToChannel();
        retryCount = 0;
      } else if (currentState == 'DISCONNECTED' || currentState == 'RECONNECTING') {
        _retryConnection();
      }
    });

    pusher.onConnectionError((error) {
      print("error: ${error?.message}");
      Future.delayed(Duration(seconds: 5), () {
        _retryConnection();
      });
    });

    pusher.connect();
    isInitialized = true;
  }

  void connect() {
    if (!isInitialized) {
      print("PusherClientManager initialize edilmedi.");
      return;
    }
    pusher.connect();
  }

  void disconnect() {
    if (channel != null) {
      pusher.unsubscribe(channel!.name);
      channel = null;
    }
    pusher.disconnect();
    isInitialized = false;
    isSubscribed = false;
  }

  void _retryConnection() {
    print("Retrying connection...");

    if (currentState == 'CONNECTING' || currentState == 'RECONNECTING' || retryCount >= maxRetries) {
      print("Bağlanma denemeleri sınırına ulaşıldı veya bağlantı zaten kuruluyor.");
      return;
    }

    retryCount++;
    reconnectTimer?.cancel();
    reconnectTimer = Timer(Duration(seconds: 5), () {
      pusher.connect();
    });
  }

  Future<void> _subscribeToChannel() async {
    if (channel != null) {
      print("Already subscribed to the channel");
      return;
    }

    try {
      channel = pusher.subscribe('private-terminal-channel');
      isSubscribed = true;

      channel?.bind('App\\Events\\TerminalEvent', (dynamic event) async {
        print("Event received: ${event.data}");
        onEventReceived(event.data);

        final parsedData = jsonDecode(event.data);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool allNotifications = prefs.getBool('all_notifications') ?? true;
        bool orderUpdates = prefs.getBool('order_updates') ?? true;
        bool emberUpdates = prefs.getBool('emberPage_updates') ?? true;

        if (allNotifications) {
          bool notificationSent = false;

          if (orderUpdates && parsedData["data"] is Map && parsedData["data"]["order_status"] == 1) {
            notificationService.showNotification(
              'NargileHub',
              'Hey!!! Yeni bir siparişiniz var🧐',
            );
            notificationSent = true;
          }

          if (emberUpdates && parsedData["pageName"] == "emberPage") {
            notificationService.showNotification(
              'NargileHub',
              'Hey!!! Müşteri Köz İstiyor🔥',
            );
            notificationSent = true;
          }
          if (emberUpdates && parsedData["pageName"] == "employeePage") {
            notificationService.showNotification(
              'NargileHub',
              'Hey!!! Müşteri Sizi Çagırıyor🔥',
            );
            notificationSent = true;
          }
          if (!notificationSent && parsedData.containsKey('pageName') && parsedData["pageName"] == "orders") {
            notificationService.showNotification(
              'NargileHub',
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
                title: 'Masa ${data["table_id"]}',
                body: 'Yeni bir siparişiniz var🧐',
                isRead: false,
                uuid: '${data["uuid"]}',
                timestamp: DateTime.now(),
              );
            } else if (parsedData["pageName"] == "emberPage") {
              notification = NotificationModel(
                title: 'Masa ${data["table_id"]}',
                body: 'Müşteri Köz Talebinde Bulundu🔥',
                isRead: false,
                uuid: '${data["uuid"]}',
                timestamp: DateTime.now(),
              );
            }else if (parsedData["pageName"] == "employeePage"){
              notification = NotificationModel(
                title: 'Masa ${data["table_id"]}',
                body: 'Muşteri Sizi Çağırıyor🗣️',
                isRead: false,
                uuid: '${data["uuid"]}',
                timestamp: DateTime.now(),
              );
            } else {
              notification = NotificationModel(
                title: 'Masa ${data["table_id"]}',
                body: 'Sipariş Durumu Güncellendi🧐',
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
      isSubscribed = false;
      _retryConnection();
    }
  }
}
