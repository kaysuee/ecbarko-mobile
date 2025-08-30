import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_service.dart';
import '../utils/date_format.dart';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class NotificationScheduler {
  static Timer? _reminderTimer;
  static const Duration _checkInterval =
      Duration(minutes: 5); // Check every 5 minutes

  // Start the notification scheduler
  static void startScheduler() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(_checkInterval, (timer) {
      _checkUpcomingBookings();
    });

    print('Notification scheduler started - checking every 5 minutes');
  }

  // Stop the notification scheduler
  static void stopScheduler() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
    print('Notification scheduler stopped');
  }

  // Check for upcoming bookings and send reminders
  static Future<void> _checkUpcomingBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userID');

      if (token == null || userId == null) {
        return;
      }

      // Fetch active bookings for the user
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/actbooking/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> bookings = jsonDecode(response.body);
        final now = DateFormatUtil.getCurrentTime();

        for (final booking in bookings) {
          try {
            final departDate = DateTime.parse(booking['departDate']);
            final departTime = booking['departTime'];

            // Parse departure time - handle both "HH:MM" and "HH AM/PM" formats
            final departureDateTime =
                _parseDepartureTime(departDate, departTime);

            if (departureDateTime == null) {
              print(
                  'Warning: Could not parse departure time: $departTime for booking: ${booking['bookingId']}');
              continue; // Skip this booking if time parsing fails
            }

            // Check if departure is within 1 hour and hasn't been reminded yet
            final timeDifference = departureDateTime.difference(now);
            if (timeDifference.inHours == 0 &&
                timeDifference.inMinutes > 0 &&
                timeDifference.inMinutes <= 60) {
              // Check if we've already sent a reminder for this booking
              final reminderKey = 'reminder_${booking['bookingId']}';
              final hasReminded = prefs.getBool(reminderKey) ?? false;

              if (!hasReminded) {
                // Send reminder notification
                await NotificationService.notifyBookingReminder(
                  userId: userId,
                  bookingId: booking['bookingId'],
                  departureLocation: booking['departureLocation'],
                  arrivalLocation: booking['arrivalLocation'],
                  departTime: departTime,
                  departureDateTime: departureDateTime,
                );

                // Mark as reminded
                await prefs.setBool(reminderKey, true);
                print('Sent reminder for booking: ${booking['bookingId']}');
              }
            }
          } catch (e) {
            print('Error processing booking reminder: $e');
          }
        }
      }
    } catch (e) {
      print('Error checking upcoming bookings: $e');
    }
  }

  // Manually check for reminders (useful for testing)
  static Future<void> checkRemindersNow() async {
    await _checkUpcomingBookings();
  }

  // Get next reminder time for a specific booking
  static DateTime? getNextReminderTime(DateTime departureDateTime) {
    final now = DateFormatUtil.getCurrentTime();
    final timeDifference = departureDateTime.difference(now);

    if (timeDifference.inMinutes > 60) {
      // Return time when reminder should be sent (1 hour before departure)
      return departureDateTime.subtract(const Duration(hours: 1));
    }

    return null;
  }

  // Check if a booking needs a reminder
  static bool needsReminder(DateTime departureDateTime) {
    final now = DateFormatUtil.getCurrentTime();
    final timeDifference = departureDateTime.difference(now);

    return timeDifference.inHours == 0 &&
        timeDifference.inMinutes > 0 &&
        timeDifference.inMinutes <= 60;
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
