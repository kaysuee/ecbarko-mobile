import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../widgets/schedule_card.dart';
import '../models/schedule_model.dart';
import '../models/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../services/notification_service.dart';
import '../utils/date_formatter.dart';
import 'completed_booking_screen.dart';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000'; // Change this to your actual base URL
}

class BookingScreen extends StatefulWidget {
  final bool showBackButton;
  final int initialTab;

  const BookingScreen(
      {Key? key, this.showBackButton = false, this.initialTab = 0})
      : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  List<BookingModel> activeBookings = [];
  Timer? _bookingCheckTimer;

  List<Schedule> allSchedules = [];

  List<Schedule> displayedSchedules = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);

    _loadActiveBooking();
    _loadBooking();
    // Set up periodic check for booking statuses (every 5 minutes)
    _bookingCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadActiveBooking();
        _loadBooking();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _bookingCheckTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${getBaseUrl()}/api/schedule'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonList = jsonDecode(response.body);

        final List<Schedule> updatedSchedule = [];
        final now = DateTime.now();

        for (var json in jsonList) {
          final schedule = Schedule.fromJson(json as Map<String, dynamic>);

          // Filter out past schedules
          try {
            // Parse the departure date and time
            final scheduleDate = DateTime.parse(schedule.departDate);
            final scheduleTime = schedule.departTime;

            print(
                'Parsing schedule: ${schedule.departDate} ${schedule.departTime}'); // Debug print

            // Use the existing _parseTime function to handle AM/PM format correctly
            final parsedTime = _parseTime(scheduleTime);

            // Create a DateTime object for the schedule departure
            final scheduleDateTime = DateTime(
              scheduleDate.year,
              scheduleDate.month,
              scheduleDate.day,
              parsedTime.hour,
              parsedTime.minute,
            );

            // Only add schedules that are in the future
            if (scheduleDateTime.isAfter(now)) {
              updatedSchedule.add(schedule);
            } else {
              print(
                  'Filtered out past schedule: ${schedule.departDate} ${schedule.departTime}');
            }
          } catch (e) {
            print('Error parsing schedule date/time: $e');
            print(
                'Schedule data: departDate=${schedule.departDate}, departTime=${schedule.departTime}');
            print('Schedule ID: ${schedule.scheduleId}'); // Add more debug info
            // If we can't parse the date, hide the schedule to be safe
            continue;
          }
        }

        // Sort schedules by departure date and time (earliest first)
        updatedSchedule.sort((a, b) {
          try {
            final aDate = DateTime.parse(a.departDate);
            final bDate = DateTime.parse(b.departDate);

            // First compare by date
            final dateComparison = aDate.compareTo(bDate);
            if (dateComparison != 0) {
              return dateComparison;
            }

            // If same date, compare by time
            final aTime = _parseTime(a.departTime);
            final bTime = _parseTime(b.departTime);
            return aTime.compareTo(bTime);
          } catch (e) {
            print('Error sorting schedules: $e');
            return 0; // Keep original order if sorting fails
          }
        });

        if (mounted) {
          setState(() {
            allSchedules = updatedSchedule;
            displayedSchedules = updatedSchedule;
          });
        }

        print(
            'Loaded ${updatedSchedule.length} available schedules (filtered from ${jsonList.length} total)');
        print('Schedules sorted by earliest departure first');

        // Debug: Show sample schedule data
        if (updatedSchedule.isNotEmpty) {
          print('🔍 DEBUG: Sample schedule data after loading:');
          for (int i = 0; i < updatedSchedule.length && i < 3; i++) {
            final schedule = updatedSchedule[i];
            print('  Schedule ${i + 1}:');
            print('    ID: ${schedule.scheduleId}');
            print(
                '    Depart Date: ${schedule.departDate} (Type: ${schedule.departDate.runtimeType})');
            print(
                '    Depart Time: ${schedule.departTime} (Type: ${schedule.departTime.runtimeType})');
            print('    From: ${schedule.departureLocation}');
            print('    To: ${schedule.arrivalLocation}');
          }
        }
      } catch (e) {
        print('Error processing schedule data: $e');
        print('Response body: ${response.body}');
      }
    }
  }

  Future<void> _loadActiveBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    print('Loading active bookings for user: $userId'); // Debug print

    if (token != null && userId != null) {
      try {
        final response = await http.get(
          Uri.parse('${getBaseUrl()}/api/actbooking/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print(
            'Active booking response status: ${response.statusCode}'); // Debug print

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(response.body);
          print('Active booking response body: $jsonList'); // Debug print

          final now = DateTime.now();

          // Filter and update bookings (same logic as dashboard)
          final List<BookingModel> updatedBookings = [];
          for (var json in jsonList) {
            final booking = BookingModel.fromJson(json as Map<String, dynamic>);

            // Parse departure date and time
            final departDate = DateTime.parse(booking.departDate);
            final departTime = _parseTime(booking.departTime);

            // Combine date and time
            final departureDateTime = DateTime(
              departDate.year,
              departDate.month,
              departDate.day,
              departTime.hour,
              departTime.minute,
            );

            // Check if booking is completed
            if (departureDateTime.isBefore(now)) {
              // Only update if bookingId is valid
              if (booking.bookingId.isNotEmpty) {
                try {
                  await _updateBookingStatus(
                      booking.bookingId, 'completed', token);
                  print(
                      'Successfully updated booking ${booking.bookingId} to completed');
                } catch (e) {
                  print('Failed to update booking ${booking.bookingId}: $e');
                  // Still add to updatedBookings even if status update fails
                  updatedBookings.add(booking);
                }
              } else {
                print('Warning: bookingId is empty, cannot update status');
                updatedBookings.add(booking);
              }
            } else {
              updatedBookings.add(booking);
            }
          }

          // Sort bookings from latest to oldest based on creation date
          updatedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          print(
              'Final active bookings count: ${updatedBookings.length}'); // Debug print

          if (mounted) {
            setState(() {
              activeBookings = updatedBookings;
            });
          }
        }
      } catch (e) {
        print('Error loading active bookings: $e');
      }
    } else {
      print('Token or userId is null'); // Debug print
    }
  }

  // Method to handle refresh
  Future<void> _handleRefresh() async {
    await Future.wait([
      _loadActiveBooking(),
      _loadBooking(),
    ]);
  }

  Future<void> _updateBookingStatus(
      String bookingId, String status, String token) async {
    try {
      print('Attempting to update booking $bookingId to status: $status');
      print('API endpoint: ${getBaseUrl()}/api/actbooking/$bookingId');

      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/actbooking/$bookingId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        print('Successfully updated booking $bookingId to $status');
      } else if (response.statusCode == 404) {
        print(
            'Booking $bookingId not found (404) - may have been deleted or ID is invalid');
        print('Response body: ${response.body}');
      } else {
        print('Failed to update booking status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating booking status: $e');
    }
  }

  DateTime _parseTime(String timeStr) {
    try {
      // Handle different time formats
      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        // Format: "03:30 AM" or "3:30 PM"
        final parts = timeStr.split(' ');
        if (parts.length != 2) {
          throw FormatException('Invalid AM/PM format: $timeStr');
        }

        final timeParts = parts[0].split(':');
        if (timeParts.length != 2) {
          throw FormatException('Invalid time format: $timeStr');
        }

        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        if (parts[1] == 'PM' && hour != 12) {
          hour += 12;
        } else if (parts[1] == 'AM' && hour == 12) {
          hour = 0;
        }

        return DateTime(2024, 1, 1, hour, minute);
      } else {
        // Format: "15:30" (24-hour)
        final timeParts = timeStr.split(':');
        if (timeParts.length != 2) {
          throw FormatException('Invalid 24-hour format: $timeStr');
        }

        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        return DateTime(2024, 1, 1, hour, minute);
      }
    } catch (e) {
      print('Error parsing time: $e');
      print('Time string: "$timeStr"');
      return DateTime(2024, 1, 1, 0, 0);
    }
  }

  // Using centralized DateFormatter instead of local function

  // Using centralized DateFormatter instead of local function

  // Using centralized DateFormatter instead of local function

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Using centralized DateFormatter instead of local function

  // Using centralized DateFormatter instead of local function

  // Using centralized DateFormatter instead of local function

  Widget _buildActiveBookingCard(BookingModel booking) {
    // Debug logging for arrival time
    print(
        '🔍 DEBUG: Booking ${booking.bookingId} arrival time: "${booking.arriveTime}" (length: ${booking.arriveTime.length})');
    print(
        '🔍 DEBUG: Booking ${booking.bookingId} arrival date: "${booking.arriveDate}" (length: ${booking.arriveDate.length})');

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // 🎫 Enhanced Header with Gradient Background (matching schedule card)
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Ec_PRIMARY,
                  Ec_PRIMARY.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                // Top row with booking ID and status (matching schedule card layout)
                Row(
                  children: [
                    // 🚢 Dynamic Logo with Background (matching schedule card style)
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: SizedBox(
                          width: 50.w,
                          height: 50.h,
                          child: _getLogoWidget(booking.shippingLine),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    // 📋 Booking Info (matching schedule card typography)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking #${booking.bookingId}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Confirmed',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 🎯 Status Badge (matching schedule card badge style)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // 🔵 LOCATIONS with enhanced design (matching schedule card layout)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            booking.departureLocation,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 🚀 Arrow with enhanced styling (matching schedule card)
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'To',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            booking.arrivalLocation,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.h),

                // 📅 Booking Date & Time Row (matching schedule card info style)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      // 📅 Calendar Icon
                      Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      // 📝 Booking Date & Time Text
                      Expanded(
                        child: Text(
                          booking.createdAt != null
                              ? 'Booked on ${DateFormatter.formatDateTimeFromDateTime(booking.createdAt)}'
                              : 'Booked date and time',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // 🕐 Time Ago
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          _getTimeAgo(booking.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 📅 Schedule Details Section (matching schedule card structure)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 DEPARTURE AND ARRIVAL TIME INFO - 2 ROWS LAYOUT - This section displays the departure and arrival information for the active booking - Row 1: Departure details (date + time) - Row 2: Arrival details (date + time) - NOTE: This may be empty if arriveDate/arriveTime are missing from database
                Column(
                  children: [
                    // 🚢 DEPARTURE CONTAINER - Row 1 - Shows: Icon + "Departure" label + Departure Date & Time
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 🚢 Departure boat icon - Blue boat icon representing departure
                          Icon(
                            Icons.directions_boat_filled,
                            color: Ec_PRIMARY,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          // "Departure" label - Text label showing "Departure"
                          Text(
                            'Departure',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // 📅 Departure Date & Time (from booking.departDate & booking.departTime) - Shows the actual departure date and time
                          Expanded(
                            child: Text(
                              '${DateFormatter.formatDateAbbreviated(booking.departDate)} ${DateFormatter.formatTime(booking.departTime)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Ec_PRIMARY,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // 📍 ARRIVAL CONTAINER - Row 2 - Shows: Icon + "Arrival" label + Arrival Date & Time - ⚠️  WARNING: This may show empty if booking.arriveDate & booking.arriveTime are null/empty - The database schema for activebooking is missing arriveDate & arriveTime fields
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 📍 Arrival location icon - Orange location icon representing arrival
                          Icon(
                            Icons.location_on,
                            color: Colors.orange,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          // "Arrival" label - Text label showing "Arrival"
                          Text(
                            'Arrival',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // 📅 Arrival Date & Time (from booking.arriveDate & booking.arriveTime) - ⚠️  ISSUE: These fields may be empty because the database schema is missing them
                          Expanded(
                            child: Text(
                              '${DateFormatter.formatDateAbbreviated(booking.arriveDate)} ${DateFormatter.formatTime(booking.arriveTime)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // 🧍‍♂️🚗 SEPARATE SLOT INDICATORS in single row (matching schedule card)
                Row(
                  children: [
                    // 🧍‍♂️ PASSENGERS CONTAINER
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.blue[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.people,
                                size: 18.sp,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Passengers',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${booking.passengers}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // 🚗 VEHICLES CONTAINER
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.blue[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                size: 18.sp,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vehicles',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  booking.hasVehicle ? '1' : '0',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // 🚀 Action Buttons (matching schedule card button style)
                Row(
                  children: [
                    // 📱 View Details Button
                    Expanded(
                      child: Container(
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Ec_PRIMARY,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () {
                            _viewBookingDetails(booking);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 16.w),

                    // 📞 Contact Support Button
                    Expanded(
                      child: Container(
                        height: 50.h,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () {
                            _showSupportDialog(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.support_agent,
                                size: 14.sp,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Get Help',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Ec_PRIMARY;
    }
  }

  void _viewBookingDetails(BookingModel booking) {
    // Navigate to booking details view (similar to e-ticket)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _buildBookingDetailsView(booking),
      ),
    );
  }

  void _manageBooking(BookingModel booking) {
    // Navigate to manage booking screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Managing booking ${booking.bookingId}'),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedDate = null;
      displayedSchedules = allSchedules;
    });
    print(
        '🔍 DEBUG: Filters reset, showing all ${allSchedules.length} schedules');
  }

  Future<void> _refreshSchedules() async {
    await _loadBooking();
    // Reset displayed schedules to show all available (filtered) schedules
    setState(() {
      displayedSchedules = allSchedules;
    });
  }

  void _filterByDate(DateTime date) {
    print('🔍 DEBUG: Starting date filter for: ${date.toString()}');
    print('🔍 DEBUG: Total schedules available: ${allSchedules.length}');

    // Debug: Show first few schedule dates
    if (allSchedules.isNotEmpty) {
      print('🔍 DEBUG: Sample schedule dates:');
      for (int i = 0; i < allSchedules.length && i < 3; i++) {
        print(
            '  Schedule ${i + 1}: ${allSchedules[i].departDate} (${allSchedules[i].departTime})');
      }
    }

    setState(() {
      selectedDate = date;
      displayedSchedules = allSchedules.where((schedule) {
        try {
          // Parse the schedule departure date
          final scheduleDate = DateTime.parse(schedule.departDate);

          print(
              '🔍 DEBUG: Comparing schedule date ${schedule.departDate} (${scheduleDate.toString()}) with filter date ${date.toString()}');

          // Compare only the date part (year, month, day)
          final matches = scheduleDate.year == date.year &&
              scheduleDate.month == date.month &&
              scheduleDate.day == date.day;

          print('🔍 DEBUG: Date match: $matches');
          return matches;
        } catch (e) {
          print('🔍 DEBUG: Error parsing schedule date for filtering: $e');
          print('🔍 DEBUG: Raw schedule date: ${schedule.departDate}');
          return false;
        }
      }).toList();

      print(
          '🔍 DEBUG: Filtered schedules for ${date.toString()}: ${displayedSchedules.length} found');

      // Debug: Show filtered results
      if (displayedSchedules.isNotEmpty) {
        print('🔍 DEBUG: Filtered schedule details:');
        for (int i = 0; i < displayedSchedules.length && i < 3; i++) {
          print(
              '  Filtered ${i + 1}: ${displayedSchedules[i].departDate} (${displayedSchedules[i].departTime})');
        }
      } else {
        print('🔍 DEBUG: No schedules found for the selected date');
      }
    });
  }

  void _searchSchedules(String query) {
    setState(() {
      displayedSchedules = allSchedules.where((schedule) {
        final destination = schedule.arrivalLocation.toLowerCase();
        final shippingLine = schedule.shippingLine.toLowerCase();
        return destination.contains(query.toLowerCase()) ||
            shippingLine.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _sortByDepartureTime() {
    setState(() {
      displayedSchedules.sort((a, b) {
        try {
          final aDate = DateTime.parse(a.departDate);
          final bDate = DateTime.parse(b.departDate);

          // First compare by date
          final dateComparison = aDate.compareTo(bDate);
          if (dateComparison != 0) {
            return dateComparison;
          }

          // If same date, compare by time
          final aTime = _parseTime(a.departTime);
          final bTime = _parseTime(b.departTime);
          return aTime.compareTo(bTime);
        } catch (e) {
          print('Error sorting schedules: $e');
          return 0; // Keep original order if sorting fails
        }
      });
    });
  }

  void _filterByDestination(String destination) {
    print('🔍 DEBUG: Filtering by destination: "$destination"');
    print('🔍 DEBUG: Total schedules available: ${allSchedules.length}');

    // Debug: Show sample destinations
    if (allSchedules.isNotEmpty) {
      print('🔍 DEBUG: Sample destinations in data:');
      for (int i = 0; i < allSchedules.length && i < 3; i++) {
        print('  Schedule ${i + 1}: "${allSchedules[i].arrivalLocation}"');
      }
    }

    setState(() {
      displayedSchedules = allSchedules.where((s) {
        final matches =
            s.arrivalLocation.toLowerCase() == destination.toLowerCase();
        print(
            '🔍 DEBUG: Schedule destination "${s.arrivalLocation}" matches "$destination": $matches');
        return matches;
      }).toList();

      print(
          '🔍 DEBUG: Filtered schedules for destination "$destination": ${displayedSchedules.length} found');
    });
  }

  void _filterByShippingLine(String line) {
    print('🔍 DEBUG: Filtering by shipping line: "$line"');
    print('🔍 DEBUG: Total schedules available: ${allSchedules.length}');

    // Debug: Show sample shipping lines
    if (allSchedules.isNotEmpty) {
      print('🔍 DEBUG: Sample shipping lines in data:');
      for (int i = 0; i < allSchedules.length && i < 3; i++) {
        print('  Schedule ${i + 1}: "${allSchedules[i].shippingLine}"');
      }
    }

    setState(() {
      displayedSchedules = allSchedules.where((s) {
        final matches =
            s.shippingLine.toLowerCase().contains(line.toLowerCase());
        print(
            '🔍 DEBUG: Schedule "${s.shippingLine}" matches "$line": $matches');
        return matches;
      }).toList();

      print(
          '🔍 DEBUG: Filtered schedules for shipping line "$line": ${displayedSchedules.length} found');
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              const Text(
                'Filter & Sort Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Sort by Departure Time'),
                onTap: () {
                  _sortByDepartureTime();
                  Navigator.pop(context);
                },
              ),
              ExpansionTile(
                leading: const Icon(Icons.place),
                title: const Text("Filter by Destination"),
                children: [
                  _buildFilterOption("Marinduque"),
                  _buildFilterOption("Banton"),
                  _buildFilterOption("Masbate"),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.directions_boat),
                title: const Text("Filter by Shipping Line"),
                children: [
                  _buildShippingLineOption("Starhorse"),
                  _buildShippingLineOption("Montenegro"),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Reset Filters'),
                onTap: () {
                  _resetFilters();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String destination) {
    return ListTile(
      title: Text(destination),
      onTap: () {
        _filterByDestination(destination);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildShippingLineOption(String line) {
    return ListTile(
      title: Text(line),
      onTap: () {
        _filterByShippingLine(line);
        Navigator.pop(context);
      },
    );
  }

  Widget _getShippingLineIcon(String shippingLine) {
    if (shippingLine.toLowerCase().contains('starhorse')) {
      return Icon(Icons.directions_boat, color: Colors.blue, size: 16.sp);
    } else if (shippingLine.toLowerCase().contains('montenegro')) {
      return Icon(Icons.directions_boat, color: Colors.purple, size: 16.sp);
    } else {
      return Icon(Icons.directions_boat, color: Colors.grey, size: 16.sp);
    }
  }

  Widget _buildBookingDetailsView(BookingModel booking) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality coming soon!')),
              );
            },
            tooltip: 'Share Booking',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // 🎫 Enhanced Booking Header Card with Gradient
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Ec_PRIMARY,
                        Ec_PRIMARY.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Ec_PRIMARY.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 🚢 Shipping Line Logo and Booking ID
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: SizedBox(
                                width: 60.w,
                                height: 60.h,
                                child: _getLogoWidget(booking.shippingLine),
                              ),
                            ),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking #${booking.bookingId}',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '${booking.shippingLine}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 🎯 Dynamic Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking.status.name),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: _getStatusColor(booking.status.name)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              booking.status.name.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // 🔵 Route Information with Enhanced Design
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'From',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    booking.departureLocation,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (booking.departurePort.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      booking.departurePort,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // 🚀 Enhanced Arrow with Animation
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'To',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    booking.arrivalLocation,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (booking.arrivalPort.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      booking.arrivalPort,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // 📅 Booking Creation Info
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Colors.white.withOpacity(0.8),
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Booked on ${DateFormatter.formatDateTimeFromDateTime(booking.createdAt)}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                _getTimeAgo(booking.createdAt),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // 🕐 Enhanced Schedule Details with Timeline
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Ec_PRIMARY,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Journey Timeline',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // 🚢 Departure Section
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Ec_PRIMARY.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Ec_PRIMARY.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Ec_PRIMARY,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_boat_filled,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Departure',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Ec_PRIMARY,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    '${DateFormatter.formatDepartDate(booking.departDate)} at ${DateFormatter.formatTime(booking.departTime)}',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // 📍 Arrival Section (if available)
                      if (booking.arriveDate.isNotEmpty &&
                          booking.arriveTime.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Arrival',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      '${DateFormatter.formatDateAbbreviated(booking.arriveDate)} at ${DateFormatter.formatTime(booking.arriveTime)}',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Show message if arrival info is missing
                      if (booking.arriveDate.isEmpty ||
                          booking.arriveTime.isEmpty)
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey[600],
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Arrival time will be updated closer to departure',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // 🧍‍♂️🚗 Enhanced Passenger & Vehicle Information
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Ec_PRIMARY,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Travel Details',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // 🧍‍♂️ Passengers Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.blue[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.people,
                                size: 24.sp,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Passengers',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    '${booking.passengers} passenger${booking.passengers > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (booking.passengerDetails.isNotEmpty) ...[
                                    SizedBox(height: 8.h),
                                    ExpansionTile(
                                      title: Text(
                                        'View Details (${booking.passengerDetails.length} passenger${booking.passengerDetails.length > 1 ? 's' : ''})',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.blue[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      children: [
                                        ...booking.passengerDetails
                                            .map((passenger) => Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 8.h),
                                                  padding: EdgeInsets.all(12.w),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.r),
                                                    border: Border.all(
                                                      color: Colors.blue[200]!,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        color: Colors.blue[600],
                                                        size: 16.sp,
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              passenger.name,
                                                              style: TextStyle(
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                            Text(
                                                              '${passenger.ticketType} - ₱${passenger.fare.toStringAsFixed(2)}',
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                            .toList(),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // 🚗 Vehicles Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.green[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                size: 24.sp,
                                color: Colors.green[700],
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vehicles',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    booking.hasVehicle
                                        ? '1 vehicle'
                                        : 'No vehicles',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (booking.hasVehicle &&
                                      booking.vehicleInfo != null) ...[
                                    SizedBox(height: 8.h),
                                    ExpansionTile(
                                      title: Text(
                                        'View Vehicle Details',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.green[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            border: Border.all(
                                              color: Colors.green[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.directions_car,
                                                    color: Colors.green[600],
                                                    size: 16.sp,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Expanded(
                                                    child: Text(
                                                      '${booking.vehicleInfo!.vehicleType}',
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.confirmation_number,
                                                    color: Colors.green[600],
                                                    size: 16.sp,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Expanded(
                                                    child: Text(
                                                      'Plate: ${booking.vehicleInfo!.plateNumber}',
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.attach_money,
                                                    color: Colors.green[600],
                                                    size: 16.sp,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Expanded(
                                                    child: Text(
                                                      'Fare: ₱${booking.vehicleInfo!.fare.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // 💰 Payment Information Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            color: Ec_PRIMARY,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Payment Details',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // 💵 Total Amount
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Ec_PRIMARY.withOpacity(0.1),
                              Ec_PRIMARY.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Ec_PRIMARY.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Ec_PRIMARY,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.attach_money,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Ec_PRIMARY,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    '₱${booking.totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // 📊 Payment Status and Method
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: _getPaymentStatusColor(
                                        booking.paymentStatus)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: _getPaymentStatusColor(
                                          booking.paymentStatus)
                                      .withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    color: _getPaymentStatusColor(
                                        booking.paymentStatus),
                                    size: 20.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    booking.paymentStatus.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _getPaymentStatusColor(
                                          booking.paymentStatus),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color: Colors.grey[600],
                                    size: 20.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Method',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    booking.paymentMethod ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // 📊 Booking Progress Indicator
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timeline,
                            color: Ec_PRIMARY,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Booking Progress',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Progress Steps
                      Column(
                        children: [
                          _buildProgressStep(
                            icon: Icons.check_circle,
                            title: 'Booking Confirmed',
                            subtitle: 'Your booking has been confirmed',
                            isCompleted: true,
                            color: Colors.green,
                          ),
                          _buildProgressStep(
                            icon: Icons.schedule,
                            title: 'Departure',
                            subtitle:
                                '${DateFormatter.formatDepartDate(booking.departDate)} at ${DateFormatter.formatTime(booking.departTime)}',
                            isCompleted: _isDeparturePassed(booking),
                            color: Ec_PRIMARY,
                          ),
                          _buildProgressStep(
                            icon: Icons.location_on,
                            title: 'Arrival',
                            subtitle: booking.arriveDate.isNotEmpty &&
                                    booking.arriveTime.isNotEmpty
                                ? '${DateFormatter.formatDateAbbreviated(booking.arriveDate)} at ${DateFormatter.formatTime(booking.arriveTime)}'
                                : 'To be updated',
                            isCompleted: _isArrivalPassed(booking),
                            color: Colors.orange,
                          ),
                          _buildProgressStep(
                            icon: Icons.flag,
                            title: 'Journey Complete',
                            subtitle: 'Trip completed successfully',
                            isCompleted:
                                booking.status == BookingStatus.completed,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // 🚀 Action Buttons Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Booking',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // 📱 View E-Ticket Button
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Ec_PRIMARY,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          onPressed: () {
                            // TODO: Navigate to e-ticket view
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('E-Ticket view coming soon!')),
                            );
                          },
                          icon: Icon(
                            Icons.qr_code,
                            size: 20.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            'View E-Ticket',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // 📞 Contact Support Button
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Ec_PRIMARY),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          onPressed: () {
                            _showSupportDialog(context);
                          },
                          icon: Icon(
                            Icons.support_agent,
                            size: 20.sp,
                            color: Ec_PRIMARY,
                          ),
                          label: Text(
                            'Contact Support',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Ec_PRIMARY,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ⚠️ Cancel Booking Button (only for active bookings)
                      if (booking.status == BookingStatus.active)
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            onPressed: () {
                              _showCancelBookingDialog(booking);
                            },
                            icon: Icon(
                              Icons.cancel,
                              size: 20.sp,
                              color: Colors.red,
                            ),
                            label: Text(
                              'Cancel Booking',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h), // Bottom spacing
              ],
            ),
          ),

          // 🚀 Floating Action Button for Quick Actions
          Positioned(
            bottom: 24.h,
            right: 24.w,
            child: FloatingActionButton.extended(
              onPressed: () {
                _showQuickActionsBottomSheet(booking);
              },
              backgroundColor: Ec_PRIMARY,
              foregroundColor: Colors.white,
              icon: Icon(Icons.more_horiz, size: 20.sp),
              label: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get payment status color
  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Method to show cancel booking confirmation dialog
  void _showCancelBookingDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Cancel Booking?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to cancel your booking #${booking.bookingId}? This action cannot be undone.',
            style: TextStyle(fontSize: 16.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Keep Booking',
                style: TextStyle(
                  color: Ec_PRIMARY,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelBooking(booking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Cancel Booking',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to handle booking cancellation
  void _cancelBooking(BookingModel booking) {
    // TODO: Implement actual cancellation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Cancellation request submitted for booking #${booking.bookingId}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Method to show quick actions bottom sheet
  void _showQuickActionsBottomSheet(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24.h),

              // Action buttons
              _buildQuickActionButton(
                icon: Icons.qr_code,
                title: 'View E-Ticket',
                subtitle: 'Show QR code for boarding',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to e-ticket view
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('E-Ticket view coming soon!')),
                  );
                },
              ),

              SizedBox(height: 12.h),

              _buildQuickActionButton(
                icon: Icons.share,
                title: 'Share Booking',
                subtitle: 'Share booking details with others',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Share functionality coming soon!')),
                  );
                },
              ),

              SizedBox(height: 12.h),

              _buildQuickActionButton(
                icon: Icons.support_agent,
                title: 'Contact Support',
                subtitle: 'Get help with your booking',
                onTap: () {
                  Navigator.pop(context);
                  _showSupportDialog(context);
                },
              ),

              if (booking.status == BookingStatus.active) ...[
                SizedBox(height: 12.h),
                _buildQuickActionButton(
                  icon: Icons.cancel,
                  title: 'Cancel Booking',
                  subtitle: 'Cancel this booking',
                  onTap: () {
                    Navigator.pop(context);
                    _showCancelBookingDialog(booking);
                  },
                  isDestructive: true,
                ),
              ],

              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build quick action button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDestructive ? Colors.red[200]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : Ec_PRIMARY.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Ec_PRIMARY,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build progress step
  Widget _buildProgressStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey[600],
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? color : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: color,
              size: 20.sp,
            ),
        ],
      ),
    );
  }

  // Method to show support dialog
  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Ec_PRIMARY,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Contact Support',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please contact our support team for assistance:',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Ec_PRIMARY.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Ec_PRIMARY.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: Ec_PRIMARY,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Phone: +63 912 345 6789',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Ec_PRIMARY,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: Ec_PRIMARY,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Email: support@ecbarko.com',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Ec_PRIMARY,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Ec_PRIMARY,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Hours: 24/7 Support',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Ec_PRIMARY,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: EdgeInsets.all(20.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Ec_PRIMARY,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to check if departure has passed
  bool _isDeparturePassed(BookingModel booking) {
    try {
      final departDate = DateTime.parse(booking.departDate);
      final departTime = _parseTime(booking.departTime);
      final departureDateTime = DateTime(
        departDate.year,
        departDate.month,
        departDate.day,
        departTime.hour,
        departTime.minute,
      );
      return departureDateTime.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Helper method to check if arrival has passed
  bool _isArrivalPassed(BookingModel booking) {
    if (booking.arriveDate.isEmpty || booking.arriveTime.isEmpty) {
      return false;
    }
    try {
      final arriveDate = DateTime.parse(booking.arriveDate);
      final arriveTime = _parseTime(booking.arriveTime);
      final arrivalDateTime = DateTime(
        arriveDate.year,
        arriveDate.month,
        arriveDate.day,
        arriveTime.hour,
        arriveTime.minute,
      );
      return arrivalDateTime.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  Future<void> _chooseSchedule() async {
    print('🔍 DEBUG: Date picker opened');
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );

    if (pickedDate != null) {
      print('🔍 DEBUG: Date selected: ${pickedDate.toString()}');
      _filterByDate(pickedDate);
    } else {
      print('🔍 DEBUG: No date selected (user cancelled)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: const Text(
          'Bookings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CompletedBookingScreen(),
              ),
            ),
            tooltip: 'View Completed Trips',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Text(
                'Active Bookings',
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
            ),
            Tab(
              child: Text(
                'Available Schedules',
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Bookings Tab
          RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  if (activeBookings.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.h),
                        child: Column(
                          children: [
                            // 🎫 Enhanced Empty State Icon
                            Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Ec_PRIMARY.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_boat,
                                size: 60.sp,
                                color: Ec_PRIMARY,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              "No Active Bookings",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "You don't have any active ferry bookings at the moment.",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20.h),
                            // 🚀 Call to Action
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.blue[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.blue[700],
                                    size: 24.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "Ready to travel?",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Switch to 'Available Schedules' to book your next trip!",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.blue[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeBookings.length,
                      itemBuilder: (context, index) {
                        return _buildActiveBookingCard(activeBookings[index]);
                      },
                    ),
                  SizedBox(height: 30.h), // Space below the last active booking
                ],
              ),
            ),
          ),

          // Available Schedules Tab (existing content)
          RefreshIndicator(
            onRefresh: _refreshSchedules,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _searchController,
                    onChanged: _searchSchedules,
                    decoration: InputDecoration(
                      hintText: 'Search by destination, port, or shipping line',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide:
                            const BorderSide(color: Ec_PRIMARY, width: 1.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildTopButtons(),
                  SizedBox(height: 20.h),
                  if (displayedSchedules.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.h),
                        child: Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 60.sp,
                                color: Ec_PRIMARY.withOpacity(0.7)),
                            SizedBox(height: 10.h),
                            Text(
                              "No schedules found.",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Ec_TEXT_COLOR_GREY,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedSchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = displayedSchedules[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 15.h),
                          child: ScheduleCard(
                            schedcde: schedule.scheduleId,
                            departureLocation: schedule.departureLocation,
                            arrivalLocation: schedule.arrivalLocation,
                            departDate: schedule.departDate,
                            departTime: schedule.departTime,
                            arriveDate: schedule.arriveDate,
                            arriveTime: schedule.arriveTime,
                            shippingLine: schedule.shippingLine,
                            passengerSlotsLeft: schedule.passengerCapacity -
                                schedule.passengerBooked,
                            vehicleSlotsLeft: schedule.vehicleCapacity -
                                schedule.vehicleBooked,
                            onBookingCompleted: () {
                              // Refresh active bookings when returning to dashboard
                              _loadActiveBooking();
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 5.w),
                child: ElevatedButton.icon(
                  onPressed: _chooseSchedule,
                  icon: const Icon(Icons.calendar_month, color: Colors.white),
                  label: Text('Choose Date',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Ec_PRIMARY,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 5.w),
                child: ElevatedButton.icon(
                  onPressed: _showSortOptions,
                  icon: const Icon(Icons.sort, color: Colors.white),
                  label: Text('Filter',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Ec_PRIMARY,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Show selected date and clear filter option
        if (selectedDate != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Ec_PRIMARY.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Ec_PRIMARY,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Filtered: ${DateFormatter.formatDateAbbreviated(selectedDate!.toString())}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Ec_PRIMARY,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _resetFilters,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Get all completed bookings
  List<BookingModel> _getCompletedBookings() {
    final now = DateTime.now();
    final completedBookings = activeBookings.where((b) {
      // Check if booking is marked as completed OR if departure date has passed
      if (b.status == BookingStatus.completed) return true;

      try {
        final departDate = DateTime.parse(b.departDate);
        final departTime = _parseTime(b.departTime);
        final departureDateTime = DateTime(
          departDate.year,
          departDate.month,
          departDate.day,
          departTime.hour,
          departTime.minute,
        );

        // Consider booking completed if departure time has passed
        return departureDateTime.isBefore(now);
      } catch (e) {
        print('Error parsing booking date/time: $e');
        return false;
      }
    }).toList()
      ..sort((a, b) => b.createdAt
          .compareTo(a.createdAt)); // Sort by creation date (most recent first)

    // Debug logging
    print('🔍 DEBUG: Total bookings: ${activeBookings.length}');
    print(
        '🔍 DEBUG: Completed bookings (including past dates): ${completedBookings.length}');
    for (var booking in activeBookings) {
      try {
        final departDate = DateTime.parse(booking.departDate);
        final departTime = _parseTime(booking.departTime);
        final departureDateTime = DateTime(
          departDate.year,
          departDate.month,
          departDate.day,
          departTime.hour,
          departTime.minute,
        );
        final isPast = departureDateTime.isBefore(now);
        print(
            '🔍 DEBUG: Booking ${booking.bookingId} - Status: ${booking.status.name} - Date: ${booking.departDate} - Is Past: $isPast');
      } catch (e) {
        print(
            '🔍 DEBUG: Booking ${booking.bookingId} - Status: ${booking.status.name} - Date: ${booking.departDate} - Parse Error: $e');
      }
    }

    return completedBookings;
  }

  // Helper method to get the appropriate logo based on shipping line
  Widget _getLogoWidget(String shippingLine) {
    if (shippingLine.toLowerCase().contains('starhorse')) {
      return Image.asset(
        'assets/images/starhorselogo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.directions_boat_filled,
            color: Colors.white.withOpacity(0.7),
            size: 24.sp,
          );
        },
      );
    } else if (shippingLine.toLowerCase().contains('montenegro')) {
      return Image.asset(
        'assets/images/montenegrologo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.directions_boat_filled,
            color: Colors.white.withOpacity(0.7),
            size: 24.sp,
          );
        },
      );
    }
    // Default logo for other shipping lines
    return Icon(
      Icons.directions_boat_filled,
      color: Colors.white.withOpacity(0.7),
      size: 24.sp,
    );
  }

  // Helper method to format schedule time (12-hour format)
  // Using centralized DateFormatter instead of local function
}
