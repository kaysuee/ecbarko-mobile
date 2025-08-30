// announcement_model.dart
import 'package:flutter/material.dart';
import '../utils/date_format.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String scheduleAffected;
  final String status;
  final String author;
  final DateTime dateCreated;
  final List<String> targetUsers;
  final String priority;
  final bool isActive;
  final DateTime? expiresAt;
  final List<String> readBy;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.scheduleAffected,
    required this.status,
    required this.author,
    required this.dateCreated,
    this.targetUsers = const [],
    this.priority = 'medium',
    this.isActive = true,
    this.expiresAt,
    this.readBy = const [],
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      scheduleAffected: json['scheduleAffected'] ?? '',
      status: json['status'] ?? 'draft',
      author: json['author'] ?? '',
      dateCreated: DateTime.parse(
          json['dateCreated'] ?? DateTime.now().toIso8601String()),
      targetUsers: List<String>.from(json['targetUsers'] ?? []),
      priority: json['priority'] ?? 'medium',
      isActive: json['isActive'] ?? true,
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'scheduleAffected': scheduleAffected,
      'status': status,
      'author': author,
      'dateCreated': dateCreated.toIso8601String(),
      'targetUsers': targetUsers,
      'priority': priority,
      'isActive': isActive,
      'expiresAt': expiresAt?.toIso8601String(),
      'readBy': readBy,
    };
  }

  // Get announcement icon based on type
  String getIcon() {
    switch (type) {
      case 'info':
        return 'ℹ️';
      case 'warning':
        return '⚠️';
      case 'urgent':
        return '🚨';
      case 'maintenance':
        return '🔧';
      case 'general':
        return '📢';
      default:
        return '📢';
    }
  }

  // Get announcement color based on type
  String getColor() {
    switch (type) {
      case 'info':
        return 'blue';
      case 'warning':
        return 'orange';
      case 'urgent':
        return 'red';
      case 'maintenance':
        return 'yellow';
      case 'general':
        return 'green';
      default:
        return 'grey';
    }
  }

  // Get priority icon
  String getPriorityIcon() {
    switch (priority) {
      case 'low':
        return '🔵';
      case 'medium':
        return '🟡';
      case 'high':
        return '🟠';
      case 'critical':
        return '🔴';
      default:
        return '🟡';
    }
  }

  // Get time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(dateCreated);

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

  // Check if announcement is urgent
  bool get isUrgent {
    return type == 'urgent' || priority == 'critical';
  }

  // Check if announcement is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    final now = DateFormatUtil.getCurrentTime();
    return now.isAfter(expiresAt!);
  }

  // Check if announcement requires action
  bool get requiresAction {
    return type == 'urgent' || priority == 'high' || priority == 'critical';
  }

  // Check if user has read the announcement
  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  // Check if announcement is for all users
  bool get isForAllUsers {
    return targetUsers.isEmpty;
  }

  // Check if announcement is for specific user
  bool isForUser(String userId) {
    return isForAllUsers || targetUsers.contains(userId);
  }
}
