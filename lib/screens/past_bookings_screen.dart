import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:EcBarko/constants.dart';
import '../models/booking_model.dart';
import '../utils/responsive_utils.dart';
import '../utils/date_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

String getBaseUrl() {
  return 'https://ecbarko-db.onrender.com';
}

class PastBookingsScreen extends StatefulWidget {
  const PastBookingsScreen({super.key});

  @override
  State<PastBookingsScreen> createState() => _PastBookingsScreenState();
}

class _PastBookingsScreenState extends State<PastBookingsScreen>
    with ResponsiveWidgetMixin {
  List<BookingModel> pastBookings = [];
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadPastBookings();
  }

  Future<void> _loadPastBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userID');
      final token = prefs.getString('token');

      if (currentUserId != null && token != null) {
        setState(() {
          userId = currentUserId;
        });

        final response = await http.get(
          Uri.parse('${getBaseUrl()}/api/actbooking/$currentUserId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          print('🔍 Past bookings raw data: $data'); // Debug log

          final List<BookingModel> bookings =
              data.map((json) => BookingModel.fromJson(json)).toList();

          // Filter past bookings (completed, cancelled, expired, or past departure dates)
          final pastBookingsList = bookings.where((booking) {
            // Check if booking is completed/cancelled/expired OR has past departure date
            final isPastStatus = booking.status.name == 'completed' ||
                booking.status.name == 'cancelled' ||
                booking.status.name == 'expired';

            // Parse the departure date string to DateTime
            try {
              final departDateTime = DateTime.parse(booking.departDate);
              final isPastDate = departDateTime.isBefore(DateTime.now());
              return isPastStatus || isPastDate;
            } catch (e) {
              // If date parsing fails, only check status
              return isPastStatus;
            }
          }).toList();

          // Sort by booking date (newest first)
          pastBookingsList
              .sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

          setState(() {
            pastBookings = pastBookingsList;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorSnackBar('Failed to load past bookings');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('User not authenticated');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error loading past bookings: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatTimeTo12Hour(String time24) {
    try {
      // Check if the time already has AM/PM
      if (time24.toUpperCase().contains('AM') ||
          time24.toUpperCase().contains('PM')) {
        return time24; // Return as is if already in 12-hour format
      }

      final parts = time24.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        String minute = parts[1];

        String period = hour >= 12 ? 'PM' : 'AM';
        int hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

        return '${hour12.toString().padLeft(2, '0')}:${minute} ${period}';
      }
      return time24;
    } catch (e) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: Text(
          'Past Bookings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Ec_PRIMARY,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPastBookings,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Ec_PRIMARY),
                ),
              )
            : pastBookings.isEmpty
                ? _buildEmptyState()
                : _buildPastBookingsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 50.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80.sp,
              color: Ec_PRIMARY.withOpacity(0.7),
            ),
            SizedBox(height: 20.h),
            Text(
              "No past bookings found",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Ec_TEXT_COLOR_GREY,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Your completed and cancelled trips will appear here",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastBookingsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: pastBookings.length,
      itemBuilder: (context, index) {
        final booking = pastBookings[index];
        return _buildPastBookingCard(booking);
      },
    );
  }

  Widget _buildPastBookingCard(BookingModel booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with booking ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.bookingId}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Ec_PRIMARY,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status.name),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _getStatusText(booking.status.name),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Route information
            Row(
              children: [
                Icon(Icons.location_on, size: 16.sp, color: Ec_PRIMARY),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${booking.departureLocation} → ${booking.arrivalLocation}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Date and time
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  DateFormatUtil.formatDateAbbreviated(booking.departDate),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.access_time, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  _formatTimeTo12Hour(booking.departTime),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Shipping line
            Row(
              children: [
                Icon(Icons.directions_boat,
                    size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  booking.shippingLine,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Passenger and vehicle info
            Row(
              children: [
                Icon(Icons.person, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  '${booking.passengers} Passenger${booking.passengers > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                if (booking.hasVehicle) ...[
                  SizedBox(width: 16.w),
                  Icon(Icons.directions_car,
                      size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    '1 Vehicle',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.orange;
      case 'active':
        return Colors
            .green; // Green for active bookings with past dates (treated as completed)
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      case 'active':
        return 'Completed'; // Show "Completed" for active bookings with past dates
      default:
        return status.toUpperCase();
    }
  }
}
