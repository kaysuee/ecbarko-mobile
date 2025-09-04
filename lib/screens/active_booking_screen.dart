import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:EcBarko/constants.dart';
import '../models/booking_model.dart';
import '../utils/responsive_utils.dart';
import '../utils/date_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/booking_summary_screen.dart';
import '../screens/eticket_screen.dart';
import '../screens/past_bookings_screen.dart';
import 'package:flutter/material.dart';

String getBaseUrl() {
  return 'https://ecbarko-db.onrender.com';
}

class ActiveBookingScreen extends StatefulWidget {
  const ActiveBookingScreen({super.key});

  @override
  State<ActiveBookingScreen> createState() => _ActiveBookingScreenState();
}

class _ActiveBookingScreenState extends State<ActiveBookingScreen>
    with ResponsiveWidgetMixin {
  List<BookingModel> activeBookings = [];
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadActiveBookings();
  }

  Future<void> _loadActiveBookings() async {
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
          print('🔍 Active bookings raw data: $data'); // Debug log

          final List<BookingModel> bookings =
              data.map((json) => BookingModel.fromJson(json)).toList();

          // Filter only active bookings (exclude completed, cancelled, and past dates)
          final activeBookingsList = bookings.where((booking) {
            // Check if booking is active/confirmed AND departure date is in the future
            final isActiveStatus = booking.status.name == 'active' ||
                booking.status.name == 'confirmed';

            // Parse the departure date string to DateTime
            try {
              final departDateTime = DateTime.parse(booking.departDate);
              final isFutureDate = departDateTime.isAfter(DateTime.now());
              return isActiveStatus && isFutureDate;
            } catch (e) {
              // If date parsing fails, treat as active booking
              return isActiveStatus;
            }
          }).toList();

          // Sort by booking date (newest first)
          activeBookingsList
              .sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

          setState(() {
            activeBookings = activeBookingsList;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorSnackBar('Failed to load active bookings');
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
      _showErrorSnackBar('Error loading active bookings: $e');
    }
  }

  void _showPastBookings() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PastBookingsScreen(),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: Text(
          'Active Bookings',
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
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.white,
              size: 28.sp,
            ),
            onPressed: _showPastBookings,
            tooltip: 'View Past Bookings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadActiveBookings,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Ec_PRIMARY),
                ),
              )
            : activeBookings.isEmpty
                ? _buildEmptyState()
                : _buildBookingsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No Active Bookings',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You don\'t have any active bookings at the moment.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: activeBookings.length,
      itemBuilder: (context, index) {
        final booking = activeBookings[index];
        return _buildActiveBookingCard(booking);
      },
    );
  }

  Widget _buildActiveBookingCard(BookingModel booking) {
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
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Active',
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

            SizedBox(height: 16.h),

            // Action buttons
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Ec_PRIMARY,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () => _viewBookingSummary(booking),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () => _viewETicket(booking),
                        child: Text(
                          'View E-Ticket',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: () => _showSupportDialog(context),
                    child: Text(
                      'Get Help',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  // Helper method to get time ago
  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to convert 24-hour format to 12-hour format
  String _formatTimeTo12Hour(String time24) {
    try {
      // Check if the time already has AM/PM
      if (time24.toUpperCase().contains('AM') ||
          time24.toUpperCase().contains('PM')) {
        return time24; // Return as is if already in 12-hour format
      }

      // Parse the time string (assuming format like "14:30" or "09:15")
      final parts = time24.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        String minute = parts[1];

        String period = hour >= 12 ? 'PM' : 'AM';
        int hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

        return '${hour12.toString().padLeft(2, '0')}:${minute} ${period}';
      }
      return time24; // Return original if parsing fails
    } catch (e) {
      return time24; // Return original if parsing fails
    }
  }

  void _viewETicket(BookingModel booking) {
    // Debug: Print booking data to see what we're working with
    print('DEBUG: Booking hasVehicle = ${booking.hasVehicle}');
    print('DEBUG: Booking vehicleInfo = ${booking.vehicleInfo}');
    print('DEBUG: Passenger Details:');
    for (var passenger in booking.passengerDetails) {
      print('  - Name: ${passenger.name}, Contact: ${passenger.contactNumber}');
    }
    if (booking.hasVehicle && booking.vehicleInfo != null) {
      print('DEBUG: Vehicle owner = ${booking.vehicleInfo!.owner}');
      print('DEBUG: Vehicle customType = ${booking.vehicleInfo!.customType}');
    }

    // Convert booking data to ETicketScreen format
    final passengers = booking.passengerDetails
        .map((passenger) => {
              'name': passenger.name,
              'contactNumber': (passenger.contactNumber != null &&
                      passenger.contactNumber!.isNotEmpty)
                  ? passenger.contactNumber!
                  : 'Contact not provided',
            })
        .toList()
        .cast<Map<String, String>>();

    final vehicleDetail = booking.hasVehicle && booking.vehicleInfo != null
        ? [
            {
              'vehicleType': booking.vehicleInfo!.vehicleType,
              'plateNumber': booking.vehicleInfo!.plateNumber,
              'owner': (booking.vehicleInfo!.owner != null &&
                      booking.vehicleInfo!.owner!.isNotEmpty)
                  ? booking.vehicleInfo!.owner!
                  : (booking.vehicleInfo!.customType != null &&
                          booking.vehicleInfo!.customType!.isNotEmpty)
                      ? booking.vehicleInfo!.customType!
                      : 'Driver not specified',
            }
          ].cast<Map<String, String>>()
        : <Map<String, String>>[];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ETicketScreen(
          departureLocation: booking.departureLocation,
          arrivalLocation: booking.arrivalLocation,
          departDate: booking.departDate,
          departTime: booking.departTime,
          arriveDate: booking.arriveDate,
          arriveTime: booking.arriveTime,
          shippingLine: booking.shippingLine,
          selectedCardType: 'Type 1 (1.0 - 3.0 LM)', // Default card type
          passengers: passengers,
          hasVehicle: booking.hasVehicle,
          vehicleDetail: vehicleDetail,
          bookingReference: booking.bookingId,
          totalFare: booking.totalAmount,
          paymentMethod: booking.paymentMethod ?? 'Not specified',
          bookingStatus: booking.status.name,
        ),
      ),
    );
  }

  void _viewBookingSummary(BookingModel booking) {
    // Navigate to booking summary screen using the new widget
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSummaryScreen(
          booking: booking,
          showBackButton: true,
          onRefresh: () async {
            // Refresh active bookings when returning from summary
            await _loadActiveBookings();
          },
          onManageBooking: () {
            // Handle manage booking action
            _showManageBookingOptions(booking);
          },
          onShareBooking: () {
            // Handle share booking action
            _shareBookingDetails(booking);
          },
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Container(
          padding: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Ec_PRIMARY.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.support_agent,
                  color: Ec_PRIMARY,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Support',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Ec_PRIMARY,
                      ),
                    ),
                    Text(
                      'We\'re here to help with your booking',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContactInfo(
                Icons.phone,
                'Phone Support',
                '+63 912 345 6789',
                'Available 24/7 for immediate assistance',
              ),
              SizedBox(height: 16.h),
              _buildContactInfo(
                Icons.email,
                'Email Support',
                'support@ecbarko.com',
                'Send detailed inquiries and get responses within 24 hours',
              ),
              SizedBox(height: 16.h),
              _buildContactInfo(
                Icons.location_on,
                'Port Assistance',
                'Dalahican & Balanacan Ports',
                'Visit our customer service desk at the ports',
              ),
              SizedBox(height: 16.h),
              _buildContactInfo(
                Icons.access_time,
                'Support Hours',
                '24/7 Customer Support',
                'We\'re always here to help you with your travel needs',
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Ec_PRIMARY,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Got it',
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

  Widget _buildContactInfo(
    IconData icon,
    String label,
    String value,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Ec_PRIMARY,
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Ec_PRIMARY,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showManageBookingOptions(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Booking',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue), // ✅ fixed
                title: const Text('Modify Booking'),
                subtitle: const Text('Change date, time, or passengers'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Modify booking functionality coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel Booking',
                    style: TextStyle(color: Colors.red)),
                subtitle: const Text('Cancel and get refund'),
                onTap: () {
                  Navigator.pop(context);
                  _showCancelConfirmation(booking);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  void _showCancelConfirmation(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
            'Are you sure you want to cancel booking ${booking.bookingId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual cancellation logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Booking ${booking.bookingId} cancelled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareBookingDetails(BookingModel booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing booking ${booking.bookingId}...'),
      ),
    );
  }
}
