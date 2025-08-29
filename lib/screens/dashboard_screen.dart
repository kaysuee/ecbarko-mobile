import 'package:EcBarko/screens/RFIDCard_screen.dart';
import 'package:EcBarko/screens/announcement_screen.dart';
import 'package:EcBarko/screens/buyload_screen.dart';
import 'package:EcBarko/screens/linked_card_screen.dart';
import 'package:EcBarko/screens/notification_screen.dart';
import 'package:EcBarko/screens/history_screen.dart';
import 'package:EcBarko/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../utils/responsive_utils.dart';
import 'rates_screen.dart';
import 'booking_screen.dart';
import '../controllers/dashboard_data.dart';
import '../widgets/bounce_tap_wrapper.dart';
import '../models/booking_model.dart';
import '../models/schedule_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({super.key, this.userName = "User"});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver, ResponsiveWidgetMixin {
  bool isBalanceVisible = true;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? cardData;
  List<BookingModel> activeBookings = [];
  List<Schedule> availableSchedules = [];
  bool isLoadingBookings = false;
  bool isLoadingSchedules = false;
  bool debugShowAllSchedules = false; // Set to false to enable date filtering

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadCard();
    _loadActiveBookings();
    _loadAvailableSchedules();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change (e.g., when returning to this screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        refreshDashboard();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app becomes active
      _loadActiveBookings();
      _loadAvailableSchedules();
    }
  }

  // Method to refresh dashboard data
  Future<void> refreshDashboard() async {
    await Future.wait([
      _loadActiveBookings(),
      _loadAvailableSchedules(),
      _loadUserData(),
      _loadCard(),
    ]);
  }

  // Method to handle navigation back to dashboard
  void onReturnToDashboard() {
    // Refresh data when returning to dashboard
    refreshDashboard();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token != null && userId != null) {
      print("userId is $userId");
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            userData = jsonDecode(response.body);
          });
        }
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    }
  }

  Future<void> _loadCard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token != null && userId != null) {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/card/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            cardData = jsonDecode(response.body);
          });
        }
      } else {
        print('Failed to load card data: ${response.statusCode}');
      }
    }
  }

  Future<void> _loadActiveBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userID');

    if (token != null && userId != null) {
      if (mounted) {
        setState(() {
          isLoadingBookings = true;
        });
      }

      try {
        final response = await http.get(
          Uri.parse('${getBaseUrl()}/api/actbooking/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(response.body);
          final List<BookingModel> updatedBookings = [];

          for (var json in jsonList) {
            final booking = BookingModel.fromJson(json as Map<String, dynamic>);
            updatedBookings.add(booking);
          }

          // Sort by creation date (latest first)
          updatedBookings.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });

          if (mounted) {
            setState(() {
              activeBookings = updatedBookings;
              isLoadingBookings = false;
            });
          }
        } else {
          print('Failed to load active bookings: ${response.statusCode}');
          if (mounted) {
            setState(() {
              isLoadingBookings = false;
            });
          }
        }
      } catch (e) {
        print('Error loading active bookings: $e');
        if (mounted) {
          setState(() {
            isLoadingBookings = false;
          });
        }
      }
    }
  }

  Future<void> _loadAvailableSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      if (mounted) {
        setState(() {
          isLoadingSchedules = true;
        });
      }

      try {
        final response = await http.get(
          Uri.parse('${getBaseUrl()}/api/schedule'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(response.body);
          final List<Schedule> allSchedules = [];
          final now = DateTime.now();

          print('🔍 DEBUG: Total schedules from API: ${jsonList.length}');
          print('🔍 DEBUG: Current time: $now');
          print(
              '🔍 DEBUG: Current time (formatted): ${DateFormat('yyyy-MM-dd HH:mm').format(now)}');
          print('🔍 DEBUG: Raw API response (first 3):');
          for (int i = 0; i < jsonList.length && i < 3; i++) {
            print('🔍 DEBUG: Raw [$i]: ${jsonList[i]}');
          }

          // Check for October 18 schedules in raw data
          print('🔍 DEBUG: Searching for October 18 schedules in raw data...');
          bool foundOctober18InRaw = false;
          for (var json in jsonList) {
            if (json.toString().contains('2025-10-18') ||
                json.toString().contains('10-18') ||
                json.toString().contains('Oct 18') ||
                json.toString().contains('October 18')) {
              print('🔍 DEBUG: 🎯 FOUND OCTOBER 18 IN RAW DATA: $json');
              foundOctober18InRaw = true;
            }
          }
          if (!foundOctober18InRaw) {
            print('🔍 DEBUG: ❌ NO OCTOBER 18 SCHEDULES FOUND IN RAW API DATA');
          }

          for (var json in jsonList) {
            final schedule = Schedule.fromJson(json as Map<String, dynamic>);

            print('🔍 DEBUG: Processing schedule: ${schedule.scheduleId}');
            print(
                '🔍 DEBUG: - Departure: ${schedule.departDate} ${schedule.departTime}');
            print(
                '🔍 DEBUG: - Route: ${schedule.departureLocation} → ${schedule.arrivalLocation}');

            // Filter out past schedules
            try {
              // Parse the departure date and time
              final scheduleDate = DateTime.parse(schedule.departDate);
              final scheduleTime = schedule.departTime;

              print('🔍 DEBUG: - Raw departDate: "${schedule.departDate}"');
              print('🔍 DEBUG: - Raw departTime: "${schedule.departTime}"');
              print('🔍 DEBUG: - Parsed scheduleDate: $scheduleDate');

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

              print('🔍 DEBUG: - Final scheduleDateTime: $scheduleDateTime');
              print('🔍 DEBUG: - Is Future: ${scheduleDateTime.isAfter(now)}');
              print(
                  '🔍 DEBUG: - Time difference: ${scheduleDateTime.difference(now).inDays} days');

              // Special check for October 18, 2025
              if (scheduleDateTime.year == 2025 &&
                  scheduleDateTime.month == 10 &&
                  scheduleDateTime.day == 18) {
                print('🔍 DEBUG: 🎯 FOUND OCTOBER 18, 2025 SCHEDULE!');
                print('🔍 DEBUG: 🎯 This should definitely be visible!');
                print(
                    '🔍 DEBUG: 🎯 debugShowAllSchedules: $debugShowAllSchedules');
                print(
                    '🔍 DEBUG: 🎯 scheduleDateTime.isAfter(now): ${scheduleDateTime.isAfter(now)}');
              }

              // Only add schedules that are in the future
              if (debugShowAllSchedules || scheduleDateTime.isAfter(now)) {
                allSchedules.add(schedule);
                print('🔍 DEBUG: ✅ Added to available schedules');
              } else {
                print('🔍 DEBUG: ❌ Filtered out (past schedule)');
              }
            } catch (e) {
              print('Error parsing schedule date/time: $e');
              print(
                  'Schedule data: departDate=${schedule.departDate}, departTime=${schedule.departTime}');
              // If we can't parse the date, hide the schedule to be safe
              continue;
            }
          }

          // Sort by departure date and time (earliest first)
          allSchedules.sort((a, b) {
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
              availableSchedules = allSchedules;
              isLoadingSchedules = false;
            });
          }

          print(
              '🔍 DEBUG: Loaded ${availableSchedules.length} available schedules for dashboard');
          print('🔍 DEBUG: Final availableSchedules list:');
          for (int i = 0; i < availableSchedules.length; i++) {
            final schedule = availableSchedules[i];
            print(
                '🔍 DEBUG: [$i] ${schedule.scheduleId} - ${schedule.departDate} ${schedule.departTime} - ${schedule.departureLocation} → ${schedule.arrivalLocation}');
          }
        } else {
          print('Failed to load schedules: ${response.statusCode}');
          if (mounted) {
            setState(() {
              isLoadingSchedules = false;
            });
          }
        }
      } catch (e) {
        print('Error loading schedules: $e');
        if (mounted) {
          setState(() {
            isLoadingSchedules = false;
          });
        }
      }
    }
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
        final timeParts = parts[0].split(':');
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
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        return DateTime(2024, 1, 1, hour, minute);
      }
    } catch (e) {
      print('Error parsing time: $timeStr, $e');
      return DateTime(2024, 1, 1, 0, 0);
    }
  }

  // Get the most recent active booking (including past dates)
  BookingModel? get _mostRecentActiveBooking {
    if (activeBookings.isEmpty) return null;

    // Sort by creation date (most recent first)
    activeBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return activeBookings.first;
  }

  // Get the most recent completed booking (including past dates)
  BookingModel? get _mostRecentCompletedBooking {
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

        // Include if departure time has passed
        return departureDateTime.isBefore(now);
      } catch (e) {
        print('Error parsing booking date/time: $e');
        return false; // Exclude if we can't parse the date/time
      }
    }).toList();

    if (completedBookings.isEmpty) return null;

    // Sort by creation date (most recent first)
    completedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return completedBookings.first;
  }

  // Get the most recent active (non-completed) booking
  BookingModel? get _mostRecentNonCompletedBooking {
    final now = DateTime.now();
    final nonCompletedBookings = activeBookings.where((b) {
      // Check if booking is NOT marked as completed AND departure date has NOT passed
      if (b.status == BookingStatus.completed) return false;

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

        // Only include if departure time has NOT passed
        return departureDateTime.isAfter(now);
      } catch (e) {
        print('Error parsing booking date/time: $e');
        return false; // Exclude if we can't parse the date/time
      }
    }).toList();

    if (nonCompletedBookings.isEmpty) return null;

    // Sort by creation date (most recent first)
    nonCompletedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return nonCompletedBookings.first;
  }

  // Format date for display
  String _formatDateForDisplay(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      final month = months[date.month - 1];
      final day = date.day;
      final weekday = days[date.weekday - 1];

      return '$month $day ($weekday)';
    } catch (e) {
      return dateString;
    }
  }

  String _formatScheduleDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      final month = months[date.month - 1];
      final day = date.day;
      final weekday = days[date.weekday - 1];

      return '$month $day ($weekday)';
    } catch (e) {
      return dateString;
    }
  }

  String _formatScheduleTime(String timeStr) {
    try {
      // Handle different time formats
      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        // Format: "03:30 AM" or "3:30 PM" - already in 12-hour format
        return timeStr;
      } else {
        // Format: "15:30" (24-hour) - convert to 12-hour format
        final timeParts = timeStr.split(':');
        if (timeParts.length == 2) {
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
      }
      return timeStr;
    } catch (e) {
      print('Error formatting schedule time: $e');
      return timeStr;
    }
  }

  // Helper methods for booking status
  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.active:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.active:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
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

  Color _getScheduleColor(String shippingLine) {
    switch (shippingLine) {
      case 'M/V Barko':
        return Ec_PRIMARY;
      case 'M/V Barko 2':
        return Ec_SECONDARY;
      case 'M/V Barko 3':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Hello, ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: userData?['name'] ?? 'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await refreshDashboard();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            // top: MediaQuery.of(context).padding.top + 5.h,
            top: 0,
            left: 5.w,
            right: 5.w,
            bottom: 80.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRFIDImage(context),
              SizedBox(height: 3.h),

              _buildCardActionRow(context),
              SizedBox(height: 3.h),

              _buildAnnouncementSection(context),
              SizedBox(height: 3.h),

              // Show active booking if exists
              if (_mostRecentNonCompletedBooking != null) ...[
                _buildActiveBookingCard(context),
                SizedBox(height: 20.h), // More space below active booking
              ] else if (isLoadingBookings) ...[
                _buildLoadingBookingCard(context),
                SizedBox(height: 20.h), // More space below loading card
              ] else if (activeBookings.isEmpty) ...[
                _buildNoBookingsCard(context),
                SizedBox(height: 20.h), // More space below no bookings card
              ],

              _buildBookSection(context),
              SizedBox(height: 3.h),
              SizedBox(height: 10.h),
              _buildRateCards(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildRFIDImage(BuildContext context) {
  //   return BounceTapWrapper(
  //     onTap: () =>
  //         _navigateTo(context, const RFIDCardScreen(showBackButton: true)),
  //     child: Card(
  //       color: Ec_PRIMARY,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16.r),
  //       ),
  //       elevation: 8,
  //       margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
  //       child: Container(
  //         width: double.infinity,
  //         height: 220.h,
  //         padding: EdgeInsets.all(18.w),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(16.r),
  //           gradient: const RadialGradient(
  //             center: Alignment.center,
  //             radius: 1.0,
  //             colors: [
  //               Color(0xFF1A5A91),
  //               Color(0xFF142F60),
  //             ],
  //             stops: [0.3, 1.0],
  //           ),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Image.asset(
  //                   'assets/images/ecbarkowhitelogo.png',
  //                   width: 60.w,
  //                   height: 60.w,
  //                 ),
  //                 Text(
  //                   'RFID CARD',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 25.sp,
  //                     fontWeight: FontWeight.w700,
  //                     letterSpacing: 1.2,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 30.h),
  //             Row(
  //               children: [
  //                 Text(
  //                   'Available Balance',
  //                   style: TextStyle(
  //                     color: Colors.white.withOpacity(0.9),
  //                     fontSize: 25.sp,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //                 SizedBox(width: 8.w),
  //                 GestureDetector(
  //                   onTap: () {
  //                     setState(() {
  //                       isBalanceVisible = !isBalanceVisible;
  //                     });
  //                   },
  //                   child: Icon(
  //                     isBalanceVisible
  //                         ? Icons.visibility
  //                         : Icons.visibility_off,
  //                     color: Colors.white.withOpacity(0.8),
  //                     size: 25.sp,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 4.h),
  //             Text(
  //               isBalanceVisible == true
  //                   ? '₱${(cardData?['balance']?.toString() ?? '0').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}'
  //                   : '•••••••••',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 40.sp,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildRFIDImage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Use a fraction of screen height for the card height
    final cardHeight = screenHeight * 0.28; // ~28% of screen height

    return BounceTapWrapper(
      onTap: () =>
          _navigateTo(context, const RFIDCardScreen(showBackButton: true)),
      child: Card(
        color: Ec_PRIMARY,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(screenWidth * 0.04), // 4% of width
        ),
        elevation: 8,
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, // 3% horizontal margin
          vertical: screenHeight * 0.01, // 1% vertical margin
        ),
        child: Container(
          width: double.infinity,
          height: cardHeight,
          padding: EdgeInsets.all(screenWidth * 0.045), // 4.5% padding
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Color(0xFF1A5A91),
                Color(0xFF142F60),
              ],
              stops: [0.3, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/ecbarkowhitelogo.png',
                    width: screenWidth * 0.11, // reduced from 0.13 to 0.11
                    height: screenWidth * 0.11,
                  ),
                  Text(
                    'RFID CARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          screenWidth * 0.055, // reduced from 0.065 to 0.055
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04), // 4% spacing
              Row(
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize:
                          screenWidth * 0.035, // reduced from 0.040 to 0.035
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isBalanceVisible = !isBalanceVisible;
                      });
                    },
                    child: Icon(
                      isBalanceVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white.withOpacity(0.8),
                      size: screenWidth * 0.055, // reduced from 0.065 to 0.055
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.005),
              Flexible(
                child: Text(
                  isBalanceVisible
                      ? '₱${(cardData?['balance']?.toString() ?? '0').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}'
                      : '••••••',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.055, // reduced from 0.08 to 0.055
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardActionRow(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Ec_PRIMARY.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCardActionButton(
            context,
            icon: Icons.add_circle_outline,
            label: 'Load',
            onTap: () {
              print('🔄 Load button tapped!');
              _navigateTo(context, const BuyLoadScreen());
            },
          ),
          _buildCardActionButton(
            context,
            icon: Icons.credit_card,
            label: 'Link Card',
            onTap: () => _navigateTo(context, const LinkedCardScreen()),
          ),
          _buildCardActionButton(
            context,
            icon: Icons.history,
            label: 'History',
            onTap: () => _navigateTo(context, const HistoryScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Ec_PRIMARY, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Ec_PRIMARY,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementSection(BuildContext context) {
    // Sample announcement data - in a real app, this would come from an API or service
    final List<Map<String, String>> announcements = [
      {
        'title': '🌪️ Weather Advisory: Ferry Cancellations',
        'body':
            'Due to severe weather conditions, all ferry operations for today (May 15, 2025) have been cancelled. Please check our app for updates on rescheduled trips. Stay safe!'
      },
      {
        'title': '⚠️ Scheduled Maintenance',
        'body':
            'EcBarko will undergo maintenance on May 12, 2025, from 12:00 AM to 4:00 AM. During this time, ticketing and tracking features will be temporarily unavailable.'
      },
      {
        'title': '📱 New Feature Alert',
        'body':
            'Real-time ferry tracking is now live! Tap on "Track Ferry" from your dashboard to see estimated arrival and departure times.'
      },
      {
        'title': '🇵🇭 Independence Day Advisory',
        'body':
            'In observance of Independence Day, there will be no ferry operations on June 12, 2025. Please plan your trips accordingly.'
      },
      {
        'title': '🎫 Ticket Booking Reminder',
        'body':
            'Booking your ticket at least 24 hours before departure is highly recommended to avoid long queues and ensure a smooth boarding process.'
      },
    ];

    final latestAnnouncement = announcements.first;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AnnouncementScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Ec_PRIMARY.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Ec_PRIMARY.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: Ec_PRIMARY,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest Announcement',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Ec_PRIMARY,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        latestAnnouncement['title']!,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        latestAnnouncement['body']!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: Ec_TEXT_COLOR_GREY,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 16.sp,
                            color: Ec_PRIMARY.withOpacity(0.7),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Tap to view all announcements',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Ec_PRIMARY.withOpacity(0.7),
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
        ),
      ),
    );
  }

  // Active Booking Card Widget - Only shows active (non-completed) bookings
  Widget _buildActiveBookingCard(BuildContext context) {
    final booking = _mostRecentNonCompletedBooking;
    if (booking == null) return Container(); // No active bookings to show

    return BounceTapWrapper(
      onTap: () => _navigateTo(
        context,
        const BookingScreen(showBackButton: true),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple header
            Row(
              children: [
                Icon(
                  _getStatusText(booking.status) == 'Completed'
                      ? Icons.check_circle_outline
                      : Icons.check_circle,
                  color: _getStatusText(booking.status) == 'Completed'
                      ? Colors.grey[600]
                      : Colors.green,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  _getStatusText(booking.status) == 'Completed'
                      ? 'Completed Trip'
                      : 'Active Booking',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: _getStatusText(booking.status) == 'Completed'
                        ? Colors.grey[700]
                        : Ec_PRIMARY,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Route info - simple horizontal layout
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Ec_TEXT_COLOR_GREY,
                        ),
                      ),
                      Text(
                        booking.departureLocation,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Ec_BLACK,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Ec_PRIMARY,
                  size: 20.sp,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'To',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Ec_TEXT_COLOR_GREY,
                        ),
                      ),
                      Text(
                        booking.arrivalLocation,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Ec_BLACK,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Simple info row
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16.sp,
                  color: Ec_TEXT_COLOR_GREY,
                ),
                SizedBox(width: 8.w),
                Text(
                  '${_formatDateForDisplay(booking.departDate)} at ${_formatScheduleTime(booking.departTime)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Ec_BLACK,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Passengers and shipping line
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16.sp,
                  color: Ec_TEXT_COLOR_GREY,
                ),
                SizedBox(width: 8.w),
                Text(
                  '${booking.passengers} passenger${booking.passengers == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Ec_BLACK,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  booking.shippingLine,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Ec_TEXT_COLOR_GREY,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            if (booking.hasVehicle && booking.vehicleInfo != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 16.sp,
                    color: Ec_TEXT_COLOR_GREY,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Vehicle included',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Ec_BLACK,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 16.h),

            // Action button - different for completed vs active
            if (_getStatusText(booking.status) == 'Completed') ...[
              // Completed trip indicator
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.grey[600],
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Trip Completed',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Active booking action button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Ec_PRIMARY,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Active Booking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Completed Bookings Section Widget
  Widget _buildCompletedBookingsSection(BuildContext context) {
    final completedBookings = _getCompletedBookings();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(
                Icons.history,
                color: Colors.grey[600],
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Completed Trips',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${completedBookings.length} trip${completedBookings.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Completed Bookings List
          ...completedBookings
              .map((booking) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildCompletedBookingItem(booking),
                  ))
              .toList(),

          SizedBox(height: 8.h),

          // View All Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility,
                  color: Colors.grey[600],
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'View All Completed Trips',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Individual Completed Booking Item Widget
  Widget _buildCompletedBookingItem(BookingModel booking) {
    final now = DateTime.now();
    bool isPastDeparture = false;

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
      isPastDeparture = departureDateTime.isBefore(now);
    } catch (e) {
      print('Error parsing booking date/time: $e');
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route info with status indicator
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      booking.departureLocation,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.grey[500],
                size: 16.sp,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      booking.arrivalLocation,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Trip details with completion status
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14.sp,
                color: Colors.grey[500],
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '${_formatDateForDisplay(booking.departDate)} at ${_formatScheduleTime(booking.departTime)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${booking.passengers} pax',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Completion status indicator
          Row(
            children: [
              Icon(
                booking.status == BookingStatus.completed
                    ? Icons.check_circle
                    : Icons.schedule,
                size: 14.sp,
                color: booking.status == BookingStatus.completed
                    ? Colors.green[600]
                    : Colors.grey[500],
              ),
              SizedBox(width: 6.w),
              Text(
                booking.status == BookingStatus.completed
                    ? 'Marked as completed'
                    : 'Trip date has passed',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: booking.status == BookingStatus.completed
                      ? Colors.green[700]
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (booking.hasVehicle && booking.vehicleInfo != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 14.sp,
                  color: Colors.grey[500],
                ),
                SizedBox(width: 6.w),
                Text(
                  'Vehicle included',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBookingCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.hourglass_empty,
                  color: Colors.yellow,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Loading Booking...',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Ec_PRIMARY,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Please wait while we fetch your booking.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Ec_TEXT_COLOR_GREY,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBookingsCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.red,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'No Bookings',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Ec_PRIMARY,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'You currently have no active bookings. Book a new trip to get started!',
            style: TextStyle(
              fontSize: 14.sp,
              color: Ec_TEXT_COLOR_GREY,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookSection(BuildContext context) {
    // Use real schedule data from database, take first 3 available schedules
    final schedules = availableSchedules.take(3).toList();

    print('🔍 DEBUG: _buildBookSection called');
    print('🔍 DEBUG: availableSchedules.length: ${availableSchedules.length}');
    print('🔍 DEBUG: schedules to display (first 3): ${schedules.length}');
    for (int i = 0; i < schedules.length; i++) {
      final schedule = schedules[i];
      print(
          '🔍 DEBUG: Display [$i]: ${schedule.scheduleId} - ${schedule.departDate} ${schedule.departTime}');
    }

    return BounceTapWrapper(
      onTap: () => _navigateTo(
        context,
        const BookingScreen(showBackButton: true, initialTab: 1),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Ec_PRIMARY.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.directions_boat_rounded,
                        color: Ec_PRIMARY,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Book a Trip',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Ec_PRIMARY,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Ec_PRIMARY,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),
            if (isLoadingSchedules)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: CircularProgressIndicator(
                    color: Ec_PRIMARY,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (schedules.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 40.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No schedules available',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: schedules.asMap().entries.map((entry) {
                  final index = entry.key;
                  final schedule = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index < schedules.length - 1 ? 8.h : 0),
                    child: _buildEnhancedScheduleCard(
                      date: _formatScheduleDate(schedule.departDate),
                      from: schedule.departureLocation,
                      to: schedule.arrivalLocation,
                      time: _formatScheduleTime(schedule.departTime),
                      bgColor: _getScheduleColor(schedule.shippingLine),
                    ),
                  );
                }).toList(),
              ),
            SizedBox(height: 10.h),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Ec_PRIMARY.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Ec_PRIMARY.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Schedules',
                      style: TextStyle(
                        color: Ec_PRIMARY,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Ec_PRIMARY,
                      size: 14.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedScheduleCard({
    required String date,
    required String from,
    required String to,
    required String time,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Ec_BG_SKY_BLUE,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Ec_PRIMARY.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Ec_PRIMARY,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Text(
                  date.split(' ')[0],
                  style: TextStyle(
                    color: Ec_WHITE,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date.split(' ')[1],
                  style: TextStyle(
                    color: Ec_WHITE,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10.sp,
                      color: Ec_PRIMARY,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      from,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Ec_BLACK,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 4.w),
                  height: 14.h,
                  width: 2.w,
                  color: Ec_TEXT_COLOR_GREY.withOpacity(0.3),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 10.sp,
                      color: Ec_PRIMARY,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      to,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Ec_BLACK,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Ec_WHITE,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Ec_PRIMARY,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCards(BuildContext context) {
    final rateItems = DashboardData.getRateItems();

    return BounceTapWrapper(
      onTap: () => _navigateTo(
        context,
        const RatesScreen(showBackButton: true),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Ec_PRIMARY.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.attach_money_rounded,
                        color: Ec_PRIMARY,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Ferry Rates',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Ec_PRIMARY,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Ec_PRIMARY,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'View Rates',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: rateItems.map((item) {
                final isVehicle = item['label']
                        ?.toString()
                        .toLowerCase()
                        .contains('vehicle') ??
                    false;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: BounceTapWrapper(
                      onTap: () => _navigateTo(
                        context,
                        RatesScreen(
                          showBackButton: true,
                          initialVehicleTab: isVehicle,
                        ),
                      ),
                      child: Container(
                        // height: 105.h,
                        decoration: BoxDecoration(
                          color: item['bgColor'] ?? Ec_BG_SKY_BLUE,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Ec_PRIMARY.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['label'] ?? '',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: item['textColor'] ?? Ec_BLACK,
                              ),
                            ),
                            if (item['imagePath'] != null)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  item['imagePath'].toString(),
                                  height: 50.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 10.h),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Ec_PRIMARY.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Ec_PRIMARY.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All Rates',
                      style: TextStyle(
                        color: Ec_PRIMARY,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Ec_PRIMARY,
                      size: 14.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    print('🔍 Navigating to: ${screen.runtimeType}');
    try {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      print('✅ Navigation successful');
    } catch (e) {
      print('❌ Navigation failed: $e');
    }
  }
}
