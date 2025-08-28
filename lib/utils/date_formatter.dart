import 'package:intl/intl.dart';

/// Centralized date formatting utility for consistent date display across the app
class DateFormatter {
  /// Formats date in abbreviated month format: "JAN 27, 2025 TUE"
  static String formatDateAbbreviated(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy EEE').format(date).toUpperCase();
    } catch (e) {
      print('Error formatting date: $e');
      return dateString;
    }
  }

  /// Formats DateTime object in abbreviated month format: "JAN 27, 2025 TUE"
  static String formatDateAbbreviatedFromDateTime(DateTime dateTime) {
    try {
      return DateFormat('MMM d, yyyy EEE').format(dateTime).toUpperCase();
    } catch (e) {
      print('Error formatting DateTime: $e');
      return 'N/A';
    }
  }

  /// Formats date in abbreviated month format: "JAN 27, 2025 TUE"
  /// Alias for backward compatibility
  static String formatDepartDate(String dateString) {
    return formatDateAbbreviated(dateString);
  }

  /// Formats date for display in abbreviated month format: "JAN 27, 2025 TUE"
  static String formatDateForDisplay(String dateString) {
    return formatDateAbbreviated(dateString);
  }

  /// Formats time in 12-hour format with AM/PM
  static String formatTime(String timeStr) {
    try {
      // Handle different time formats
      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        // Format: "03:30 AM" or "3:30 PM" - already in 12-hour format
        return timeStr;
      } else {
        // Format: "15:30" (24-hour) - convert to 12-hour format
        final timeParts = timeStr.split(':');
        if (timeParts.length != 2) {
          return timeStr;
        }

        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        String period = 'AM';
        if (hour >= 12) {
          period = 'PM';
          if (hour > 12) {
            hour -= 12;
          }
        }
        if (hour == 0) {
          hour = 12;
        }

        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      print('Error formatting time: $e');
      return timeStr;
    }
  }

  /// Formats DateTime object time in 12-hour format with AM/PM
  static String formatTimeFromDateTime(DateTime dateTime) {
    try {
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      print('Error formatting DateTime time: $e');
      return 'N/A';
    }
  }

  /// Formats schedule time in 12-hour format with AM/PM
  static String formatScheduleTime(String timeStr) {
    return formatTime(timeStr);
  }

  /// Formats full date and time: "JAN 27, 2025 TUE at 03:30 PM"
  static String formatDateTime(String dateString, String timeString) {
    final formattedDate = formatDateAbbreviated(dateString);
    final formattedTime = formatTime(timeString);
    return '$formattedDate at $formattedTime';
  }

  /// Formats DateTime object for full date and time: "JAN 27, 2025 TUE at 03:30 PM"
  static String formatDateTimeFromDateTime(DateTime dateTime) {
    try {
      final formattedDate =
          DateFormat('MMM d, yyyy EEE').format(dateTime).toUpperCase();
      final formattedTime = DateFormat('hh:mm a').format(dateTime);
      return '$formattedDate at $formattedTime';
    } catch (e) {
      print('Error formatting DateTime: $e');
      return 'N/A';
    }
  }

  /// Formats date for booking display: "JAN 27, 2025 TUE"
  static String formatBookingDate(String dateString) {
    return formatDateAbbreviated(dateString);
  }

  /// Formats date for schedule display: "JAN 27, 2025 TUE"
  static String formatScheduleDate(String dateString) {
    return formatDateAbbreviated(dateString);
  }
}
