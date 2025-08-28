// notification_model.dart
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String userId;
  final Map<String, dynamic> additionalData;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.userId,
    required this.additionalData,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      userId: json['userId'] ?? '',
      additionalData: json['additionalData'] ?? {},
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'userId': userId,
      'additionalData': additionalData,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  // Get notification icon based on type
  String getIcon() {
    switch (type) {
      case 'profile_update':
        return '👤';
      case 'password_update':
        return '🔒';
      case 'booking_created':
        return '✅';
      case 'card_loaded':
        return '💳';
      case 'card_linked':
        return '🔗';
      case 'booking_reminder':
        return '⏰';
      case 'card_tapped':
        return '📱';
      default:
        return '📢';
    }
  }

  // Get notification color based on type
  String getColor() {
    switch (type) {
      case 'profile_update':
        return 'blue';
      case 'password_update':
        return 'red';
      case 'booking_created':
        return 'green';
      case 'card_loaded':
        return 'purple';
      case 'card_linked':
        return 'orange';
      case 'booking_reminder':
        return 'red';
      case 'card_tapped':
        return 'blue';
      default:
        return 'grey';
    }
  }

  // Get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Check if notification is urgent
  bool get isUrgent {
    return type == 'booking_reminder' || 
           (additionalData['urgency'] == 'high');
  }

  // Check if action is required
  bool get requiresAction {
    return additionalData['actionRequired'] == true;
  }
}
