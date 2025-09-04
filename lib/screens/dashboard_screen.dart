import 'package:EcBarko/screens/RFIDCard_screen.dart';
import 'package:EcBarko/screens/announcement_screen.dart';
import 'package:EcBarko/screens/buyload_screen.dart';
import 'package:EcBarko/screens/linked_card_screen.dart';
import 'package:EcBarko/screens/notification_screen.dart';
import 'package:EcBarko/screens/history_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../utils/responsive_utils.dart';
import '../utils/date_format.dart';
import 'rates_screen.dart';
import 'active_booking_screen.dart';
import 'schedule_screen.dart';
import '../controllers/dashboard_data.dart';
import '../widgets/bounce_tap_wrapper.dart';
import '../widgets/card_action_row.dart';
import '../models/booking_model.dart';
import '../models/announcement_model.dart';
import '../models/schedule_model.dart';
// import '../services/error_service.dart'; // Temporarily commented out
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/background_refresh_service.dart';
import '../services/network_status_service.dart';
import '../services/debug_service.dart';
import '../services/api_test_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<AnnouncementModel> announcements = [];
  List<Map<String, dynamic>> upcomingSchedules = [];
  bool isLoadingBookings = false;
  bool isLoadingAnnouncements = false;
  bool isLoadingUserData = false;
  bool isLoadingCardData = false;
  bool isLoadingNotifications = false;
  bool isLoadingSchedules = false;
  bool isInitialLoading = true;
  int unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startNetworkMonitoring();
    _startDebugMonitoring();
    _loadDashboardData();
    _startBackgroundRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change (e.g., when returning to this screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDashboardData(forceRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopBackgroundRefresh();
    _stopNetworkMonitoring();
    _stopDebugMonitoring();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app becomes active
      _loadDashboardData(forceRefresh: true);
    }
  }

  // Optimized dashboard data loading with caching
  Future<void> _loadDashboardData({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userID');

      if (userId == null) {
        debugPrint('❌ No user ID found for dashboard loading');
        return;
      }

      debugPrint('🔄 Loading dashboard data (forceRefresh: $forceRefresh)');

      // Set loading states
      if (mounted) {
        setState(() {
          isLoadingBookings = true;
          isLoadingAnnouncements = true;
          isLoadingUserData = true;
          isLoadingCardData = true;
          isLoadingNotifications = true;
          if (isInitialLoading) {
            isInitialLoading = false;
          }
        });
      }

      // Load all data in parallel using cache
      final results = await Future.wait([
        DashboardCache.getUserData(userId, forceRefresh: forceRefresh),
        DashboardCache.getCardData(userId, forceRefresh: forceRefresh),
        DashboardCache.getActiveBookings(userId, forceRefresh: forceRefresh),
        DashboardCache.getAnnouncements(userId, forceRefresh: forceRefresh),
        DashboardCache.getUnreadNotificationCount(userId,
            forceRefresh: forceRefresh),
        _loadUpcomingSchedules(forceRefresh: forceRefresh),
      ]);

      // Debug logging for each result
      debugPrint('🔍 Dashboard data results:');
      debugPrint('  - User Data: ${results[0] != null ? 'Loaded' : 'Null'}');
      debugPrint('  - Card Data: ${results[1] != null ? 'Loaded' : 'Null'}');
      debugPrint('  - Active Bookings: ${(results[2] as List).length} items');
      debugPrint('  - Announcements: ${(results[3] as List).length} items');
      debugPrint('  - Notification Count: ${results[4]}');
      debugPrint(
          '  - Upcoming Schedules: ${(results[5] as List).length} items');

      // Debug schedule data
      final scheduleData = results[5] as List<Map<String, dynamic>>;
      if (scheduleData.isNotEmpty) {
        debugPrint('📅 Sample schedule data:');
        for (int i = 0; i < scheduleData.length && i < 3; i++) {
          final schedule = scheduleData[i];
          debugPrint(
              '  Schedule ${i + 1}: ${schedule['departureLocation']} -> ${schedule['arrivalLocation']} on ${schedule['departDate']} at ${schedule['departTime']}');
        }
      } else {
        debugPrint('❌ No schedule data received from API');
      }

      if (mounted) {
        setState(() {
          userData = results[0] as Map<String, dynamic>?;
          cardData = results[1] as Map<String, dynamic>?;
          activeBookings = (results[2] as List<Map<String, dynamic>>)
              .map((json) => BookingModel.fromJson(json))
              .toList();
          announcements = (results[3] as List<Map<String, dynamic>>)
              .map((json) => AnnouncementModel.fromJson(json))
              .toList();
          unreadNotificationCount = results[4] as int;
          upcomingSchedules = results[5] as List<Map<String, dynamic>>;
          isLoadingBookings = false;
          isLoadingAnnouncements = false;
          isLoadingUserData = false;
          isLoadingCardData = false;
          isLoadingNotifications = false;
          isLoadingSchedules = false;
        });
      }

      debugPrint('✅ Dashboard data loaded successfully');

      // Run API tests to help debug any issues
      _runApiTests(userId);
    } catch (e) {
      debugPrint('❌ Error loading dashboard data: $e');

      // Show user-friendly error message for API failures
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        debugPrint(
            '🌐 Network error detected, showing cached data if available');
        // The cache service will handle fallback to cached data
      }

      // Run API tests to help debug the error
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userID');
      if (userId != null) {
        _runApiTests(userId);
      }

      if (mounted) {
        setState(() {
          isLoadingBookings = false;
          isLoadingAnnouncements = false;
          isLoadingUserData = false;
          isLoadingCardData = false;
          isLoadingNotifications = false;
          isLoadingSchedules = false;
        });
      }
    }
  }

  // Method to refresh dashboard data (for pull-to-refresh)
  Future<void> refreshDashboard() async {
    await _loadDashboardData(forceRefresh: true);
  }

  // Load upcoming schedules for dashboard
  Future<List<Map<String, dynamic>>> _loadUpcomingSchedules(
      {bool forceRefresh = false}) async {
    try {
      setState(() {
        isLoadingSchedules = true;
      });

      debugPrint('🔄 Loading upcoming schedules...');
      final response = await ApiService.get('/api/schedule');
      final responseData = await ApiService.handleResponse(response);
      final List<dynamic> jsonList = responseData as List<dynamic>;
      final List<Map<String, dynamic>> schedules = [];
      final now = DateFormatUtil.getCurrentTime();

      debugPrint('📅 Current time: $now');
      debugPrint('📊 Total schedules from API: ${jsonList.length}');

      for (var json in jsonList) {
        final schedule = json as Map<String, dynamic>;

        try {
          final scheduleDate =
              DateFormatUtil.safeParseDate(schedule['departDate']);
          if (scheduleDate == null) {
            debugPrint('⚠️ Could not parse date: ${schedule['departDate']}');
            continue;
          }

          final scheduleTime = schedule['departTime'] as String;
          final parsedTime = _parseTime(scheduleTime);

          final scheduleDateTime = DateTime(
            scheduleDate.year,
            scheduleDate.month,
            scheduleDate.day,
            parsedTime.hour,
            parsedTime.minute,
          );

          debugPrint(
              '📅 Schedule: ${schedule['departDate']} ${schedule['departTime']} -> $scheduleDateTime');
          debugPrint('📅 Is future: ${scheduleDateTime.isAfter(now)}');

          // Only add future schedules
          if (scheduleDateTime.isAfter(now)) {
            schedules.add(schedule);
            debugPrint(
                '✅ Added schedule: ${schedule['departureLocation']} -> ${schedule['arrivalLocation']}');
          } else {
            debugPrint(
                '❌ Skipped past schedule: ${schedule['departureLocation']} -> ${schedule['arrivalLocation']}');
          }
        } catch (e) {
          debugPrint('❌ Error parsing schedule: $e');
          debugPrint('❌ Schedule data: $schedule');
          continue;
        }
      }

      debugPrint('📊 Upcoming schedules found: ${schedules.length}');

      // Sort by departure date and time
      schedules.sort((a, b) {
        try {
          final aDate = DateFormatUtil.safeParseDate(a['departDate']);
          final bDate = DateFormatUtil.safeParseDate(b['departDate']);
          if (aDate == null || bDate == null) return 0;

          final dateComparison = aDate.compareTo(bDate);
          if (dateComparison != 0) return dateComparison;

          final aTime = _parseTime(a['departTime']);
          final bTime = _parseTime(b['departTime']);
          return aTime.compareTo(bTime);
        } catch (e) {
          return 0;
        }
      });

      debugPrint('✅ Returning ${schedules.length} upcoming schedules');

      // If no schedules found, return some test data for debugging
      if (schedules.isEmpty) {
        debugPrint('⚠️ No schedules found, returning test data for debugging');
        final now = DateTime.now();
        final tomorrow = now.add(Duration(days: 1));
        final dayAfter = now.add(Duration(days: 2));

        return [
          {
            'departureLocation': 'Lucena',
            'arrivalLocation': 'Marinduque',
            'departDate':
                '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}',
            'departTime': '14:00',
            'shippingLine': 'Starhorse Lines'
          },
          {
            'departureLocation': 'Lucena',
            'arrivalLocation': 'Marinduque',
            'departDate':
                '${dayAfter.year}-${dayAfter.month.toString().padLeft(2, '0')}-${dayAfter.day.toString().padLeft(2, '0')}',
            'departTime': '10:00',
            'shippingLine': 'Montenegro Lines'
          }
        ];
      }

      return schedules;
    } catch (e) {
      debugPrint('❌ Error loading upcoming schedules: $e');
      // Return test data even on error for debugging
      debugPrint('⚠️ Returning test data due to error');
      final now = DateTime.now();
      final tomorrow = now.add(Duration(days: 1));
      final dayAfter = now.add(Duration(days: 2));

      return [
        {
          'departureLocation': 'Lucena',
          'arrivalLocation': 'Marinduque',
          'departDate':
              '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}',
          'departTime': '14:00',
          'shippingLine': 'Starhorse Lines'
        },
        {
          'departureLocation': 'Lucena',
          'arrivalLocation': 'Marinduque',
          'departDate':
              '${dayAfter.year}-${dayAfter.month.toString().padLeft(2, '0')}-${dayAfter.day.toString().padLeft(2, '0')}',
          'departTime': '10:00',
          'shippingLine': 'Montenegro Lines'
        }
      ];
    }
  }

  // Start background refresh service
  void _startBackgroundRefresh() {
    BackgroundRefreshService.startBackgroundRefresh();
  }

  // Stop background refresh service
  void _stopBackgroundRefresh() {
    BackgroundRefreshService.stopBackgroundRefresh();
  }

  // Start network monitoring
  void _startNetworkMonitoring() {
    NetworkStatusService.startMonitoring();
  }

  // Stop network monitoring
  void _stopNetworkMonitoring() {
    NetworkStatusService.stopMonitoring();
  }

  // Start debug monitoring
  void _startDebugMonitoring() {
    DebugService.startDebugMonitoring();
  }

  // Stop debug monitoring
  void _stopDebugMonitoring() {
    DebugService.stopDebugMonitoring();
  }

  // Run API tests for debugging
  void _runApiTests(String userId) async {
    try {
      debugPrint('🧪 Running API tests for debugging...');
      final testResults = await ApiTestService.testAllEndpoints(userId);

      debugPrint('📊 API Test Results:');
      final summary = testResults['summary'] as Map<String, dynamic>;
      debugPrint('  - Success Rate: ${summary['successRate']}');
      debugPrint(
          '  - Successful: ${summary['successfulEndpoints']}/${summary['totalEndpoints']}');

      final health = ApiTestService.getEndpointHealth(testResults);
      for (final entry in health.entries) {
        debugPrint('  - ${entry.key}: ${entry.value}');
      }

      // Log specific issues
      final results = testResults['results'] as Map<String, dynamic>;
      for (final entry in results.entries) {
        final result = entry.value as Map<String, dynamic>;
        if (result['success'] != true) {
          debugPrint('❌ ${entry.key} failed: ${result['error']}');
        }
      }

      // Test active bookings specifically
      await _testActiveBookingsDirectly(userId);
    } catch (e) {
      debugPrint('❌ Error running API tests: $e');
    }
  }

  // Test active bookings API directly
  Future<void> _testActiveBookingsDirectly(String userId) async {
    try {
      debugPrint('🔍 Testing active bookings API directly...');

      // Test via ApiService (dashboard method)
      final apiServiceResponse =
          await ApiService.get('/api/actbooking/$userId');
      final apiServiceData =
          await ApiService.handleResponse(apiServiceResponse);
      debugPrint(
          '  - ApiService response: ${apiServiceData is List ? (apiServiceData as List).length : 'Not a list'} items');

      // Test via direct HTTP (active booking screen method)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final directResponse = await http.get(
          Uri.parse('${getBaseUrl()}/api/actbooking/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (directResponse.statusCode == 200) {
          final directData = jsonDecode(directResponse.body);
          debugPrint(
              '  - Direct HTTP response: ${directData is List ? (directData as List).length : 'Not a list'} items');
        } else {
          debugPrint('  - Direct HTTP failed: ${directResponse.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error testing active bookings directly: $e');
    }
  }

  // Method to handle navigation back to dashboard
  void onReturnToDashboard() {
    // Refresh data when returning to dashboard
    refreshDashboard();
  }

  Future<void> _updateBookingStatus(
      String bookingId, String status, String token) async {
    try {
      debugPrint('Attempting to update booking $bookingId to status: $status');
      debugPrint('API endpoint: ${getBaseUrl()}/api/actbooking/$bookingId');

      try {
        await ApiService.put(
          '/api/actbooking/$bookingId',
          body: {'status': status},
        );
        debugPrint('Successfully updated booking $bookingId to $status');

        // Clear bookings cache to force refresh
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userID');
        if (userId != null) {
          await CacheService.clearCache('cached_bookings_$userId');
          // Refresh bookings data
          _loadDashboardData(forceRefresh: true);
        }
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          debugPrint(
              'Booking $bookingId not found (404) - may have been deleted or ID is invalid');
        } else {
          debugPrint('Failed to update booking status: ${e.statusCode}');
        }
        debugPrint('❌ API Exception: ${e.message}');
        // Handle API error gracefully
      } catch (e) {
        debugPrint('❌ General Error: $e');
        // Handle general error gracefully
      }
    } catch (e) {
      debugPrint('❌ General Error: $e');
      // Handle general error gracefully
    }
  }

  DateTime _parseTime(String timeStr) {
    try {
      final now = DateTime.now();
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

        return DateTime(now.year, 1, 1, hour, minute);
      } else {
        // Format: "15:30" (24-hour)
        final timeParts = timeStr.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        return DateTime(now.year, 1, 1, hour, minute);
      }
    } catch (e) {
      debugPrint('Error parsing time: $timeStr, $e');
      final now = DateTime.now();
      return DateTime(now.year, 1, 1, 0, 0);
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
    final now = DateFormatUtil.getCurrentTime();
    final completedBookings = activeBookings.where((b) {
      // Check if booking is marked as completed OR if departure date has passed
      if (b.status == BookingStatus.completed) return true;

      try {
        final departDate = DateFormatUtil.safeParseDate(b.departDate);
        if (departDate == null) return false;

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
    final now = DateFormatUtil.getCurrentTime();
    final nonCompletedBookings = activeBookings.where((b) {
      // Check if booking is NOT marked as completed AND departure date has NOT passed
      if (b.status == BookingStatus.completed) return false;

      try {
        final departDate = DateFormatUtil.safeParseDate(b.departDate);
        if (departDate == null) return false;

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
      final date = DateFormatUtil.safeParseDate(dateString);
      if (date == null) return dateString;

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
    debugPrint('🔍 DEBUG: Total bookings: ${activeBookings.length}');
    debugPrint(
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
        debugPrint(
            '🔍 DEBUG: Booking ${booking.bookingId} - Status: ${booking.status.name} - Date: ${booking.departDate} - Is Past: $isPast');
      } catch (e) {
        debugPrint(
            '🔍 DEBUG: Booking ${booking.bookingId} - Status: ${booking.status.name} - Date: ${booking.departDate} - Parse Error: $e');
      }
    }

    return completedBookings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  size: 28,
                ),
                iconSize: 28,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationScreen()),
                ),
              ),
              if (unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
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

            top: 10.h,
            left: 5.w,
            right: 5.w,
            bottom: 80.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRFIDImage(context),
              SizedBox(height: 10.h),

              CardActionRow(
                onLoadTap: () {
                  debugPrint('🔄 Load button tapped!');
                  _navigateTo(context, const BuyLoadScreen());
                },
                onLinkCardTap: () =>
                    _navigateTo(context, const LinkedCardScreen()),
                onHistoryTap: () => _navigateTo(context, const HistoryScreen()),
              ),
              SizedBox(height: 10.h),

              _buildAnnouncementSection(context),
              SizedBox(height: 10.h),

              // Show active booking if exists
              if (_mostRecentNonCompletedBooking != null) ...[
                _buildActiveBookingCard(context),
                SizedBox(height: 10.h), // More space below active booking
              ] else if (isLoadingBookings) ...[
                _buildLoadingBookingCard(context),
                SizedBox(height: 10.h), // More space below loading card
              ] else if (activeBookings.isEmpty) ...[
                _buildNoBookingsCard(context),
                SizedBox(height: 10.h), // More space below no bookings card
              ],

              // Available Schedules Summary
              _buildAvailableSchedulesSummary(context),
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
          padding:
              EdgeInsets.all(screenWidth * 0.06), // 6% padding for all sides
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
                    width: screenWidth * 0.15, // reduced from 0.13 to 0.11
                    height: screenWidth * 0.15,
                  ),
                  Text(
                    'RFID CARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          screenWidth * 0.070, // reduced from 0.065 to 0.055
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: screenHeight *
                      0.04), // 4% spacing - reduced to balance padding
              Row(
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
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
                      size: screenWidth * 0.045,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Flexible(
                child: Text(
                  isBalanceVisible
                      ? '₱${(cardData?['balance']?.toString() ?? '0').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}'
                      : '••••••',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
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

  Widget _buildAnnouncementSection(BuildContext context) {
    // Use real announcements from database
    if (isLoadingAnnouncements) {
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
        child: Center(
          child: CircularProgressIndicator(color: Ec_PRIMARY),
        ),
      );
    }

    if (announcements.isEmpty) {
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
                        'No Announcements',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Ec_PRIMARY,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Check back later for updates',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Ec_PRIMARY.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Ec_PRIMARY.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14.sp,
                              color: Ec_PRIMARY,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'All clear!',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Ec_PRIMARY,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final latestAnnouncement =
        _getMostUrgentAnnouncement() ?? announcements.first;

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
                    color: _getAnnouncementTypeColor(latestAnnouncement.type)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    latestAnnouncement.getIcon(),
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with urgent badge beside it
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              latestAnnouncement.title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (latestAnnouncement.isUrgent) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🚨',
                                    style: TextStyle(fontSize: 10.sp),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'URGENT',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
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
        const ActiveBookingScreen(),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
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
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Simple header
              Row(
                children: [
                  Icon(
                    _getStatusText(booking.status) == 'Completed'
                        ? Icons.check_circle_outline
                        : Icons.directions_boat_filled,
                    color: _getStatusText(booking.status) == 'Completed'
                        ? Colors.grey[600]
                        : Ec_PRIMARY,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
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
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward,
                    color: Ec_PRIMARY,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
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
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
                  Expanded(
                    child: Text(
                      '${_formatDateForDisplay(booking.departDate)} at ${_formatScheduleTime(booking.departTime)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Ec_BLACK,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
                  Expanded(
                    child: Text(
                      '${booking.passengers} passenger${booking.passengers == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Ec_BLACK,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      booking.shippingLine,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Ec_TEXT_COLOR_GREY,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.end,
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
                    Expanded(
                      child: Text(
                        'Vehicle included',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Ec_BLACK,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 16.h),

              // Enhanced Action Buttons
              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: BounceTapWrapper(
                      onTap: () => _navigateTo(
                        context,
                        const ActiveBookingScreen(),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Ec_PRIMARY.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border:
                              Border.all(color: Ec_PRIMARY.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Bookings',
                              style: TextStyle(
                                color: Ec_PRIMARY,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Ec_PRIMARY,
                              size: 12.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: BounceTapWrapper(
                      onTap: () => _navigateTo(
                        context,
                        const ScheduleScreen(showBackButton: true),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Ec_SECONDARY.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border:
                              Border.all(color: Ec_SECONDARY.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Schedules',
                                style: TextStyle(
                                  color: Ec_SECONDARY,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.schedule,
                                color: Ec_SECONDARY,
                                size: 12.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
              // Animated loading icon
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 1),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Container(
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
                  );
                },
                onEnd: () {
                  if (mounted) setState(() {});
                },
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Loading Booking',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Ec_PRIMARY,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildAnimatedDots(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Please wait while we fetch your booking details...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Ec_TEXT_COLOR_GREY,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 12.h),
          // Progress bar
          SizedBox(
            height: 4.h,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Ec_PRIMARY),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final dotValue = (value - delay).clamp(0.0, 1.0);
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: dotValue > 0.5 ? Ec_PRIMARY : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
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
          SizedBox(height: 16.h),
          Center(
            child: BounceTapWrapper(
              onTap: () => _navigateTo(
                context,
                const ScheduleScreen(showBackButton: true),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Ec_PRIMARY,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'View Available Schedules',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCards(BuildContext context) {
    final rateItems = DashboardData.getRateItems();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white, // White background like Book a Trip
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Light blue background like Book a Trip
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F3FF), // Light blue header background
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFF1A5A91), // Dark blue square like Book a Trip
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.attach_money_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Ferry Rates',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(
                        0xFF1A5A91), // Dark blue text like Book a Trip
                  ),
                ),
                Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFF1A5A91), // Dark blue button like Book a Trip
                    borderRadius: BorderRadius.circular(20.r),
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
          ),
          SizedBox(height: 16.h),

          // Rate Items
          Row(
            children: rateItems.map((item) {
              final isVehicle =
                  item['label']?.toString().toLowerCase().contains('vehicle') ??
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

          // See All Rates Button
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5A91).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: const Color(0xFF1A5A91).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All Rates',
                    style: TextStyle(
                      color: const Color(0xFF1A5A91),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0xFF1A5A91),
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
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

  // Helper method to get announcement type color
  Color _getAnnouncementTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      case 'maintenance':
        return Colors.yellow;
      case 'general':
        return Ec_PRIMARY;
      default:
        return Ec_PRIMARY;
    }
  }

  // Helper method to get the most urgent announcement
  AnnouncementModel? _getMostUrgentAnnouncement() {
    if (announcements.isEmpty) return null;

    final urgentAnnouncements = announcements.where((a) => a.isUrgent).toList();
    if (urgentAnnouncements.isEmpty) return announcements.first;

    // Sort by priority and return the most urgent
    urgentAnnouncements.sort((a, b) {
      final priorityOrder = {'critical': 4, 'high': 3, 'medium': 2, 'low': 1};
      final aPriority = priorityOrder[a.priority] ?? 0;
      final bPriority = priorityOrder[b.priority] ?? 0;
      return bPriority.compareTo(aPriority);
    });

    return urgentAnnouncements.first;
  }

  // Book Now Button Widget - Old Design
  Widget _buildBookNowButton(BuildContext context) {
    return BounceTapWrapper(
      onTap: () => _navigateTo(
        context,
        const ScheduleScreen(showBackButton: true),
      ),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Ec_PRIMARY.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_boat_filled,
                color: Ec_PRIMARY,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Ec_PRIMARY,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'View available schedules and book your trip',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Ec_PRIMARY,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  // Available Schedules Summary Widget - Now with Real Data
  Widget _buildAvailableSchedulesSummary(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white, // White background like rates section
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Light blue background
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F3FF), // Light blue header background
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFF1A5A91), // Dark blue square like in image
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.directions_boat_filled,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Book a Trip',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A5A91), // Dark blue text
                  ),
                ),
                Spacer(),
                BounceTapWrapper(
                  onTap: () => _navigateTo(
                    context,
                    const ScheduleScreen(showBackButton: true),
                  ),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A5A91), // Dark blue button
                      borderRadius: BorderRadius.circular(20.r),
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
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Real Schedule Items - Show up to 3 upcoming schedules
          if (isLoadingSchedules) ...[
            _buildScheduleLoadingItem(),
            SizedBox(height: 12.h),
            _buildScheduleLoadingItem(),
            SizedBox(height: 12.h),
            _buildScheduleLoadingItem(),
          ] else if (upcomingSchedules.isEmpty) ...[
            _buildNoSchedulesItem(),
          ] else ...[
            // Show up to 3 upcoming schedules
            ...upcomingSchedules.take(3).map((schedule) {
              debugPrint(
                  '🎫 Displaying schedule: ${schedule['departureLocation']} -> ${schedule['arrivalLocation']}');
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildScheduleSummaryItemReal(schedule),
              );
            }).toList(),
          ],

          SizedBox(height: 16.h),

          // View All Schedules Button
          Center(
            child: BounceTapWrapper(
              onTap: () => _navigateTo(
                context,
                const ScheduleScreen(showBackButton: true),
              ),
              child: Container(
                margin: EdgeInsets.only(top: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5A91)
                      .withOpacity(0.1), // Dark blue with opacity
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                      color: const Color(0xFF1A5A91).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Schedules',
                      style: TextStyle(
                        color: const Color(0xFF1A5A91), // Dark blue text
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFF1A5A91), // Dark blue arrow
                      size: 14.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Real Schedule Summary Item - Using Real Data
  Widget _buildScheduleSummaryItemReal(Map<String, dynamic> schedule) {
    final departDate = DateFormatUtil.safeParseDate(schedule['departDate']);
    final month =
        departDate != null ? _getMonthAbbreviation(departDate.month) : 'N/A';
    final day = departDate?.day.toString() ?? 'N/A';
    final departure = schedule['departureLocation'] ?? 'Unknown';
    final arrival = schedule['arrivalLocation'] ?? 'Unknown';
    final time = _formatScheduleTime(schedule['departTime'] ?? '00:00');

    return _buildScheduleSummaryItemExact(
      month: month,
      day: day,
      departure: departure,
      arrival: arrival,
      time: time,
    );
  }

  // Helper method to get month abbreviation
  String _getMonthAbbreviation(int month) {
    const months = [
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
    return months[month - 1];
  }

  // Schedule Loading Item
  Widget _buildScheduleLoadingItem() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Loading date square
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Loading content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 14.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Loading time badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Container(
              width: 40.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // No Schedules Item
  Widget _buildNoSchedulesItem() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: Colors.grey[400],
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'No upcoming schedules available',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Individual Schedule Summary Item - Exact Copy of Old Design
  Widget _buildScheduleSummaryItemExact({
    required String month,
    required String day,
    required String departure,
    required String arrival,
    required String time,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white, // White background like in image
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFF1A5A91)
              .withOpacity(0.2), // Dark blue outline for schedule cards
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Side - Date Square (Dark Blue)
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1A5A91), // Exact dark blue from image
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Middle Section - Route Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Departure location with blue dot
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A5A91), // Dark blue dot
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      departure,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                // Vertical dashed line
                Container(
                  margin: EdgeInsets.only(left: 3.w),
                  width: 2.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDBDBD), // Grey dashed line
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                ),

                // Arrival location with location pin
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: const Color(0xFF1A5A91), // Dark blue location pin
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      arrival,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Right Side - Time Badge (Light Grey)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), // Light grey background
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE0E0E0)), // Grey border
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A5A91), // Dark blue text
              ),
            ),
          ),
        ],
      ),
    );
  }
}
