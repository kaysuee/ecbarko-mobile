import 'package:EcBarko/screens/booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:EcBarko/constants.dart';
import 'package:EcBarko/screens/ticket_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../widgets/constant_dialog.dart';

String getBaseUrl() {
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  //return 'https://ecbarko.onrender.com';
  return 'https://ecbarko-db.onrender.com';
  // return 'http://localhost:3000';
}

class PaymentScreen extends StatefulWidget {
  final String schedcde;
  final String departureLocation;
  final String arrivalLocation;
  final String departDate;
  final String departTime;
  final String arriveDate;
  final String arriveTime;
  final String shippingLine;
  final String selectedCardType;
  final List<Map<String, String>> passengers;
  final bool hasVehicle;
  final List<Map<String, String>> vehicleDetail;
  final String bookingReference;
  final VoidCallback? onPaymentCompleted; // Callback for payment completion

  PaymentScreen({
    super.key,
    required this.schedcde,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departDate,
    required this.departTime,
    required this.arriveDate,
    required this.arriveTime,
    required this.shippingLine,
    required this.selectedCardType,
    required this.passengers,
    required this.hasVehicle,
    required this.vehicleDetail,
    String? bookingReference,
    this.onPaymentCompleted,
  }) : bookingReference = _generateReference();

  static String _generateReference() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "EcBarko Card";
  double totalAmount = 0.0;
  List<double> passengerFares = [];
  double vehicleFare = 0.0;
  bool isPaymentCompleted = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    generateFixedFares();
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentKey = 'payment_${widget.bookingReference}';
    final completed = prefs.getBool(paymentKey) ?? false;

