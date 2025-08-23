import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/booking_model.dart'; // ✅ Import shared model

import '../constants.dart';

class BookingModel {
  final String bookingId;
  final String departureLocation;
  final String arrivalLocation;
  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String returnDate;
  final String returnTime;
  final bool isRoundTrip;
  final int passengers;
  final bool hasVehicle;
  final String status;
  final String shippingLine;
  final String departurePort;
  final String arrivalPort;
  final String bookingDate;
  final double totalAmount;
  final String paymentStatus;
  final List<Passenger> passengerDetails;
  final VehicleInfo? vehicleInfo;

  const BookingModel({
    required this.bookingId,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departDate,
    required this.departTime,
    required this.arriveDate,
    required this.arriveTime,
    this.returnDate = '',
    this.returnTime = '',
    this.isRoundTrip = false,
    required this.passengers,
    this.hasVehicle = false,
    required this.status,
    required this.shippingLine,
    required this.departurePort,
    required this.arrivalPort,
    required this.bookingDate,
    required this.totalAmount,
    required this.paymentStatus,
    required this.passengerDetails,
    this.vehicleInfo,
  });
}

class Passenger {
  final String name;
  final String ticketType;
  final double fare;

  const Passenger({
    required this.name,
    required this.ticketType,
    required this.fare,
  });
}

class VehicleInfo {
  final String vehicleType;
  final String plateNumber;
  final double fare;
  final String owner;

  const VehicleInfo({
    required this.vehicleType,
    required this.plateNumber,
    required this.fare,
    required this.owner,
  });
}

class BookingDetailsViewScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailsViewScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ec_BG_SKY_BLUE,
      appBar: AppBar(
        title: const Text(
          'Booking Details',
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingHeader(),
            SizedBox(height: 20.h),
            _buildTripDetails(),
            SizedBox(height: 20.h),
            _buildPassengerDetails(),
            if (booking.vehicleInfo != null) ...[
              SizedBox(height: 20.h),
              _buildVehicleDetails(),
            ],
            SizedBox(height: 20.h),
            _buildPaymentSummary(),
            SizedBox(height: 20.h),
            _buildBookingInfo(),
            SizedBox(height: 30.h),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingHeader() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking ID',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Ec_TEXT_COLOR_GREY,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: _getStatusColor(booking.status)),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(booking.status),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            booking.bookingId,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Ec_PRIMARY,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails() {
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
            'Trip Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Ec_PRIMARY,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Ec_PRIMARY,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${booking.departureLocation} - ${booking.departurePort}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${booking.departDate} at ${booking.departTime}',
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
          SizedBox(height: 8.h),
          Container(
            margin: EdgeInsets.only(left: 5.w),
            width: 2.w,
            height: 30.h,
            color: Ec_TEXT_COLOR_GREY.withOpacity(0.3),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Ec_PRIMARY,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${booking.arrivalLocation} - ${booking.arrivalPort}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${booking.arriveDate} at ${booking.arriveTime}',
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
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Ec_BG_SKY_BLUE,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_boat,
                  color: Ec_PRIMARY,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  booking.shippingLine,
                  style: TextStyle(
                    fontSize: 14.sp,
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

  Widget _buildPassengerDetails() {
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
            'Passenger Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Ec_PRIMARY,
            ),
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: booking.passengerDetails.length,
            separatorBuilder: (context, index) => Divider(height: 16.h),
            itemBuilder: (context, index) {
              final passenger = booking.passengerDetails[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passenger.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        passenger.ticketType,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Ec_TEXT_COLOR_GREY,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₱${passenger.fare.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Ec_PRIMARY,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetails() {
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
              Icon(
                Icons.directions_car,
                color: Ec_PRIMARY,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (booking.vehicleInfo != null)
                      Text(
                        'Driver: ${booking.vehicleInfo!.owner}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      booking.vehicleInfo!.vehicleType,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Plate No: ${booking.vehicleInfo!.plateNumber}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Ec_TEXT_COLOR_GREY,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₱${booking.vehicleInfo!.fare.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Ec_PRIMARY,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    double passengerTotal = booking.passengerDetails.fold(
      0,
      (sum, passenger) => sum + passenger.fare,
    );
    double vehicleTotal = booking.vehicleInfo?.fare ?? 0;

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
            'Payment Summary',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Ec_PRIMARY,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Passenger Fare (${booking.passengers})',
                style: TextStyle(fontSize: 14.sp),
              ),
              Text(
                '₱${passengerTotal.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
          if (vehicleTotal > 0) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehicle Fare',
                  style: TextStyle(fontSize: 14.sp),
                ),
                Text(
                  '₱${vehicleTotal.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ],
          Divider(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₱${booking.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Ec_PRIMARY,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: booking.paymentStatus == 'paid'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  booking.paymentStatus == 'paid'
                      ? Icons.check_circle_outline
                      : Icons.pending,
                  size: 16.sp,
                  color: booking.paymentStatus == 'paid'
                      ? Colors.green
                      : Colors.orange,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Payment ${booking.paymentStatus.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: booking.paymentStatus == 'paid'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
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
          _buildInfoRow(
              'Trip Type', booking.isRoundTrip ? 'Round Trip' : 'One Way'),
          if (booking.isRoundTrip) ...[
            _buildInfoRow('Return Date', booking.returnDate),
            _buildInfoRow('Return Time', booking.returnTime),
          ],
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to manage booking screen
              _showManageOptions(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Ec_PRIMARY.withOpacity(0.1),
              foregroundColor: Ec_PRIMARY,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Manage Booking',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Save or share booking details
              _shareBookingDetails(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Ec_PRIMARY,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Share Details',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _showManageOptions(BuildContext context) {
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
                leading: const Icon(Icons.edit, color: Ec_PRIMARY),
                title: const Text('Modify Booking'),
                subtitle: const Text('Change date, time, or passengers'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to modify booking screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel Booking',
                    style: TextStyle(color: Colors.red)),
                subtitle: const Text('Cancel and get refund'),
                onTap: () {
                  Navigator.pop(context);
                  _showCancelConfirmation(context);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  void _showCancelConfirmation(BuildContext context) {
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
              Navigator.pop(context); // Return to previous screen
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

  void _shareBookingDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing booking details...'),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Ec_PRIMARY;
    }
  }
}
