// notification_model.dart
class NotificationModel {
  final String type;
  final String message;
  final DateTime date;
  bool isRead;

  NotificationModel({
    required this.type,
    required this.message,
    required this.date,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      type: json['type'] as String,
      message: json['message'] as String,
      date: DateTime.parse(json['date']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'date': date.toIso8601String(),
      'isRead': isRead,
    };
  }
}
