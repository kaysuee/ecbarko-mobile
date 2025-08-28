import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../models/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/date_formatter.dart';

String getBaseUrl() {
  return 'https://ecbarko-db.onrender.com';
}

class CompletedBookingScreen extends StatefulWidget {
  final bool showBackButton;

  const CompletedBookingScreen({Key? key, this.showBackButton = true})
      : super(key: key);

  @override
  State<CompletedBookingScreen> createState() => _CompletedBookingScreenState();
}

class _CompletedBookingScreenState extends State<CompletedBookingScreen> {
  List<BookingModel> completedBookings = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCompletedBookings();
  }

  Future<void> _loadCompletedBookings() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userID');

      if (token == null || userId == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/actbooking/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<BookingModel> allBookings = [];

        for (var json in jsonList) {
          final booking = BookingModel.fromJson(json as Map<String, dynamic>);
          allBookings.add(booking);
        }

        // Filter and sort completed bookings
        final now = DateTime.now();
        final completed = allBookings.where((b) {
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
        }).toList();

        // Sort by creation date (latest first)
        completed.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        setState(() {
          completedBookings = completed;
          isLoading = false;
        });

        print(
            '🔍 DEBUG: Loaded ${completed.length} completed bookings out of ${allBookings.length} total');
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
      print('Error loading completed bookings: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: const Text(
          'Completed Trips',
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
      ),
      body: RefreshIndicator(
        onRefresh: _loadCompletedBookings,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (hasError) {
      return _buildErrorState();
    }

    if (completedBookings.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCompletedBookingsList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Ec_PRIMARY,
            strokeWidth: 3,
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading completed trips...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: Colors.red[400],
          ),
          SizedBox(height: 20.h),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: _loadCompletedBookings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Ec_PRIMARY,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 80.sp,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No completed trips yet',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Your completed trips will appear here once you have some.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Ec_PRIMARY.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Ec_PRIMARY.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Ec_PRIMARY,
                  size: 32.sp,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Trips are automatically marked as completed when:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Ec_PRIMARY,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  '• The departure date has passed\n• The booking status is marked as completed',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBookingsList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with trip count
          Container(
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
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Ec_PRIMARY,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Completed Trips',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Ec_PRIMARY.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Ec_PRIMARY.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${completedBookings.length} trip${completedBookings.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Ec_PRIMARY,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Completed bookings list
          ...completedBookings.asMap().entries.map((entry) {
            final index = entry.key;
            final booking = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildCompletedBookingCard(booking, index + 1),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCompletedBookingCard(BookingModel booking, int tripNumber) {
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
          // Header with trip number and completion status
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Ec_PRIMARY.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '#$tripNumber',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Ec_PRIMARY,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completed Trip',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${DateFormatter.formatDateForDisplay(booking.departDate)} at ${DateFormatter.formatScheduleTime(booking.departTime)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: booking.status == BookingStatus.completed
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: booking.status == BookingStatus.completed
                        ? Colors.green.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  booking.status == BookingStatus.completed
                      ? 'Completed'
                      : 'Past Date',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: booking.status == BookingStatus.completed
                        ? Colors.green[700]
                        : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Route info
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.grey[200]!,
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
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        booking.departureLocation,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Ec_PRIMARY.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Ec_PRIMARY,
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
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        booking.arrivalLocation,
                        style: TextStyle(
                          fontSize: 16.sp,
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
          ),

          SizedBox(height: 16.h),

          // Trip details
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16.sp,
                color: Colors.grey[500],
              ),
              SizedBox(width: 8.w),
              Text(
                '${booking.passengers} passenger${booking.passengers == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Text(
                booking.shippingLine,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
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
                  color: Colors.grey[500],
                ),
                SizedBox(width: 8.w),
                Text(
                  'Vehicle included',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 12.h),

          // Completion status indicator
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: booking.status == BookingStatus.completed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: booking.status == BookingStatus.completed
                    ? Colors.green.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  booking.status == BookingStatus.completed
                      ? Icons.check_circle
                      : Icons.schedule,
                  size: 16.sp,
                  color: booking.status == BookingStatus.completed
                      ? Colors.green[600]
                      : Colors.grey[500],
                ),
                SizedBox(width: 8.w),
                Text(
                  booking.status == BookingStatus.completed
                      ? 'Marked as completed'
                      : 'Trip date has passed',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: booking.status == BookingStatus.completed
                        ? Colors.green[700]
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
