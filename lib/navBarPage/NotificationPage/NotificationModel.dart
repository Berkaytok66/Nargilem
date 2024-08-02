class NotificationModel {
  final String title;
  final String body;
  final DateTime timestamp;
  final String uuid;
  bool isRead;

  NotificationModel({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.uuid,
    required this.isRead,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'uuid': uuid,
    'isRead': isRead,
  };

  static NotificationModel fromJson(Map<String, dynamic> json) => NotificationModel(
    title: json['title'],
    body: json['body'],
    timestamp: DateTime.parse(json['timestamp']),
    uuid: json['uuid'],
    isRead: json['isRead'] ?? false,
  );
}
