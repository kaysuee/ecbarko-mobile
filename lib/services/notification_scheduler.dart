import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_service.dart';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class NotificationScheduler {
  static Timer? _reminderTimer;
  static const Duration _checkInterval = Duration(minutes: 5); // Check every 5 minutes

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
        final now = DateTime.now();
        
        for (final booking in bookings) {
          try {
            final departDate = DateTime.parse(booking['departDate']);
            final departTime = booking['departTime'];
            
            // Parse departure time
            final timeParts = departTime.split(':');
            final departureDateTime = DateTime(
              departDate.year,
              departDate.month,
              departDate.day,
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );

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
    final now = DateTime.now();
    final timeDifference = departureDateTime.difference(now);
    
    if (timeDifference.inMinutes > 60) {
      // Return time when reminder should be sent (1 hour before departure)
      return departureDateTime.subtract(const Duration(hours: 1));
    }
    
    return null;
  }

  // Check if a booking needs a reminder
  static bool needsReminder(DateTime departureDateTime) {
    final now = DateTime.now();
    final timeDifference = departureDateTime.difference(now);
    
    return timeDifference.inHours == 0 && 
           timeDifference.inMinutes > 0 && 
           timeDifference.inMinutes <= 60;
  }
}
