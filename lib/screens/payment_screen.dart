import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../services/fare_service.dart';
import '../widgets/constant_dialog.dart';
import 'eticket_screen.dart';
import 'booking_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingReference;
  final String departureLocation;
  final String arrivalLocation;
  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String shippingLine;
  final bool hasVehicle;
  final String selectedCardType;
  final List<PassengerModel> passengers;
  final VehicleInfoModel? vehicleDetail;
  final String schedcde;

  const PaymentScreen({
    Key? key,
    required this.bookingReference,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departDate,
    required this.departTime,
    required this.arriveDate,
    required this.arriveTime,
    required this.shippingLine,
    required this.hasVehicle,
    required this.selectedCardType,
    required this.passengers,
    this.vehicleDetail,
    required this.schedcde,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "EcBarko Card";
  bool isLoading = false;
  bool isPaymentCompleted = false;
  double totalAmount = 0.0;
  List<double> passengerFares = [];
  double vehicleFare = 0.0;

  @override
  void initState() {
    super.initState();
    generateFixedFares();
    _checkPaymentStatus();
  }

  void generateFixedFares() {
    passengerFares.clear();
    double totalPassengerFare = 0.0;

    for (var passenger in widget.passengers) {
      double fare = FareService.getTotalPassengerFare(passenger.ticketType);
      passengerFares.add(fare);
      totalPassengerFare += fare;
    }

    if (widget.hasVehicle && widget.vehicleDetail != null) {
      vehicleFare =
          FareService.getVehicleFare(widget.vehicleDetail!.vehicleType);
    }

    totalAmount = totalPassengerFare + vehicleFare;
  }

  Future<void> _checkPaymentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentStatus =
        prefs.getString('payment_status_${widget.bookingReference}');

    if (paymentStatus == 'completed') {
      setState(() {
        isPaymentCompleted = true;
      });
    }
  }

  Future<bool> _submit() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      final user = prefs.getString('userID');

      if (email == null || user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User session expired. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return false;
      }

      // Convert passengers to the format expected by API
      List<Map<String, dynamic>> passengerMaps = widget.passengers
          .map((p) => {
                'name': p.name,
                'ticketType': p.ticketType,
                'contactNumber': p.contactNumber ?? '',
              })
          .toList();

      // Convert vehicle to the format expected by API
      List<Map<String, dynamic>> vehicleMaps = widget.vehicleDetail != null
          ? [
              {
                'carType': widget
                    .vehicleDetail!.vehicleType, // Server expects 'carType'
                'plateNumber': widget.vehicleDetail!.plateNumber,
                'vehicleOwner': widget.vehicleDetail!.owner ?? '',
              }
            ]
          : [];

      // Prepare booking data
      final bookingData = {
        "email": email,
        "user": user,
        "departureLocation": widget.departureLocation,
        "arrivalLocation": widget.arrivalLocation,
        "departDate": widget.departDate,
        "departTime": widget.departTime,
        "arriveDate": widget.arriveDate,
        "arriveTime": widget.arriveTime,
        "shippingLine": widget.shippingLine,
        "selectedCardType": widget.selectedCardType,
        "passengers": passengerMaps,
        "hasVehicle": widget.hasVehicle,
        "vehicleDetail": vehicleMaps,
        "bookingReference": widget.bookingReference,
        "totalFare": totalAmount,
        "paymentMethod": selectedPaymentMethod,
        "status": "active",
      };

      // Make API call to save booking
      print('🔍 Creating booking with data:');
      print('Email: $email');
      print('User: $user');
      print('Booking Reference: ${widget.bookingReference}');
      print('Total Fare: $totalAmount');
      print('Passengers: ${passengerMaps.length}');
      print('Has Vehicle: ${widget.hasVehicle}');
      print('Schedule Code: ${widget.schedcde}');

      final response = await BookingApi.createBooking(
        email: email,
        user: user,
        departureLocation: widget.departureLocation,
        arrivalLocation: widget.arrivalLocation,
        departDate: widget.departDate,
        departTime: widget.departTime,
        arriveDate: widget.arriveDate,
        arriveTime: widget.arriveTime,
        shippingLine: widget.shippingLine,
        selectedCardType: widget.selectedCardType,
        passengers: passengerMaps,
        hasVehicle: widget.hasVehicle,
        vehicleDetail: vehicleMaps,
        bookingReference: widget.bookingReference,
        totalFare: totalAmount,
        schedcde: widget.schedcde ??
            "SCH001", // Default schedule code if not provided
      );

      print('🔍 API Response: $response');

      if (response['success'] == true ||
          response['message'] == 'eTicket created successfully') {
        print(
            '✅ Booking created successfully! Email should be sent automatically.');

        // Save payment status locally
        await prefs.setString(
            'payment_status_${widget.bookingReference}', 'completed');

        // Show success notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Booking created successfully! Check your email for confirmation.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        setState(() {
          isLoading = false;
          isPaymentCompleted = true;
        });

        return true;
      } else {
        String errorMessage = response['message'] ??
            response['error'] ??
            'Payment failed. Please try again.';

        // Handle specific error cases
        if (errorMessage.contains('Insufficient funds')) {
          errorMessage =
              'Insufficient card balance. Please load your card first.';
        } else if (errorMessage.contains('Active card not found')) {
          errorMessage =
              'No active card found. Please activate your card first.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
      return false;
    }
  }

  void _showAlreadyPaidDialog() {
    ConstantDialog.showActionDialog(
      context: context,
      title: 'Payment Already Completed',
      message:
          'This booking has already been paid for. You can view your e-ticket or check your active bookings.',
      actions: [
        DialogAction(
          text: 'View E-Ticket',
          icon: Icons.confirmation_number,
          color: Ec_PRIMARY,
          onPressed: () {
            Navigator.of(context).pop();

            // Convert PassengerModel to Map<String, String>
            List<Map<String, String>> passengerMaps = widget.passengers
                .map((p) => {
                      'name': p.name,
                      'ticketType': p.ticketType,
                      'contactNumber': p.contactNumber ?? '',
                    })
                .toList();

            // Convert VehicleInfoModel to Map<String, String>
            List<Map<String, String>> vehicleMaps = widget.vehicleDetail != null
                ? [
                    {
                      'vehicleType': widget.vehicleDetail!.vehicleType,
                      'plateNumber': widget.vehicleDetail!.plateNumber,
                      'owner': widget.vehicleDetail!.owner ?? '',
                    }
                  ]
                : [];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ETicketScreen(
                  passengers: passengerMaps,
                  departureLocation: widget.departureLocation,
                  arrivalLocation: widget.arrivalLocation,
                  departDate: widget.departDate,
                  departTime: widget.departTime,
                  arriveDate: widget.arriveDate,
                  arriveTime: widget.arriveTime,
                  shippingLine: widget.shippingLine,
                  hasVehicle: widget.hasVehicle,
                  bookingReference: widget.bookingReference,
                  selectedCardType: widget.selectedCardType,
                  vehicleDetail: vehicleMaps,
                  totalFare: totalAmount,
                  paymentMethod: selectedPaymentMethod,
                  bookingStatus: 'Active',
                ),
              ),
            );
          },
        ),
        DialogAction(
          text: 'Active Bookings',
          icon: Icons.book_online,
          color: Ec_PRIMARY,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookingScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isPaymentCompleted) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Payment Completed',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Ec_PRIMARY,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Ec_BG_SKY_BLUE,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(32.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Payment Successful!',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Your booking has been confirmed',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      _buildActionButton(
                        'View E-Ticket',
                        Icons.confirmation_number,
                        () {
                          // Convert PassengerModel to Map<String, String>
                          List<Map<String, String>> passengerMaps =
                              widget.passengers
                                  .map((p) => {
                                        'name': p.name,
                                        'ticketType': p.ticketType,
                                        'contactNumber': p.contactNumber ?? '',
                                      })
                                  .toList();

                          // Convert VehicleInfoModel to Map<String, String>
                          List<Map<String, String>> vehicleMaps =
                              widget.vehicleDetail != null
                                  ? [
                                      {
                                        'vehicleType':
                                            widget.vehicleDetail!.vehicleType,
                                        'plateNumber':
                                            widget.vehicleDetail!.plateNumber,
                                        'owner':
                                            widget.vehicleDetail!.owner ?? '',
                                      }
                                    ]
                                  : [];

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ETicketScreen(
                                passengers: passengerMaps,
                                departureLocation: widget.departureLocation,
                                arrivalLocation: widget.arrivalLocation,
                                departDate: widget.departDate,
                                departTime: widget.departTime,
                                arriveDate: widget.arriveDate,
                                arriveTime: widget.arriveTime,
                                shippingLine: widget.shippingLine,
                                hasVehicle: widget.hasVehicle,
                                bookingReference: widget.bookingReference,
                                selectedCardType: widget.selectedCardType,
                                vehicleDetail: vehicleMaps,
                                totalFare: totalAmount,
                                paymentMethod: selectedPaymentMethod,
                                bookingStatus: 'Active',
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12.h),
                      _buildActionButton(
                        'Active Bookings',
                        Icons.book_online,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookingScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await ConstantDialog.showConfirmationDialog(
          context: context,
          title: 'Cancel Payment?',
          message:
              'Are you sure you want to cancel this payment? Your booking details will be lost.',
          confirmText: 'Yes, Cancel',
          cancelText: 'No, Continue',
          confirmColor: Colors.red,
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Payment',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Ec_PRIMARY,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Ec_BG_SKY_BLUE,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with booking reference
                Container(
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
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Ec_PRIMARY.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: Ec_PRIMARY,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking Reference',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              widget.bookingReference,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Ec_PRIMARY,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Payment Method Selection
                Text(
                  "Payment Method",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildPaymentOption("EcBarko Card", Icons.credit_card),
                SizedBox(height: 8.h),
                _buildPaymentOption("GCash", Icons.account_balance_wallet),

                SizedBox(height: 20.h),

                Expanded(child: _buildBookingSummaryCard()),
                SizedBox(height: 16.h),

                // Total amount and payment button
                Container(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "₱${totalAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Ec_PRIMARY,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final success = await _submit();

                                if (!success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Payment failed. Please try again.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                ConstantDialog.showActionDialog(
                                  context: context,
                                  title: 'Payment Successful!',
                                  message:
                                      'Your payment has been processed successfully and your booking is confirmed.',
                                  actions: [
                                    DialogAction(
                                      text: 'Go to Dashboard',
                                      icon: Icons.dashboard,
                                      color: Colors.grey[600]!,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      },
                                    ),
                                    DialogAction(
                                      text: 'View E-Ticket',
                                      icon: Icons.confirmation_number,
                                      color: Ec_PRIMARY,
                                      onPressed: () {
                                        Navigator.of(context).pop();

                                        // Convert PassengerModel to Map<String, String>
                                        List<Map<String, String>>
                                            passengerMaps = widget.passengers
                                                .map((p) => {
                                                      'name': p.name,
                                                      'ticketType':
                                                          p.ticketType,
                                                      'contactNumber':
                                                          p.contactNumber ?? '',
                                                    })
                                                .toList();

                                        // Convert VehicleInfoModel to Map<String, String>
                                        List<Map<String, String>> vehicleMaps =
                                            widget.vehicleDetail != null
                                                ? [
                                                    {
                                                      'vehicleType': widget
                                                          .vehicleDetail!
                                                          .vehicleType,
                                                      'plateNumber': widget
                                                          .vehicleDetail!
                                                          .plateNumber,
                                                      'owner': widget
                                                              .vehicleDetail!
                                                              .owner ??
                                                          '',
                                                    }
                                                  ]
                                                : [];

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ETicketScreen(
                                              passengers: passengerMaps,
                                              departureLocation:
                                                  widget.departureLocation,
                                              arrivalLocation:
                                                  widget.arrivalLocation,
                                              departDate: widget.departDate,
                                              departTime: widget.departTime,
                                              arriveDate: widget.arriveDate,
                                              arriveTime: widget.arriveTime,
                                              shippingLine: widget.shippingLine,
                                              hasVehicle: widget.hasVehicle,
                                              bookingReference:
                                                  widget.bookingReference,
                                              selectedCardType:
                                                  widget.selectedCardType,
                                              vehicleDetail: vehicleMaps,
                                              totalFare: totalAmount,
                                              paymentMethod:
                                                  selectedPaymentMethod,
                                              bookingStatus: 'Active',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    DialogAction(
                                      text: 'Active Bookings',
                                      icon: Icons.book_online,
                                      color: Ec_PRIMARY,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const BookingScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                        icon: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.payment, color: Colors.white),
                        label: Text(
                          isLoading ? "Processing..." : "Pay Now",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Ec_DARK_PRIMARY,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String label, IconData icon) {
    final isSelected = selectedPaymentMethod == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = label;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? Ec_PRIMARY.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Ec_PRIMARY : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isSelected ? Ec_PRIMARY : Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Ec_PRIMARY,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Ec_PRIMARY : Colors.black87,
                ),
              ),
            ),
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Ec_PRIMARY : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Ec_PRIMARY : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14.sp,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route information
            Row(
              children: [
                Icon(Icons.location_on, size: 16.sp, color: Ec_PRIMARY),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${widget.departureLocation} → ${widget.arrivalLocation}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Date and time
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  widget.departDate,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.access_time, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  widget.departTime,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Passenger details
            Text(
              'Passenger Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            ...widget.passengers.asMap().entries.map((entry) {
              int index = entry.key;
              PassengerModel passenger = entry.value;
              double fare = passengerFares[index];

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 16.sp, color: Ec_PRIMARY),
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
                            passenger.ticketType,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₱${fare.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Ec_PRIMARY,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            if (widget.hasVehicle && widget.vehicleDetail != null) ...[
              SizedBox(height: 16.h),

              // Vehicle details
              Text(
                'Vehicle Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_car, size: 16.sp, color: Ec_PRIMARY),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.vehicleDetail!.vehicleType,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Plate: ${widget.vehicleDetail!.plateNumber}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₱${vehicleFare.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Ec_PRIMARY,
                      ),
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

  Widget _buildActionButton(
      String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Ec_PRIMARY,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
