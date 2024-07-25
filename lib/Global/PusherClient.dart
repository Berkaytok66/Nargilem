import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pusher_client/pusher_client.dart';
import 'NotificationService.dart';

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
      host: '168.119.115.246',
      wsPort: 6002,
      encrypted: false,
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
    });

    pusher.connect();
  }

  void _subscribeToChannel() {
    if (channel != null) {
      print("Already subscribed to the channel");
      return;
    }

    try {
      channel = pusher.subscribe('private-terminal-channel');
      channel?.bind('App\\Events\\TerminalEvent', (dynamic event) {
        print("Event received: ${event.data}");
        onEventReceived(event.data); // Mesajı HomePage widget'ına ilet

        //sadece spariş bildirimi
        // Bildirim gönder
        final parsedData = jsonDecode(event.data);
        if (parsedData.containsKey('pageName')) {
          if (parsedData["data"]["order_status"] == 1) {
            notificationService.showNotification(
              'Nargilem',
              'Hey!!! Yeni bir siparişiniz var🧐',
            );
          }

        }
      });
    } catch (e) {
      print("Error subscribing to channel: $e");
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
