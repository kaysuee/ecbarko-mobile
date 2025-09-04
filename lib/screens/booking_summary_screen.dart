import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/booking_model.dart';
import '../constants.dart';
import '../utils/date_format.dart';
import '../services/fare_service.dart';

/// Standalone Booking Summary Screen
///
/// This screen displays a comprehensive booking summary with:
/// - App bar with title and share button
/// - Complete booking details using BookingSummaryWidget
/// - Pull-to-refresh functionality
/// - Responsive design
class BookingSummaryScreen extends StatelessWidget {
  final BookingModel booking;
  final bool showBackButton;
  final VoidCallback? onRefresh;
  final VoidCallback? onManageBooking;
  final VoidCallback? onShareBooking;

  const BookingSummaryScreen({
    super.key,
    required this.booking,
    this.showBackButton = true,
    this.onRefresh,
    this.onManageBooking,
    this.onShareBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: Text(
          'Booking Summary',
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
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              _showHelpDialog(context);
            },
            tooltip: 'Get Help',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: onShareBooking ??
                () {
                  _shareBookingDetails(context);
                },
            tooltip: 'Share Booking',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (onRefresh != null) {
            onRefresh!();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildEnhancedBookingSummary(),
                SizedBox(height: 20.h),
                _buildPassengerDetails(),
                if (booking.hasVehicle && booking.vehicleInfo != null) ...[
                  SizedBox(height: 20.h),
                  _buildVehicleDetails(),
                ],
                SizedBox(height: 20.h),
                _buildPaymentSummary(),
                SizedBox(height: 20.h),
                _buildBookingInfo(),
                SizedBox(height: 30.h),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareBookingDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing booking details...'),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Ec_PRIMARY, size: 24.sp),
            SizedBox(width: 8.w),
            Text('Booking Summary Help'),
          ],
        ),
        content: Text(
          'This screen shows all details of your ferry booking including trip information, passenger details, payment summary, and booking status. You can manage your booking or share the details from here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: TextStyle(color: Ec_PRIMARY)),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBookingSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
              Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey[600]),
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
              Icon(Icons.directions_boat, size: 16.sp, color: Colors.grey[600]),
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
    );
  }

  // Helper method to convert 24-hour format to 12-hour format
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

  // Helper method to get the appropriate logo based on shipping line
  Widget _getLogoWidget() {
    if (booking.shippingLine.toLowerCase().contains('starhorse')) {
      return Image.asset(
        'assets/images/starhorselogo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.directions_boat,
            color: Colors.white.withOpacity(0.7),
            size: 24.sp,
          );
        },
      );
    } else if (booking.shippingLine.toLowerCase().contains('montenegro')) {
      return Image.asset(
        'assets/images/montenegrologo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.directions_boat,
            color: Colors.white.withOpacity(0.7),
            size: 24.sp,
          );
        },
      );
    } else {
      return Icon(
        Icons.directions_boat,
        color: Colors.white.withOpacity(0.7),
        size: 24.sp,
      );
    }
  }

  Widget _buildPassengerDetails() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passenger Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Ec_PRIMARY,
            ),
          ),
          SizedBox(height: 12.h),
          ...booking.passengerDetails
              .map((passenger) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Ec_PRIMARY, size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                passenger.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${passenger.ticketType} - ₱${FareService.getTotalPassengerFare(passenger.ticketType).toStringAsFixed(2)}',
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
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildVehicleDetails() {
    if (booking.vehicleInfo == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Ec_PRIMARY,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.directions_car, color: Ec_PRIMARY, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.vehicleInfo!.vehicleType,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Plate: ${booking.vehicleInfo!.plateNumber} - ₱${FareService.getVehicleFare(booking.vehicleInfo!.vehicleType).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Ec_TEXT_COLOR_GREY,
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

  Widget _buildPaymentSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Ec_PRIMARY,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₱${booking.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Ec_PRIMARY,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Status',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: booking.paymentStatus == 'paid'
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  booking.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Ec_PRIMARY,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow('Booking Date', booking.bookingDate),
          _buildInfoRow('Status', booking.status.name.toUpperCase()),
          if (booking.paymentMethod != null)
            _buildInfoRow('Payment Method', booking.paymentMethod!),
          if (booking.transactionId != null)
            _buildInfoRow('Transaction ID', booking.transactionId!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Ec_TEXT_COLOR_GREY,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onManageBooking,
            icon: Icon(Icons.edit, size: 18.sp),
            label: Text('Manage Booking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Ec_PRIMARY,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShareBooking,
            icon: Icon(Icons.share, size: 18.sp),
            label: Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Ec_PRIMARY,
              side: BorderSide(color: Ec_PRIMARY),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
