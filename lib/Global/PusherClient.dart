
import 'package:pusher_client/pusher_client.dart';

class Pusherclient {
  late PusherClient pusher;
  Channel? channel;
  final String token;

  Pusherclient(this.token);

  void connectPusher() {
    PusherOptions options = PusherOptions(
      host: '168.119.115.246', // Özel sunucu
      wsPort: 6002, // Özel port
      encrypted: false, // İletişimin şifreli olup olmadığını belirtir
      auth: PusherAuth(
        'http://172.25.25.2:8005/api/broadcasting/auth',
        headers: {
          'Authorization':
          'Bearer $token',
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
      channel = pusher.subscribe('private-order-status-updated.85150235-34cd-424b-9052-be4e7075ac72');
      channel!.bind('App\\Events\\DeviceOrderUpdateEvent', (dynamic event) {
        print("Event received: ${event.data}");
      });
      channel!.bind('pusher:subscription_succeeded', (dynamic data) {
        print("Subscription succeeded: $data");
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