    if (completed) {
      setState(() {
        isPaymentCompleted = true;
      });
      // Show already paid dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlreadyPaidDialog();
      });
    }
  }

  void _showAlreadyPaidDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Ec_BG_SKY_BLUE,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Column(
            children: [
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.payment,
                  color: Colors.blue,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                'Payment Already Completed',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.blue[100]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue[700], size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Payment Status',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'This booking has already been paid for. You can view your e-ticket or go to your active bookings.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What would you like to do?',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    _buildActionButton(
                      context,
                      Icons.dashboard,
                      'Go to Dashboard',
                      Colors.grey[600]!,
                      () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    ),
                    SizedBox(height: 10.h),
                    _buildActionButton(
                      context,
                      Icons.confirmation_number,
                      'View E-Ticket',
                      Ec_PRIMARY,
                      () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketScreen(
                              passengers: widget.passengers,
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
                              vehicleDetail: widget.vehicleDetail,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    _buildActionButton(
                      context,
                      Icons.book_online,
                      'Active Bookings',
                      Ec_PRIMARY,
                      () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookingScreen(),
                          ),
                        );
                      },
                    ),
                    // Debug button for testing (remove in production)
                    SizedBox(height: 10.h),
                    _buildActionButton(
                      context,
                      Icons.refresh,
                      'Reset Payment (Debug)',
                      Colors.orange,
                      () async {
                        final prefs = await SharedPreferences.getInstance();
                        final paymentKey = 'payment_${widget.bookingReference}';
                        await prefs.remove(paymentKey);
                        Navigator.of(context).pop();
                        setState(() {
                          isPaymentCompleted = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _submit() async {
    if (isPaymentCompleted) {
      return false;
    }

    // Validate required fields
    if (widget.passengers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No passengers added. Please add at least one passenger.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate passenger details
    for (var passenger in widget.passengers) {
      if (passenger['name']?.trim().isEmpty == true ||
          passenger['contact']?.trim().isEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all passenger details.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    // Validate vehicle details if vehicle is included
    if (widget.hasVehicle && widget.vehicleDetail.isNotEmpty) {
      for (var vehicle in widget.vehicleDetail) {
        if (vehicle['plateNumber']?.trim().isEmpty == true ||
            vehicle['vehicleOwner']?.trim().isEmpty == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all vehicle details.'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      }
    }

    setState(() {
      isLoading = true;
    });

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

    final url = Uri.parse('${getBaseUrl()}/api/eticket');
    print('Submit error: user: $user');
    final body = {
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
      "passengers": widget.passengers, // already formatted list of name/contact
      "hasVehicle": widget.hasVehicle,
      "vehicleDetail": widget.vehicleDetail,
      "bookingReference": widget.bookingReference,
      "totalFare": totalAmount,
      "schedcde": widget.schedcde,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Mark payment as completed
        final paymentKey = 'payment_${widget.bookingReference}';
        await prefs.setBool(paymentKey, true);

        // Send booking created notification
        await NotificationService.notifyBookingCreated(
          userId: user,
          bookingId: widget.bookingReference,
          departureLocation: widget.departureLocation,
          arrivalLocation: widget.arrivalLocation,
          departDate: widget.departDate,
          departTime: widget.departTime,
        );

        setState(() {
          isPaymentCompleted = true;
          isLoading = false;
        });

        // Notify parent about payment completion
        widget.onPaymentCompleted?.call();

        return true;
      } else {
        final errorMessage = response.body.isNotEmpty
            ? jsonDecode(response.body)['message'] ?? 'Payment failed'
            : 'Payment failed with status: ${response.statusCode}';

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
    } catch (err) {
      print('Submit error: $err');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $err'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
      return false;
    }
  }

  void generateFixedFares() {
    passengerFares = List.generate(widget.passengers.length, (_) => 500);
    if (widget.hasVehicle) {
      vehicleFare = 1000;
    }
    totalAmount =
        passengerFares.fold(0.0, (sum, fare) => sum + fare) + vehicleFare;
  }

  @override
  Widget build(BuildContext context) {
    if (isPaymentCompleted) {
      return WillPopScope(
        onWillPop: () async {
          // Prevent going back to payment screen after completion
          Navigator.of(context).popUntil((route) => route.isFirst);
          return false;
        },
        child: Scaffold(
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
            backgroundColor: Colors.green,
            iconTheme: const IconThemeData(color: Colors.white),
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80.sp,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Payment Already Completed',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Go to Dashboard'),
                ),
                SizedBox(height: 20.h),
                // Debug button for testing (remove in production)
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final paymentKey = 'payment_${widget.bookingReference}';
                    await prefs.remove(paymentKey);
                    setState(() {
                      isPaymentCompleted = false;
                    });
                  },
                  child: Text(
                    'Reset Payment (Debug)',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14.sp,
                    ),
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
        // Show confirmation dialog when trying to go back
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment Method",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption("EcBarko Card", Icons.credit_card),
                  _buildPaymentOption("GCash", Icons.account_balance_wallet),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildBookingSummaryCard()),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Amount",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        "₱${totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final success =
                                await _submit(); // Wait for the API call to finish

                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Payment failed. Please try again.'),
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TicketScreen(
                                          passengers: widget.passengers,
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
                                          vehicleDetail: widget.vehicleDetail,
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.payment, color: Colors.white),
                    label: Text(isLoading ? "Processing..." : "Pay Now",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Ec_DARK_PRIMARY,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2),
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

  Widget _buildPaymentOption(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = label;
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selectedPaymentMethod == label
                ? Ec_PRIMARY
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        child: ListTile(
          leading: Icon(icon, color: Ec_PRIMARY),
          title:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Radio<String>(
            value: label,
            groupValue: selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value!;
              });
            },
            activeColor: Ec_PRIMARY,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_boat, color: Ec_PRIMARY),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${widget.departureLocation} ➝ ${widget.arrivalLocation}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.calendar_today,
                  "Depart: ${widget.departDate} at ${widget.departTime}"),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.event_available,
                  "Arrive: ${widget.arriveDate} at ${widget.arriveTime}"),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.local_shipping,
                  "Shipping Line: ${widget.shippingLine}"),
              const Divider(height: 30),
              const Text("👥 Passengers:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...List.generate(widget.passengers.length, (i) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Full Name: ${widget.passengers[i]["name"]}"),
                    Text("Contact Number: ${widget.passengers[i]["contact"]}"),
                    Text("Fare: ₱${passengerFares[i].toStringAsFixed(2)}"),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              if (widget.hasVehicle && widget.vehicleDetail.isNotEmpty) ...[
                const Divider(height: 30),
                const Text("🚗 Vehicle Details:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...List.generate(widget.vehicleDetail.length, (i) {
                  final vehicle = widget.vehicleDetail[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Driver Name: ${vehicle["vehicleOwner"] ?? "-"}"),
                      Text("Plate Number: ${vehicle["plateNumber"] ?? "-"}"),
                      Text("Car Type: ${vehicle["carType"] ?? "-"}"),
                      Text("Vehicle Fare: ₱${vehicleFare.toStringAsFixed(2)}"),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity, // Ensure full width
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              // Use Expanded instead of Spacer to prevent overflow
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis, // Handle very long text
              ),
            ),
            SizedBox(width: 8.w), // Small spacing before arrow
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
