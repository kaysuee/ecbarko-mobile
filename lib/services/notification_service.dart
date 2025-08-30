import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../utils/date_format.dart';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class NotificationService {
  static const String _notificationsKey = 'user_notifications';

  // Notification types
  static const String profileUpdate = 'profile_update';
  static const String passwordUpdate = 'password_update';
  static const String bookingCreated = 'booking_created';
  static const String cardLoaded = 'card_loaded';
  static const String cardLinked = 'card_linked';
  static const String bookingReminder = 'booking_reminder';
  static const String cardTapped = 'card_tapped';

  // Create a new notification
  static Future<void> createNotification({
    required String type,
    required String title,
    required String message,
    required String userId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for notification creation');
        return;
      }

      final notificationData = {
        'type': type,
        'title': title,
        'message': message,
        'userId': userId,
        'additionalData': additionalData ?? {},
        'createdAt': DateFormatUtil.getCurrentTime().toIso8601String(),
        'isRead': false,
      };

      // Send to backend API
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(notificationData),
      );

      if (response.statusCode == 200) {
        print('Notification created successfully: $title');
      } else {
        print('Failed to create notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Profile update notification
  static Future<void> notifyProfileUpdate({
    required String userId,
    required String updatedField,
    String? oldValue,
    String? newValue,
  }) async {
    final title = 'Profile Updated';
    final message = 'Your $updatedField has been updated successfully.';

    final additionalData = {
      'updatedField': updatedField,
      'oldValue': oldValue,
      'newValue': newValue,
    };

    await createNotification(
      type: profileUpdate,
      title: title,
      message: message,
      userId: userId,
      additionalData: additionalData,
    );
  }

  // Password update notification
  static Future<void> notifyPasswordUpdate({
    required String userId,
  }) async {
    final title = 'Password Updated';
    final message =
        'Your password has been changed successfully. Please keep it secure.';

    await createNotification(
      type: passwordUpdate,
      title: title,
      message: message,
      userId: userId,
      additionalData: {
        'securityLevel': 'high',
        'actionRequired': false,
      },
    );
  }

  // Booking created notification
  static Future<void> notifyBookingCreated({
    required String userId,
    required String bookingId,
    required String departureLocation,
    required String arrivalLocation,
    required String departDate,
    required String departTime,
  }) async {
    final title = 'Booking Confirmed';
    final message =
        'Your trip from $departureLocation to $arrivalLocation on $departDate at $departTime has been confirmed.';

    await createNotification(
      type: bookingCreated,
      title: title,
      message: message,
      userId: userId,
      additionalData: {
        'bookingId': bookingId,
        'departureLocation': departureLocation,
        'arrivalLocation': arrivalLocation,
        'departDate': departDate,
        'departTime': departTime,
        'actionRequired': false,
      },
    );
  }

  // Card loaded notification
  static Future<void> notifyCardLoaded({
    required String userId,
    required double amount,
    required String cardType,
  }) async {
    final title = 'Card Loaded';
    final message =
        '₱${amount.toStringAsFixed(2)} has been loaded to your $cardType card.';

    await createNotification(
      type: cardLoaded,
      title: title,
      message: message,
      userId: userId,
      additionalData: {
        'amount': amount,
        'cardType': cardType,
        'actionRequired': false,
      },
    );
  }

  // Card linked notification
  static Future<void> notifyCardLinked({
    required String userId,
    required String cardType,
    required String cardNumber,
  }) async {
    final title = 'Card Linked';
    final message =
        'Your $cardType card ending in ${cardNumber.substring(cardNumber.length - 4)} has been linked successfully.';

    await createNotification(
      type: cardLinked,
      title: title,
      message: message,
      userId: userId,
      additionalData: {
        'cardType': cardType,
        'cardNumber': cardNumber,
        'actionRequired': false,
      },
    );
  }

  // Booking reminder notification (within 1 hour)
  static Future<void> notifyBookingReminder({
    required String userId,
    required String bookingId,
    required String departureLocation,
    required String arrivalLocation,
    required String departTime,
    required DateTime departureDateTime,
  }) async {
    final title = 'Trip Reminder';
    final message =
        'Your trip to $arrivalLocation departs in less than 1 hour. Please arrive at $departureLocation 30 minutes before departure.';

    await createNotification(
      type: bookingReminder,
      title: title,
      message: message,
      userId: userId,
      additionalData: {
        'bookingId': bookingId,
        'departureLocation': departureLocation,
        'arrivalLocation': arrivalLocation,
        'departTime': departTime,
        'departureDateTime': departureDateTime.toIso8601String(),
        'actionRequired': true,
        'urgency': 'high',
      },
    );
  }

  // Card tapped notification
  static Future<void> notifyCardTapped({
    required String userId,
    required String cardType,
    required String action,
  }) async {
    final title = 'Card Activity';
    final message = 'Your $cardType card was used for: $action';

    await createNotification(
      type: cardTapped,
      title: title,
      message: message,
      userId: userId,
      additionalData: {
        'cardType': cardType,
        'action': action,
        'actionRequired': false,
      },
    );
  }

  // Check for upcoming bookings and send reminders
  static Future<void> checkAndSendBookingReminders({
    required String userId,
    required List<Map<String, dynamic>> activeBookings,
  }) async {
    final now = DateTime.now();

    for (final booking in activeBookings) {
      try {
        final departDate = DateTime.parse(booking['departDate']);
        final departTime = booking['departTime'];

        // Parse departure time - handle both "HH:MM" and "HH AM/PM" formats
        final departureDateTime = _parseDepartureTime(departDate, departTime);

        if (departureDateTime == null) {
          print(
              'Warning: Could not parse departure time: $departTime for booking: ${booking['bookingId']}');
          continue; // Skip this booking if time parsing fails
        }

        // Check if departure is within 1 hour
        final timeDifference = departureDateTime.difference(now);
        if (timeDifference.inHours == 0 &&
            timeDifference.inMinutes > 0 &&
            timeDifference.inMinutes <= 60) {
          // Send reminder notification
          await notifyBookingReminder(
            userId: userId,
            bookingId: booking['bookingId'],
            departureLocation: booking['departureLocation'],
            arrivalLocation: booking['arrivalLocation'],
            departTime: departTime,
            departureDateTime: departureDateTime,
          );
        }
      } catch (e) {
        print('Error processing booking reminder: $e');
      }
    }
  }

  // Get user notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications({
    required String userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('🔍 NotificationService: Fetching notifications for user: $userId');
      print('🔍 NotificationService: Token present: ${token != null}');

      if (token == null) {
        print(
            '❌ NotificationService: No token available for fetching notifications');
        return [];
      }

      final url = '${getBaseUrl()}/api/notifications/$userId';
      print('🔍 NotificationService: Making request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 NotificationService: Response status: ${response.statusCode}');
      print('🔍 NotificationService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> notifications = jsonDecode(response.body);
        print(
            '🔍 NotificationService: Successfully parsed ${notifications.length} notifications');
        return notifications.cast<Map<String, dynamic>>();
      } else {
        print(
            '❌ NotificationService: Failed to fetch notifications: ${response.statusCode}');
        print('❌ NotificationService: Error response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ NotificationService: Error fetching notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead({
    required String notificationId,
    required String userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for marking notification as read');
        return;
      }

      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'isRead': true,
        }),
      );

      if (response.statusCode == 200) {
        print('Notification marked as read: $notificationId');
      } else {
        print('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read for a user
  static Future<void> markAllNotificationsAsRead({
    required String userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for marking all notifications as read');
        return;
      }

      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/notifications/$userId/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        print('All notifications marked as read for user: $userId');
      } else {
        print(
            'Failed to mark all notifications as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Get archived notifications (notification history)
  static Future<List<Map<String, dynamic>>> getArchivedNotifications({
    required String userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for fetching archived notifications');
        return [];
      }

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/notifications/$userId/archived'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> notifications = jsonDecode(response.body);
        return notifications.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch archived notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching archived notifications: $e');
      return [];
    }
  }

  // Get unread notification count
  static Future<int> getUnreadNotificationCount({
    required String userId,
  }) async {
    try {
      final notifications = await getUserNotifications(userId: userId);
      return notifications
          .where((notification) => notification['isRead'] == false)
          .length;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  // Archive notification (mark as archived instead of deleting)
  static Future<void> archiveNotification({
    required String notificationId,
    required String userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for archiving notification');
        return;
      }

      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/notifications/$notificationId/archive'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'isArchived': true,
        }),
      );

      if (response.statusCode == 200) {
        print('Notification archived: $notificationId');
      } else {
        print('Failed to archive notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error archiving notification: $e');
    }
  }

  // Delete notification
  static Future<void> deleteNotification({
    required String notificationId,
    required String userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token available for deleting notification');
        return;
      }

      final response = await http.delete(
        Uri.parse('${getBaseUrl()}/api/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        print('Notification deleted: $notificationId');
      } else {
        print('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Parse departure time from various formats
  static DateTime? _parseDepartureTime(DateTime departDate, String departTime) {
    try {
      // Remove any extra whitespace
      final cleanTime = departTime.trim();

      // Try to parse as "HH:MM" format first
      if (cleanTime.contains(':')) {
        final timeParts = cleanTime.split(':');
        if (timeParts.length == 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
            return DateTime(
              departDate.year,
              departDate.month,
              departDate.day,
              hour,
              minute,
            );
          }
        }
      }

      // Try to parse as "HH AM/PM" format
      if (cleanTime.contains('AM') || cleanTime.contains('PM')) {
        final timeStr = cleanTime.replaceAll(' ', '');
        final isPM = timeStr.contains('PM');
        final timeOnly = timeStr.replaceAll('AM', '').replaceAll('PM', '');

        int hour = int.parse(timeOnly);

        // Convert 12-hour to 24-hour format
        if (isPM && hour != 12) {
          hour += 12;
        } else if (!isPM && hour == 12) {
          hour = 0;
        }

        if (hour >= 0 && hour <= 23) {
          return DateTime(
            departDate.year,
            departDate.month,
            departDate.day,
            hour,
            0, // Default to 0 minutes for AM/PM format
          );
        }
      }

      // If all parsing attempts fail, return null
      print('Warning: Could not parse time format: $departTime');
      return null;
    } catch (e) {
      print('Error parsing departure time: $departTime - $e');
      return null;
    }
  }
}
