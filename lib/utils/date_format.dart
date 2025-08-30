import 'package:intl/intl.dart';

/// Centralized date formatting utility for consistent date display across the app
class DateFormatUtil {
  // Private constants for common date formats
  static const String _abbreviatedDateFormat =
      'MMM d yyyy EEE'; // Removed comma
  static const String _timeFormat = 'hh:mm a';
  static const String _transactionDateFormat =
      'MMM dd, yyyy'; // For transaction history
  static const String _debugDateFormat =
      'yyyy-MM-dd HH:mm'; // For debug logging
  static const String _isoDateFormat = 'yyyy-MM-dd'; // ISO date format
  static const String _shortDateFormat = 'MMM dd'; // Short date format

  /// Formats date in abbreviated month format: "JAN 27 2025 MON"
  static String formatDateAbbreviated(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat(_abbreviatedDateFormat).format(date).toUpperCase();
    } catch (e) {
      print('Error formatting date: $e');
      return dateString;
    }
  }

  /// Formats DateTime object in abbreviated month format: "JAN 27 2025 MON"
  static String formatDateAbbreviatedFromDateTime(DateTime dateTime) {
    try {
      return DateFormat(_abbreviatedDateFormat).format(dateTime).toUpperCase();
    } catch (e) {
      print('Error formatting DateTime: $e');
      return 'N/A';
    }
  }

  /// Formats date for transaction history: "JAN 27, 2025"
  static String formatTransactionDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat(_transactionDateFormat).format(date).toUpperCase();
    } catch (e) {
      print('Error formatting transaction date: $e');
      return dateString;
    }
  }

  /// Formats DateTime object for transaction history: "JAN 27, 2025"
  static String formatTransactionDateFromDateTime(DateTime dateTime) {
    try {
      return DateFormat(_transactionDateFormat).format(dateTime).toUpperCase();
    } catch (e) {
      print('Error formatting transaction DateTime: $e');
      return 'N/A';
    }
  }

  /// Formats date for debug logging: "2025-01-27 15:30"
  static String formatDebugDate(DateTime dateTime) {
    try {
      return DateFormat(_debugDateFormat).format(dateTime);
    } catch (e) {
      print('Error formatting debug date: $e');
      return 'N/A';
    }
  }

  /// Formats date for debug logging from string: "2025-01-27 15:30"
  static String formatDebugDateFromString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return formatDebugDate(date);
    } catch (e) {
      print('Error formatting debug date from string: $e');
      return dateString;
    }
  }

  /// Formats date in ISO format: "2025-01-27"
  static String formatIsoDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat(_isoDateFormat).format(date);
    } catch (e) {
      print('Error formatting ISO date: $e');
      return dateString;
    }
  }

  /// Formats DateTime object in ISO format: "2025-01-27"
  static String formatIsoDateFromDateTime(DateTime dateTime) {
    try {
      return DateFormat(_isoDateFormat).format(dateTime);
    } catch (e) {
      print('Error formatting ISO DateTime: $e');
      return 'N/A';
    }
  }

  /// Formats date in short format: "JAN 27"
  static String formatShortDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat(_shortDateFormat).format(date).toUpperCase();
    } catch (e) {
      print('Error formatting short date: $e');
      return dateString;
    }
  }

  /// Formats DateTime object in short format: "JAN 27"
  static String formatShortDateFromDateTime(DateTime dateTime) {
    try {
      return DateFormat(_shortDateFormat).format(dateTime).toUpperCase();
    } catch (e) {
      print('Error formatting short DateTime: $e');
      return 'N/A';
    }
  }

  /// Formats time in 12-hour format with AM/PM: "03:30 PM"
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

  /// Formats DateTime object time in 12-hour format with AM/PM: "03:30 PM"
  static String formatTimeFromDateTime(DateTime dateTime) {
    try {
      return DateFormat(_timeFormat).format(dateTime);
    } catch (e) {
      print('Error formatting DateTime time: $e');
      return 'N/A';
    }
  }

  /// Formats full date and time: "JAN 27 2025 MON at 03:30 PM"
  static String formatDateTime(String dateString, String timeString) {
    final formattedDate = formatDateAbbreviated(dateString);
    final formattedTime = formatTime(timeString);
    return '$formattedDate at $formattedTime';
  }

  /// Formats DateTime object for full date and time: "JAN 27 2025 MON at 03:30 PM"
  static String formatDateTimeFromDateTime(DateTime dateTime) {
    try {
      final formattedDate =
          DateFormat(_abbreviatedDateFormat).format(dateTime).toUpperCase();
      final formattedTime = DateFormat(_timeFormat).format(dateTime);
      return '$formattedDate at $formattedTime';
    } catch (e) {
      print('Error formatting DateTime: $e');
      return 'N/A';
    }
  }

  /// Gets current Philippine timestamp (UTC+8)
  static DateTime getPhilippineTime() {
    return DateTime.now().toUtc().add(const Duration(hours: 8));
  }

  /// Gets current local timestamp
  static DateTime getCurrentTime() {
    return DateTime.now();
  }

  /// Formats current Philippine timestamp: "JAN 27 2025 MON at 03:30 PM"
  static String formatCurrentPhilippineTime() {
    final phTime = getPhilippineTime();
    return formatDateTimeFromDateTime(phTime);
  }

  /// Formats current local timestamp: "JAN 27 2025 MON at 03:30 PM"
  static String formatCurrentLocalTime() {
    final now = getCurrentTime();
    return formatDateTimeFromDateTime(now);
  }

  /// Formats date string to Philippine timezone: "JAN 27 2025 MON at 03:30 PM"
  static String formatToPhilippineTime(String dateString, String timeString) {
    try {
      final date = DateTime.parse(dateString);
      final time = DateTime.parse('2000-01-01 $timeString');

      // Combine date and time, then convert to Philippine timezone
      final combined = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      final phTime = combined.toUtc().add(const Duration(hours: 8));
      return formatDateTimeFromDateTime(phTime);
    } catch (e) {
      print('Error formatting to Philippine time: $e');
      return formatDateTime(dateString, timeString);
    }
  }

  /// Safely parses date string with better error handling
  static DateTime? safeParseDate(String dateString) {
    try {
      if (dateString.isEmpty) return null;

      // Try ISO format first
      if (dateString.contains('T') || dateString.contains('Z')) {
        return DateTime.parse(dateString);
      }

      // Try common date formats
      final formats = [
        'yyyy-MM-dd',
        'MM/dd/yyyy',
        'dd/MM/yyyy',
        'yyyy/MM/dd',
        'MM-dd-yyyy',
        'dd-MM-yyyy',
      ];

      for (final format in formats) {
        try {
          return DateFormat(format).parse(dateString);
        } catch (e) {
          // Continue to next format
        }
      }

      // If all formats fail, try basic parsing
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date "$dateString": $e');
      return null;
    }
  }

  /// Checks if a date is in the future
  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Checks if a date string is in the future
  static bool isFutureDateString(String dateString) {
    final date = safeParseDate(dateString);
    return date != null && isFutureDate(date);
  }

  /// Gets the difference in days between two dates
  static int getDaysDifference(DateTime date1, DateTime date2) {
    return date1.difference(date2).inDays;
  }

  /// Gets the difference in days between a date string and current time
  static int getDaysFromNow(String dateString) {
    final date = safeParseDate(dateString);
    if (date == null) return 0;
    return getDaysDifference(date, DateTime.now());
  }

  // Legacy method aliases for backward compatibility
  /// @deprecated Use formatDateAbbreviated instead
  static String formatDepartDate(String dateString) =>
      formatDateAbbreviated(dateString);

  /// @deprecated Use formatDateAbbreviated instead
  static String formatDateForDisplay(String dateString) =>
      formatDateAbbreviated(dateString);

  /// @deprecated Use formatTime instead
  static String formatScheduleTime(String timeStr) => formatTime(timeStr);

  /// @deprecated Use formatDateAbbreviated instead
  static String formatBookingDate(String dateString) =>
      formatDateAbbreviated(dateString);

  /// @deprecated Use formatDateAbbreviated instead
  static String formatScheduleDate(String dateString) =>
      formatDateAbbreviated(dateString);
}
